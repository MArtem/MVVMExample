#!/usr/bin/env python3
"""Deterministic, dependency-free static gate for the MVVMExample repository."""

from __future__ import annotations

import json
import re
import subprocess
import sys
import xml.etree.ElementTree as element_tree
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
APP_ROOT = Path("MVVMExample/MVVMExampleDemo")
PROJECT = Path("MVVMExample.xcodeproj/project.pbxproj")
SCHEME = Path("MVVMExample.xcodeproj/xcshareddata/xcschemes/MVVMExample.xcscheme")
TEST_PLANS = {
    Path("MVVMExample.xctestplan"): ("MVVMExampleTests", "177120BDB76CBC9039B9FB95"),
    Path("MVVMExampleUI.xctestplan"): ("MVVMExampleUITests", "7C17E40D544DCA5DEFEA3454"),
}
TARGET_BUNDLE_IDENTIFIERS = {
    "MVVMExample": "com.example.MVVMExample",
    "MVVMExampleTests": "com.example.MVVMExampleTests",
    "MVVMExampleUITests": "com.example.MVVMExampleUITests",
}
MAX_TRACKED_FILE_BYTES = 5 * 1024 * 1024
MAX_TEXT_SCAN_BYTES = 2 * 1024 * 1024
FORBIDDEN_COMPONENT_SUFFIXES = (".xcarchive", ".xcresult", ".ipa", ".dSYM", ".app")


@dataclass(frozen=True)
class Finding:
    severity: str
    rule: str
    path: str
    message: str
    line: int | None = None

    def render(self) -> str:
        location = self.path
        if self.line is not None:
            location += f":{self.line}"
        return f"{self.severity} {self.rule} {location} — {self.message}"


def tracked_files() -> list[Path]:
    result = subprocess.run(
        ["git", "-C", str(ROOT), "ls-files", "-z"],
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError("git ls-files failed; the static gate requires a Git worktree")
    return [Path(item.decode("utf-8")) for item in result.stdout.split(b"\0") if item]


def line_number(text: str, position: int) -> int:
    return text.count("\n", 0, position) + 1


def text_at(path: Path) -> str | None:
    absolute = ROOT / path
    if absolute.is_symlink():
        return None
    try:
        if absolute.stat().st_size > MAX_TEXT_SCAN_BYTES:
            return None
        return absolute.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return None


def executable_text(text: str) -> str:
    """Remove comments before source-pattern checks to avoid documentation false positives."""
    def blank(match: re.Match[str]) -> str:
        return "".join("\n" if character == "\n" else " " for character in match.group(0))

    without_blocks = re.sub(r"/\*.*?\*/", blank, text, flags=re.DOTALL)
    return re.sub(r"//[^\n]*", blank, without_blocks)


def contains_pbx_object(project_text: str, isa: str) -> bool:
    return f"isa = {isa};" in project_text


def pbx_object_body(project_text: str, identifier: str) -> str | None:
    match = re.search(
        rf"(?ms)^\t\t{re.escape(identifier)} /\* .*? \*/ = \{{(?P<body>.*?)^\t\t\}};",
        project_text,
    )
    return match.group("body") if match else None


def native_target(project_text: str, target_name: str) -> tuple[str, str] | None:
    match = re.search(
        rf"(?ms)^\t\t([A-F0-9]+) /\* {re.escape(target_name)} \*/ = \{{\n\t\t\tisa = PBXNativeTarget;(?P<body>.*?)^\t\t\}};",
        project_text,
    )
    return (match.group(1), match.group("body")) if match else None


def source_member_names(project_text: str, target_name: str) -> set[str] | None:
    target = native_target(project_text, target_name)
    if target is None:
        return None
    _, target_body = target
    phase_ids = re.findall(r"([A-F0-9]+) /\* Sources \*/", target_body)
    if len(phase_ids) != 1:
        return None
    phase_body = pbx_object_body(project_text, phase_ids[0])
    if phase_body is None or "isa = PBXSourcesBuildPhase;" not in phase_body:
        return None
    return set(re.findall(r"/\* ([^*]+\.swift) in Sources \*/", phase_body))


def build_settings_for_target(project_text: str, target_name: str) -> dict[str, dict[str, str]] | None:
    target = native_target(project_text, target_name)
    if target is None:
        return None
    _, target_body = target
    configuration_list = re.search(r"buildConfigurationList = ([A-F0-9]+)", target_body)
    if configuration_list is None:
        return None
    list_body = pbx_object_body(project_text, configuration_list.group(1))
    if list_body is None or "isa = XCConfigurationList;" not in list_body:
        return None
    configurations = re.findall(r"([A-F0-9]+) /\* (Debug|Release) \*/", list_body)
    if {name for _, name in configurations} != {"Debug", "Release"}:
        return None

    result: dict[str, dict[str, str]] = {}
    for identifier, name in configurations:
        configuration_body = pbx_object_body(project_text, identifier)
        if configuration_body is None:
            return None
        settings_match = re.search(r"(?ms)^\t\t\tbuildSettings = \{(?P<settings>.*?)^\t\t\t\};", configuration_body)
        if settings_match is None:
            return None
        result[name] = {
            key: value.strip().strip('"')
            for key, value in re.findall(r"(?m)^\t\t\t\t([A-Z0-9_]+) = (.*?);$", settings_match.group("settings"))
        }
    return result


def is_allowlisted_demo_credential(value: str) -> bool:
    return (
        value.startswith(("dev-access-", "dev-refresh-", "reqres-demo-refresh-", "${"))
        or value.endswith("-not-a-secret")
    )


def check_repository_hygiene(files: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    lowercase_paths: dict[str, Path] = {}
    secret_patterns = (
        ("QC.SECRET.PRIVATE_KEY", re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH |)?PRIVATE KEY-----")),
        ("QC.SECRET.AWS_ACCESS_KEY", re.compile(r"AKIA[0-9A-Z]{16}")),
        ("QC.SECRET.HARDCODED_CREDENTIAL", re.compile(r"(?i)(?:api[_-]?key|secret|token|password)\s*[:=]\s*[\"'][^\"']{16,}[\"']")),
    )

    for path in files:
        absolute = ROOT / path
        path_string = path.as_posix()
        folded = path_string.casefold()
        if folded in lowercase_paths and lowercase_paths[folded] != path:
            findings.append(Finding("FAIL", "QC.REPOSITORY.CASE_COLLISION", path_string, f"conflicts with {lowercase_paths[folded]} on a case-insensitive filesystem"))
        else:
            lowercase_paths[folded] = path

        if absolute.is_symlink():
            findings.append(Finding("FAIL", "QC.REPOSITORY.SYMLINK", path_string, "tracked symlinks are not accepted by this deterministic source gate"))
            continue
        try:
            size = absolute.stat().st_size
        except OSError:
            findings.append(Finding("FAIL", "QC.REPOSITORY.MISSING_TRACKED_FILE", path_string, "tracked path cannot be read"))
            continue
        if size > MAX_TRACKED_FILE_BYTES:
            findings.append(Finding("FAIL", "QC.REPOSITORY.LARGE_FILE", path_string, f"tracked file exceeds {MAX_TRACKED_FILE_BYTES // (1024 * 1024)} MiB"))

        components = path.parts
        if any(component.endswith(FORBIDDEN_COMPONENT_SUFFIXES) for component in components):
            findings.append(Finding("FAIL", "QC.REPOSITORY.GENERATED_ARTIFACT", path_string, "generated build or release artifact is tracked"))

        text = text_at(path)
        if text is None:
            continue
        for rule, pattern in secret_patterns:
            for match in pattern.finditer(text):
                literal = match.group(0)
                quoted_value = re.search(r"[\"']([^\"']+)[\"']\s*$", literal)
                if rule == "QC.SECRET.HARDCODED_CREDENTIAL" and quoted_value and is_allowlisted_demo_credential(quoted_value.group(1)):
                    continue
                findings.append(Finding("FAIL", rule, path_string, "possible credential in tracked source", line_number(text, match.start())))
    return findings


def check_project_contract(files: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    tracked = set(files)
    required = {PROJECT, SCHEME, *TEST_PLANS}
    for path in sorted(required):
        if path not in tracked:
            findings.append(Finding("FAIL", "QC.XCODE.REQUIRED_FILE", path.as_posix(), "required Xcode contract file is not tracked"))
            continue
        if (ROOT / path).is_symlink():
            findings.append(Finding("FAIL", "QC.XCODE.SYMLINK", path.as_posix(), "Xcode contract files must not be symlinks"))

    project_path = ROOT / PROJECT
    if not project_path.exists():
        return findings
    lint = subprocess.run(["plutil", "-lint", str(project_path)], capture_output=True, text=True, check=False)
    if lint.returncode != 0:
        findings.append(Finding("FAIL", "QC.XCODE.PROJECT_SYNTAX", PROJECT.as_posix(), lint.stderr.strip() or lint.stdout.strip() or "plutil rejected project.pbxproj"))
        return findings

    project_text = project_path.read_text(encoding="utf-8")
    for target_name, expected_bundle_identifier in TARGET_BUNDLE_IDENTIFIERS.items():
        configurations = build_settings_for_target(project_text, target_name)
        if configurations is None:
            findings.append(Finding("FAIL", "QC.XCODE.BUILD_CONTRACT", PROJECT.as_posix(), f"could not parse Debug and Release settings for {target_name}"))
            continue
        for configuration_name, settings in configurations.items():
            for key, expected_value in (
                ("IPHONEOS_DEPLOYMENT_TARGET", "17.0"),
                ("SWIFT_VERSION", "5.0"),
                ("PRODUCT_BUNDLE_IDENTIFIER", expected_bundle_identifier),
            ):
                if settings.get(key) != expected_value:
                    findings.append(Finding("FAIL", "QC.XCODE.BUILD_CONTRACT", PROJECT.as_posix(), f"{target_name} {configuration_name} must set {key} = {expected_value}"))
    for forbidden in ("PBXShellScriptBuildPhase", "XCRemoteSwiftPackageReference", "XCLocalSwiftPackageReference"):
        if contains_pbx_object(project_text, forbidden):
            findings.append(Finding("FAIL", "QC.XCODE.UNAPPROVED_BUILD_EDGE", PROJECT.as_posix(), f"unexpected build-graph edge: {forbidden}"))

    source_members = source_member_names(project_text, "MVVMExample")
    if source_members is None:
        findings.append(Finding("FAIL", "QC.XCODE.SOURCES_PHASE", PROJECT.as_posix(), "could not parse the app target Sources build phase"))
        source_members = set()
    for path in files:
        if path.suffix == ".swift" and path.is_relative_to(APP_ROOT) and path.name not in source_members:
            findings.append(Finding("FAIL", "QC.XCODE.SOURCE_MEMBERSHIP", path.as_posix(), "application Swift file is not in the app target Sources build phase"))

    try:
        scheme_root = element_tree.parse(ROOT / SCHEME).getroot()
        references = {node.attrib.get("reference") for node in scheme_root.findall(".//TestPlanReference")}
        expected = {f"container:{path.name}" for path in TEST_PLANS}
        if not expected.issubset(references):
            findings.append(Finding("FAIL", "QC.XCODE.SCHEME_TEST_PLANS", SCHEME.as_posix(), "shared scheme does not reference both required test plans"))
    except (OSError, element_tree.ParseError):
        findings.append(Finding("FAIL", "QC.XCODE.SCHEME_SYNTAX", SCHEME.as_posix(), "shared scheme is not valid XML"))

    for path, (target_name, target_identifier) in TEST_PLANS.items():
        try:
            payload = json.loads((ROOT / path).read_text(encoding="utf-8"))
            enabled_targets = [item["target"] for item in payload["testTargets"] if item.get("enabled")]
            expected_target = {
                "containerPath": "container:MVVMExample.xcodeproj",
                "identifier": target_identifier,
                "name": target_name,
            }
            if enabled_targets != [expected_target] or payload.get("version") != 1:
                raise ValueError("target contract mismatch")
        except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError):
            findings.append(Finding("FAIL", "QC.XCODE.TEST_PLAN_CONTRACT", path.as_posix(), f"must be a version-1 plan for {target_name}"))
    return findings


def check_resources(files: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        if path.suffix not in {".json", ".xcstrings"}:
            continue
        if not (path.parts[:1] == ("MVVMExample",) or "Assets.xcassets" in path.parts):
            continue
        try:
            payload = json.loads((ROOT / path).read_text(encoding="utf-8"))
            if path.suffix == ".xcstrings" and (payload.get("sourceLanguage") != "en" or not isinstance(payload.get("strings"), dict)):
                raise ValueError("catalog shape")
        except (OSError, ValueError, json.JSONDecodeError):
            findings.append(Finding("FAIL", "QC.RESOURCE.JSON_CONTRACT", path.as_posix(), "resource JSON is malformed or has an invalid catalog shape"))
    return findings


def check_app_architecture(files: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    forbidden_patterns = (
        ("QC.MVVM.GENERIC_ACTION_DISPATCH", re.compile(r"func\s+send\s*\(\s*_\s+action\s*:"), "ViewModels must expose explicit intent methods"),
        ("QC.MVVM.ACTION_ENUM", re.compile(r"enum\s+\w+Action\s*:\s*Equatable"), "action enums require an approved reducer architecture"),
        ("QC.PERFORMANCE.SYNC_FILE_LOAD", re.compile(r"Data\s*\(\s*contentsOf\s*:"), "synchronous file load is forbidden in app source"),
        ("QC.PERFORMANCE.TYPE_ERASURE", re.compile(r"\bAnyView\s*\("), "unnecessary SwiftUI type erasure is forbidden"),
    )
    app_files = [path for path in files if path.suffix == ".swift" and path.is_relative_to(APP_ROOT)]
    for path in app_files:
        text = text_at(path)
        if text is None:
            findings.append(Finding("FAIL", "QC.SOURCE.UNREADABLE", path.as_posix(), "application source must be UTF-8 and below the static scan limit"))
            continue
        source = executable_text(text)
        for rule, pattern, message in forbidden_patterns:
            for match in pattern.finditer(source):
                findings.append(Finding("FAIL", rule, path.as_posix(), message, line_number(text, match.start())))
        path_string = path.as_posix()
        if "/Domain/" in path_string and re.search(r"\bimport\s+SwiftUI\b|\bURLSession\b|\b(?:\w+DTO)\b", source):
            findings.append(Finding("FAIL", "QC.MVVM.DOMAIN_BOUNDARY", path_string, "Domain must not depend on SwiftUI, URLSession, or DTO types"))
        if "/Presentation/" in path_string and re.search(r"\bURLSession\b|\bURLRequest\b|\bURLSessionAPIClient\b|\bURLSessionNetworkClient\b", source):
            findings.append(Finding("FAIL", "QC.MVVM.PRESENTATION_NETWORKING", path_string, "Presentation must depend on repositories, not transport clients"))
        if any(component in path_string for component in ("/Data/API/", "/Infrastructure/Networking/", "/Infrastructure/LocalSupport/AppNetworking/")) and "try?" in source:
            findings.append(Finding("FAIL", "QC.NETWORK.SILENCED_FAILURE", path_string, "API boundary must not silence errors with try?"))

    receipt_contract = ROOT / APP_ROOT / "Infrastructure/Persistence/PendingMutationStore.swift"
    interaction_contract = ROOT / APP_ROOT / "Features/News/Domain/ArticleInteractionStore.swift"
    receipt_text = executable_text(receipt_contract.read_text(encoding="utf-8")) if receipt_contract.exists() else ""
    interaction_text = executable_text(interaction_contract.read_text(encoding="utf-8")) if interaction_contract.exists() else ""
    required_receipt_fragments = (
        "func clear(_ receipt: PendingMutationReceipt)",
        "payloadData == receipt.payloadData",
        "func markFailure(_ receipt: PendingMutationReceipt",
        "func clearPendingLike(_ receipt: PendingMutationReceipt)",
    )
    for fragment in required_receipt_fragments:
        if fragment not in receipt_text + interaction_text:
            findings.append(Finding("FAIL", "QC.MUTATION.RECEIPT_CONTRACT", "MVVMExample/MVVMExampleDemo", f"missing versioned mutation acknowledgement contract: {fragment}"))
    if re.search(r"clearPendingLike\s*\(\s*(?:articleID|id)\s*:", interaction_text):
        findings.append(Finding("FAIL", "QC.MUTATION.UNCONDITIONAL_CLEAR", interaction_contract.relative_to(ROOT).as_posix(), "pending mutations must be cleared by receipt, not logical ID"))
    return findings


def advisory_findings(files: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    for path in files:
        if path.suffix != ".swift" or not path.is_relative_to(APP_ROOT) or "ViewModel.swift" not in path.name:
            continue
        text = text_at(path)
        if text is None:
            continue
        for match in re.finditer(r"\bTask\s*\{", text):
            prefix = text[max(0, match.start() - 100):match.start()]
            if "=" not in prefix:
                findings.append(Finding("ADVISORY", "QC.SWIFTUI.TASK_OWNERSHIP", path.as_posix(), "inspect task cancellation and stale-result ownership", line_number(text, match.start())))
    return findings


def main() -> int:
    try:
        files = tracked_files()
        findings = (
            check_repository_hygiene(files)
            + check_project_contract(files)
            + check_resources(files)
            + check_app_architecture(files)
            + advisory_findings(files)
        )
    except Exception as error:  # Gate failures must never masquerade as PASS.
        print(f"FAIL QC.GATE.INTERNAL scripts/static_quality_gate.py — {error}")
        return 2

    blocking = [finding for finding in findings if finding.severity == "FAIL"]
    advisory = [finding for finding in findings if finding.severity == "ADVISORY"]
    for finding in findings:
        print(finding.render())
    print(f"Static quality gate: {len(files)} tracked files, {len(blocking)} blocking findings, {len(advisory)} advisory findings")
    return 1 if blocking else 0


if __name__ == "__main__":
    raise SystemExit(main())
