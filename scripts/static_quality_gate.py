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
TEST_ROOTS = {
    "MVVMExampleTests": Path("MVVMExampleTests"),
    "MVVMExampleUITests": Path("MVVMExampleUITests"),
}
PROJECT = Path("MVVMExample.xcodeproj/project.pbxproj")
SCHEME = Path("MVVMExample.xcodeproj/xcshareddata/xcschemes/MVVMExample.xcscheme")
TEST_PLANS = {
    Path("MVVMExample.xctestplan"): "MVVMExampleTests",
    Path("MVVMExampleUI.xctestplan"): "MVVMExampleUITests",
}
TARGET_BUNDLE_IDENTIFIERS = {
    "MVVMExample": "com.example.MVVMExample",
    "MVVMExampleTests": "com.example.MVVMExampleTests",
    "MVVMExampleUITests": "com.example.MVVMExampleUITests",
}
TARGET_PRODUCT_CONTRACTS = {
    "MVVMExample": ("com.apple.product-type.application", "MVVMExample.app", "wrapper.application"),
    "MVVMExampleTests": ("com.apple.product-type.bundle.unit-test", "MVVMExampleTests.xctest", "wrapper.cfbundle"),
    "MVVMExampleUITests": ("com.apple.product-type.bundle.ui-testing", "MVVMExampleUITests.xctest", "wrapper.cfbundle"),
}
MAX_TRACKED_FILE_BYTES = 5 * 1024 * 1024
MAX_TEXT_SCAN_BYTES = 2 * 1024 * 1024
FORBIDDEN_COMPONENT_NAMES = frozenset({
    ".build", ".cache", ".swiftpm", "build", "coverage", "deriveddata", "dist",
    "node_modules", "temp", "tmp", "xcuserdata",
})
FORBIDDEN_COMPONENT_SUFFIXES = (".app", ".dsym", ".dsym.zip", ".ipa", ".result", ".xcarchive", ".xcresult")
FORBIDDEN_CREDENTIAL_NAMES = frozenset({".env", "googleservice-info.plist"})
FORBIDDEN_CREDENTIAL_SUFFIXES = (".cer", ".key", ".mobileprovision", ".p12", ".p8", ".provisionprofile", ".xcconfig.local")
PBX_IDENTIFIER = r"[A-Za-z0-9]+"


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


def git_files(*arguments: str) -> list[Path]:
    result = subprocess.run(
        ["git", "-C", str(ROOT), "ls-files", "-z", *arguments],
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError("git ls-files failed; the static gate requires a Git worktree")
    return [Path(item.decode("utf-8")) for item in result.stdout.split(b"\0") if item]


def cached_files() -> list[Path]:
    return git_files("--cached")


def scanned_files() -> list[Path]:
    return git_files("--cached", "--others", "--exclude-standard")


def worktree_changed_files() -> list[Path]:
    result = subprocess.run(
        ["git", "-C", str(ROOT), "diff", "--name-only", "-z"],
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError("git diff failed; the static gate requires a Git worktree")
    changed = [Path(item.decode("utf-8")) for item in result.stdout.split(b"\0") if item]
    return list(set(changed) | set(git_files("--others", "--exclude-standard")))


def line_number(text: str, position: int) -> int:
    return text.count("\n", 0, position) + 1


def text_at(path: Path) -> str | None:
    absolute = ROOT / path
    if absolute.is_symlink():
        return None
    try:
        if absolute.stat().st_size > MAX_TEXT_SCAN_BYTES:
            return None
        return absolute.read_bytes().decode("utf-8", errors="replace")
    except OSError:
        return None


def index_text_at(path: Path) -> str | None:
    result = subprocess.run(
        ["git", "-C", str(ROOT), "show", f":{path.as_posix()}"],
        capture_output=True,
        check=False,
    )
    if result.returncode != 0 or len(result.stdout) > MAX_TEXT_SCAN_BYTES:
        return None
    return result.stdout.decode("utf-8", errors="replace")


def index_blob_sizes(paths: list[Path]) -> dict[Path, int]:
    specifications = b"".join(f":{path.as_posix()}\n".encode("utf-8") for path in paths)
    sizes = subprocess.run(
        ["git", "-C", str(ROOT), "cat-file", "--batch-check=%(objecttype) %(objectsize)"],
        input=specifications,
        capture_output=True,
        check=False,
    )
    if sizes.returncode != 0:
        raise RuntimeError("git cat-file failed while checking staged blob sizes")
    headers = sizes.stdout.splitlines()
    if len(headers) != len(paths):
        raise RuntimeError("git cat-file returned an incomplete staged blob size batch")
    sizes_by_path: dict[Path, int] = {}
    for path, header in zip(paths, headers):
        fields = header.split()
        if len(fields) == 2 and fields[0] == b"blob":
            sizes_by_path[path] = int(fields[1])
    return sizes_by_path


def index_texts(paths: list[Path]) -> list[tuple[Path, str]]:
    small_paths = [path for path, size in index_blob_sizes(paths).items() if size <= MAX_TEXT_SCAN_BYTES]
    result = subprocess.run(
        ["git", "-C", str(ROOT), "cat-file", "--batch"],
        input=b"".join(f":{path.as_posix()}\n".encode("utf-8") for path in small_paths),
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError("git cat-file failed while reading staged blobs")
    output = result.stdout
    offset = 0
    texts: list[tuple[Path, str]] = []
    for path in small_paths:
        newline = output.find(b"\n", offset)
        if newline < 0:
            raise RuntimeError("git cat-file returned a truncated batch header")
        header = output[offset:newline].split()
        offset = newline + 1
        if len(header) != 3:
            continue
        size = int(header[2])
        blob = output[offset:offset + size]
        offset += size + 1
        if header[1] == b"blob" and len(blob) <= MAX_TEXT_SCAN_BYTES:
            texts.append((path, blob.decode("utf-8", errors="replace")))
    return texts


def executable_text(text: str) -> str:
    """Remove comments before source-pattern checks to avoid documentation false positives."""
    def blank(match: re.Match[str]) -> str:
        return "".join("\n" if character == "\n" else " " for character in match.group(0))

    without_blocks = re.sub(r"/\*.*?\*/", blank, text, flags=re.DOTALL)
    return re.sub(r"//[^\n]*", blank, without_blocks)


def swift_method_body(source: str, method: str) -> str | None:
    match = re.search(rf"\bfunc\s+{re.escape(method)}\s*\(", source)
    if match is None:
        return None
    opening = source.find("{", match.end())
    if opening < 0:
        return None
    depth = 1
    for position, character in enumerate(source[opening + 1:], start=opening + 1):
        if character == "{":
            depth += 1
        elif character == "}":
            depth -= 1
            if depth == 0:
                return source[opening + 1:position]
    return None


def generic_dispatch_positions(source: str) -> list[int]:
    return [match.start() for match in re.finditer(r"\bfunc\s+(?:send|dispatch)\s*\(", source)]


def action_enum_positions(source: str) -> list[int]:
    return [match.start() for match in re.finditer(r"\benum\s+\w*Action\b", source)]


def contains_pbx_object(project_text: str, isa: str) -> bool:
    return f"isa = {isa};" in project_text


def pbx_object_body(project_text: str, identifier: str) -> str | None:
    match = re.search(
        rf"(?m)^\t\t{re.escape(identifier)}(?: /\* .*? \*/)? = \{{",
        project_text,
    )
    if match is None:
        return None

    depth = 1
    for position, character in enumerate(project_text[match.end():], start=match.end()):
        if character == "{":
            depth += 1
        elif character == "}":
            depth -= 1
            if depth == 0:
                return project_text[match.end():position]
    return None


def native_target(project_text: str, target_name: str) -> tuple[str, str] | None:
    match = re.search(
        rf"(?ms)^\t\t({PBX_IDENTIFIER}) /\* {re.escape(target_name)} \*/ = \{{\n\t\t\tisa = PBXNativeTarget;(?P<body>.*?)^\t\t\}};",
        project_text,
    )
    return (match.group(1), match.group("body")) if match and match.group(1) in project_target_identifiers(project_text) else None


def native_targets(project_text: str) -> dict[str, str] | None:
    targets: dict[str, str] = {}
    for match in re.finditer(
        rf"(?ms)^\t\t({PBX_IDENTIFIER}) /\* [^\n]*? \*/ = \{{\n\t\t\tisa = PBXNativeTarget;(?P<body>.*?)^\t\t\}};",
        project_text,
    ):
        name = pbx_value(match.group("body"), "name")
        if name is None or match.group(1) in targets or match.group(1) not in project_target_identifiers(project_text):
            return None
        targets[match.group(1)] = name
    return targets or None


def scheme_reference_matches_target(reference: element_tree.Element, targets: dict[str, str]) -> bool:
    identifier = reference.attrib.get("BlueprintIdentifier")
    return (
        identifier is not None
        and targets.get(identifier) == reference.attrib.get("BlueprintName")
        and reference.attrib.get("ReferencedContainer") == "container:MVVMExample.xcodeproj"
    )


def scheme_action_has_target(scheme_root: element_tree.Element, path: str, target_identifier: str, targets: dict[str, str]) -> bool:
    return any(
        reference.attrib.get("BlueprintIdentifier") == target_identifier
        and scheme_reference_matches_target(reference, targets)
        for reference in scheme_root.findall(path)
    )


def app_build_action_has_required_flags(scheme_root: element_tree.Element, app_target_identifier: str, targets: dict[str, str]) -> bool:
    required_flags = ("buildForTesting", "buildForRunning", "buildForProfiling", "buildForArchiving", "buildForAnalyzing")
    for entry in scheme_root.findall(".//BuildAction/BuildActionEntries/BuildActionEntry"):
        reference = entry.find("./BuildableReference")
        if (
            reference is not None
            and reference.attrib.get("BlueprintIdentifier") == app_target_identifier
            and scheme_reference_matches_target(reference, targets)
        ):
            return all(entry.attrib.get(flag) == "YES" for flag in required_flags)
    return False


def pbx_value(body: str, key: str) -> str | None:
    match = re.search(rf"\b{re.escape(key)} = (.*?);", body, re.DOTALL)
    return match.group(1).strip().strip('"') if match else None


def project_object(project_text: str) -> tuple[str, str] | None:
    root = re.search(rf"(?m)^\trootObject = ({PBX_IDENTIFIER}) /\* Project object \*/;", project_text)
    body = pbx_object_body(project_text, root.group(1)) if root else None
    return (root.group(1), body) if body is not None and "isa = PBXProject;" in body else None


def project_target_identifiers(project_text: str) -> set[str]:
    project = project_object(project_text)
    targets = re.search(r"targets = \((?P<targets>.*?)\);", project[1], re.DOTALL) if project else None
    return set(re.findall(rf"({PBX_IDENTIFIER}) /\*", targets.group("targets"))) if targets else set()


def pbx_identifier(value: str | None) -> str | None:
    return value.split(" ", 1)[0] if value else None


def test_plan_matches_target(text: str, target_name: str, target_identifier: str, app_target_identifier: str) -> bool:
    payload = json.loads(text)
    targets = payload["testTargets"]
    if not isinstance(targets, list) or any(not isinstance(item.get("enabled"), bool) for item in targets if isinstance(item, dict)):
        return False
    if any(not isinstance(item, dict) for item in targets):
        return False
    enabled_targets = [item["target"] for item in targets if item["enabled"]]
    expected_target = {
        "containerPath": "container:MVVMExample.xcodeproj",
        "identifier": target_identifier,
        "name": target_name,
    }
    expected_expansion_target = {
        "containerPath": "container:MVVMExample.xcodeproj",
        "identifier": app_target_identifier,
        "name": "MVVMExample",
    }
    return (
        enabled_targets == [expected_target]
        and payload.get("defaultOptions", {}).get("targetForVariableExpansion") == expected_expansion_target
        and payload.get("version") == 1
    )


def forbidden_credential_artifact(path: Path) -> bool:
    filename = path.name.casefold()
    return filename in FORBIDDEN_CREDENTIAL_NAMES or filename.endswith(FORBIDDEN_CREDENTIAL_SUFFIXES)


def file_reference_paths(project_text: str) -> dict[str, Path] | None:
    project = project_object(project_text)
    if project is None:
        return None
    main_group = pbx_value(project[1], "mainGroup")
    if main_group is None:
        return None
    main_group = main_group.split(" ", 1)[0]
    result: dict[str, Path] = {}
    visited: set[str] = set()

    def visit(group_identifier: str, parent_path: Path) -> bool:
        if group_identifier in visited:
            return False
        visited.add(group_identifier)
        group_body = pbx_object_body(project_text, group_identifier)
        if group_body is None or "isa = PBXGroup;" not in group_body:
            return False
        group_path = pbx_value(group_body, "path")
        current_path = parent_path / group_path if group_path else parent_path
        children = re.search(r"children = \((?P<children>.*?)\);", group_body, re.DOTALL)
        if children is None:
            return False
        for child_identifier in re.findall(rf"({PBX_IDENTIFIER}) /\*", children.group("children")):
            child_body = pbx_object_body(project_text, child_identifier)
            if child_body is None:
                return False
            if "isa = PBXGroup;" in child_body:
                if not visit(child_identifier, current_path):
                    return False
            elif "isa = PBXFileReference;" in child_body:
                path = pbx_value(child_body, "path")
                source_tree = pbx_value(child_body, "sourceTree")
                if path and source_tree == "<group>":
                    result[child_identifier] = current_path / path
        return True

    return result if visit(main_group, Path()) else None


def target_phase_paths(project_text: str, target_name: str, phase_name: str, phase_type: str) -> set[Path] | None:
    target = native_target(project_text, target_name)
    if target is None:
        return None
    _, target_body = target
    phase_ids = re.findall(rf"({PBX_IDENTIFIER}) /\* {re.escape(phase_name)} \*/", target_body)
    if len(phase_ids) != 1:
        return None
    phase_body = pbx_object_body(project_text, phase_ids[0])
    if phase_body is None or f"isa = {phase_type};" not in phase_body:
        return None
    references = file_reference_paths(project_text)
    if references is None:
        return None
    paths: set[Path] = set()
    for build_identifier in re.findall(rf"({PBX_IDENTIFIER}) /\* [^*]+ in {re.escape(phase_name)} \*/", phase_body):
        build_body = pbx_object_body(project_text, build_identifier)
        file_reference = pbx_value(build_body, "fileRef") if build_body else None
        if file_reference is None:
            return None
        file_reference = file_reference.split(" ", 1)[0]
        path = references.get(file_reference)
        if path is None:
            return None
        paths.add(path)
    return paths


def source_member_paths(project_text: str, target_name: str) -> set[Path] | None:
    return target_phase_paths(project_text, target_name, "Sources", "PBXSourcesBuildPhase")


def resource_member_paths(project_text: str, target_name: str) -> set[Path] | None:
    return target_phase_paths(project_text, target_name, "Resources", "PBXResourcesBuildPhase")


def build_settings_for_target(project_text: str, target_name: str) -> dict[str, dict[str, str]] | None:
    target = native_target(project_text, target_name)
    if target is None:
        return None
    _, target_body = target
    configuration_list = re.search(rf"buildConfigurationList = ({PBX_IDENTIFIER})", target_body)
    if configuration_list is None:
        return None
    list_body = pbx_object_body(project_text, configuration_list.group(1))
    if list_body is None or "isa = XCConfigurationList;" not in list_body:
        return None
    configurations = re.findall(rf"({PBX_IDENTIFIER}) /\* (Debug|Release) \*/", list_body)
    if len(configurations) != 2 or len({identifier for identifier, _ in configurations}) != 2 or {name for _, name in configurations} != {"Debug", "Release"}:
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


def check_repository_hygiene(files: list[Path], cached: list[Path], worktree_changed: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    cached_sizes = index_blob_sizes(cached)
    cached_paths = set(cached)
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
        if path in cached_paths:
            size = cached_sizes.get(path)
            if size is None:
                findings.append(Finding("FAIL", "QC.REPOSITORY.UNREADABLE_STAGED_FILE", path_string, "staged path cannot be read as a regular blob"))
                continue
        else:
            try:
                size = absolute.stat().st_size
            except OSError:
                findings.append(Finding("FAIL", "QC.REPOSITORY.MISSING_WORKTREE_FILE", path_string, "untracked path cannot be read"))
                continue
        if size > MAX_TRACKED_FILE_BYTES:
            findings.append(Finding("FAIL", "QC.REPOSITORY.LARGE_FILE", path_string, f"staged or untracked file exceeds {MAX_TRACKED_FILE_BYTES // (1024 * 1024)} MiB"))

        components = tuple(component.casefold() for component in path.parts)
        if any(component in FORBIDDEN_COMPONENT_NAMES or component.endswith(FORBIDDEN_COMPONENT_SUFFIXES) for component in components):
            findings.append(Finding("FAIL", "QC.REPOSITORY.GENERATED_ARTIFACT", path_string, "generated build or release artifact is tracked"))
        if forbidden_credential_artifact(path):
            findings.append(Finding("FAIL", "QC.SECRET.CREDENTIAL_ARTIFACT", path_string, "local credential artifact must not be tracked"))

    for path in worktree_changed:
        absolute = ROOT / path
        try:
            if absolute.stat().st_size > MAX_TRACKED_FILE_BYTES:
                findings.append(Finding("FAIL", "QC.REPOSITORY.LARGE_FILE", path.as_posix(), f"staged or untracked file exceeds {MAX_TRACKED_FILE_BYTES // (1024 * 1024)} MiB"))
        except OSError:
            pass

    text_inputs: list[tuple[Path, str]] = []
    text_inputs.extend(index_texts(cached))
    for path in worktree_changed:
        text = text_at(path)
        if text is not None:
            text_inputs.append((path, text))
    seen_secret_findings: set[tuple[str, str, int]] = set()
    for path, text in text_inputs:
        for rule, pattern in secret_patterns:
            for match in pattern.finditer(text):
                literal = match.group(0)
                quoted_value = re.search(r"[\"']([^\"']+)[\"']\s*$", literal)
                if rule == "QC.SECRET.HARDCODED_CREDENTIAL" and quoted_value and is_allowlisted_demo_credential(quoted_value.group(1)):
                    continue
                key = (rule, path.as_posix(), line_number(text, match.start()))
                if key not in seen_secret_findings:
                    seen_secret_findings.add(key)
                    findings.append(Finding("FAIL", rule, path.as_posix(), "possible credential in staged or worktree source", key[2]))
    return findings


def check_project_contract(files: list[Path], cached: list[Path], worktree_changed: list[Path], project_override: str | None = None, scheme_override: str | None = None) -> list[Finding]:
    findings: list[Finding] = []
    tracked = set(cached)
    required = {PROJECT, SCHEME, *TEST_PLANS}
    missing_required = required - tracked
    for path in sorted(required):
        if path in missing_required:
            findings.append(Finding("FAIL", "QC.XCODE.REQUIRED_FILE", path.as_posix(), "required Xcode contract file is not tracked"))
            continue
        if (ROOT / path).is_symlink():
            findings.append(Finding("FAIL", "QC.XCODE.SYMLINK", path.as_posix(), "Xcode contract files must not be symlinks"))

    project_text = project_override if project_override is not None else index_text_at(PROJECT)
    if project_text is None:
        findings.append(Finding("FAIL", "QC.XCODE.PROJECT_UNREADABLE", PROJECT.as_posix(), "staged Xcode project cannot be read"))
        return findings
    lint = subprocess.run(["plutil", "-lint", "-"], input=project_text, capture_output=True, text=True, check=False)
    if lint.returncode != 0:
        findings.append(Finding("FAIL", "QC.XCODE.PROJECT_SYNTAX", PROJECT.as_posix(), lint.stderr.strip() or lint.stdout.strip() or "plutil rejected project.pbxproj"))
        return findings

    for target_name, expected_bundle_identifier in TARGET_BUNDLE_IDENTIFIERS.items():
        configurations = build_settings_for_target(project_text, target_name)
        if configurations is None:
            findings.append(Finding("FAIL", "QC.XCODE.BUILD_CONTRACT", PROJECT.as_posix(), f"could not parse Debug and Release settings for {target_name}"))
            continue
        for configuration_name, settings in configurations.items():
            for key, expected_value in (
                ("IPHONEOS_DEPLOYMENT_TARGET", "17.0"),
                ("SWIFT_VERSION", "6.0"),
                ("SWIFT_STRICT_CONCURRENCY", "complete"),
                ("PRODUCT_BUNDLE_IDENTIFIER", expected_bundle_identifier),
            ):
                if settings.get(key) != expected_value:
                    findings.append(Finding("FAIL", "QC.XCODE.BUILD_CONTRACT", PROJECT.as_posix(), f"{target_name} {configuration_name} must set {key} = {expected_value}"))
        target = native_target(project_text, target_name)
        contract = TARGET_PRODUCT_CONTRACTS[target_name]
        product_reference = pbx_object_body(project_text, pbx_identifier(pbx_value(target[1], "productReference")) or "") if target else None
        if (
            target is None
            or pbx_value(target[1], "productType") != contract[0]
            or product_reference is None
            or "isa = PBXFileReference;" not in product_reference
            or pbx_value(product_reference, "path") != contract[1]
            or pbx_value(product_reference, "explicitFileType") != contract[2]
            or pbx_value(product_reference, "sourceTree") != "BUILT_PRODUCTS_DIR"
        ):
            findings.append(Finding("FAIL", "QC.XCODE.TARGET_PRODUCT_CONTRACT", PROJECT.as_posix(), f"{target_name} must retain its native product type and product reference"))
    for forbidden in ("PBXShellScriptBuildPhase", "XCRemoteSwiftPackageReference", "XCLocalSwiftPackageReference"):
        if contains_pbx_object(project_text, forbidden):
            findings.append(Finding("FAIL", "QC.XCODE.UNAPPROVED_BUILD_EDGE", PROJECT.as_posix(), f"unexpected build-graph edge: {forbidden}"))

    source_members = source_member_paths(project_text, "MVVMExample")
    if source_members is None:
        findings.append(Finding("FAIL", "QC.XCODE.SOURCES_PHASE", PROJECT.as_posix(), "could not parse the app target Sources build phase"))
        source_members = set()
    for path in files:
        if path.suffix == ".swift" and path.is_relative_to(APP_ROOT) and path not in source_members:
            findings.append(Finding("FAIL", "QC.XCODE.SOURCE_MEMBERSHIP", path.as_posix(), "application Swift file is not in the app target Sources build phase"))
    expected_app_sources = {path for path in files if path.suffix == ".swift" and path.is_relative_to(APP_ROOT)}
    for path in source_members - expected_app_sources:
        findings.append(Finding("FAIL", "QC.XCODE.SOURCE_MEMBERSHIP", path.as_posix(), "app Sources build phase contains an unexpected or stale source"))
    for target_name, root in TEST_ROOTS.items():
        source_members = source_member_paths(project_text, target_name)
        if source_members is None:
            findings.append(Finding("FAIL", "QC.XCODE.SOURCES_PHASE", PROJECT.as_posix(), f"could not parse the {target_name} Sources build phase"))
            source_members = set()
        for path in files:
            if path.suffix == ".swift" and path.is_relative_to(root) and path not in source_members:
                findings.append(Finding("FAIL", "QC.XCODE.SOURCE_MEMBERSHIP", path.as_posix(), f"test source is not in the {target_name} Sources build phase"))
        expected_test_sources = {path for path in files if path.suffix == ".swift" and path.is_relative_to(root)}
        for path in source_members - expected_test_sources:
            findings.append(Finding("FAIL", "QC.XCODE.SOURCE_MEMBERSHIP", path.as_posix(), f"{target_name} Sources build phase contains an unexpected or stale source"))

    resources = resource_member_paths(project_text, "MVVMExample")
    reference_paths = file_reference_paths(project_text)
    if resources is None or reference_paths is None:
        findings.append(Finding("FAIL", "QC.XCODE.RESOURCES_PHASE", PROJECT.as_posix(), "could not parse the app target Resources build phase"))
    else:
        expected_resources: set[Path] = set()
        for path in files:
            if path.is_relative_to(Path("MVVMExample")) and path.suffix == ".xcstrings":
                expected_resources.add(path)
            elif path.is_relative_to(Path("MVVMExample")):
                index = next((index for index, component in enumerate(path.parts) if component.endswith(".xcassets")), None)
                if index is not None:
                    expected_resources.add(Path(*path.parts[:index + 1]))
        for path in expected_resources - resources:
            findings.append(Finding("FAIL", "QC.XCODE.RESOURCE_MEMBERSHIP", path.as_posix(), "tracked app catalog is not in the Resources build phase"))
        for path in resources - expected_resources:
            if path.suffix in {".xcstrings", ".xcassets"}:
                findings.append(Finding("FAIL", "QC.XCODE.RESOURCE_MEMBERSHIP", path.as_posix(), "Resources build phase contains an unexpected or stale catalog"))

    app_target = native_target(project_text, "MVVMExample")
    app_identifier = app_target[0] if app_target else None
    active_project = project_object(project_text)
    project_identifier = active_project[0] if active_project else None
    for target_name in TEST_ROOTS:
        target = native_target(project_text, target_name)
        target_body = target[1] if target else ""
        dependency_ids = re.findall(rf"({PBX_IDENTIFIER}) /\* PBXTargetDependency \*/", target_body)
        valid = len(dependency_ids) == 1 and app_identifier is not None
        dependency_body = pbx_object_body(project_text, dependency_ids[0]) if valid else None
        proxy_body = pbx_object_body(project_text, pbx_identifier(pbx_value(dependency_body, "targetProxy")) or "") if dependency_body else None
        if (
            not valid
            or dependency_body is None
            or pbx_value(dependency_body, "name") != "MVVMExample"
            or pbx_identifier(pbx_value(dependency_body, "target")) != app_identifier
            or proxy_body is None
            or "isa = PBXContainerItemProxy;" not in proxy_body
            or pbx_identifier(pbx_value(proxy_body, "containerPortal")) != project_identifier
            or pbx_value(proxy_body, "proxyType") != "1"
            or pbx_identifier(pbx_value(proxy_body, "remoteGlobalIDString")) != app_identifier
            or pbx_value(proxy_body, "remoteInfo") != "MVVMExample"
        ):
            findings.append(Finding("FAIL", "QC.XCODE.TEST_TARGET_DEPENDENCY", PROJECT.as_posix(), f"{target_name} must depend on the current MVVMExample target through its proxy"))

    try:
        scheme_text = scheme_override if scheme_override is not None else index_text_at(SCHEME)
        if scheme_text is None:
            raise ValueError("staged shared scheme cannot be read")
        scheme_root = element_tree.fromstring(scheme_text)
        references = {node.attrib.get("reference") for node in scheme_root.findall(".//TestPlanReference")}
        expected = {f"container:{path.name}" for path in TEST_PLANS}
        if not expected.issubset(references):
            findings.append(Finding("FAIL", "QC.XCODE.SCHEME_TEST_PLANS", SCHEME.as_posix(), "shared scheme does not reference both required test plans"))
        targets = native_targets(project_text)
        if targets is None:
            raise ValueError("could not parse native targets")
        for reference in scheme_root.findall(".//BuildableReference"):
            if not scheme_reference_matches_target(reference, targets):
                findings.append(Finding("FAIL", "QC.XCODE.SCHEME_TARGET_CONTRACT", SCHEME.as_posix(), "BuildableReference must identify a current native target in this project"))
                break
        required_scheme_references = (
            (".//BuildAction/BuildActionEntries/BuildActionEntry/BuildableReference", "MVVMExample"),
            (".//TestAction/Testables/TestableReference/BuildableReference", "MVVMExampleTests"),
            (".//LaunchAction/BuildableProductRunnable/BuildableReference", "MVVMExample"),
            (".//ProfileAction/BuildableProductRunnable/BuildableReference", "MVVMExample"),
        )
        for action_path, target_name in required_scheme_references:
            target = native_target(project_text, target_name)
            if target is None or not scheme_action_has_target(scheme_root, action_path, target[0], targets):
                findings.append(Finding("FAIL", "QC.XCODE.SCHEME_ACTION_CONTRACT", SCHEME.as_posix(), f"required {target_name} reference is missing from its scheme action"))
        if app_target is None or not app_build_action_has_required_flags(scheme_root, app_target[0], targets):
            findings.append(Finding("FAIL", "QC.XCODE.SCHEME_BUILD_ACTION", SCHEME.as_posix(), "the app BuildActionEntry must enable all required build actions"))
        required_action_configurations = {
            "TestAction": "Debug",
            "LaunchAction": "Debug",
            "ProfileAction": "Release",
            "AnalyzeAction": "Debug",
            "ArchiveAction": "Release",
        }
        for action, configuration in required_action_configurations.items():
            if scheme_root.find(f".//{action}") is None or scheme_root.find(f".//{action}").attrib.get("buildConfiguration") != configuration:
                findings.append(Finding("FAIL", "QC.XCODE.SCHEME_CONFIGURATION", SCHEME.as_posix(), f"{action} must use {configuration} configuration"))
    except (OSError, ValueError, element_tree.ParseError):
        findings.append(Finding("FAIL", "QC.XCODE.SCHEME_SYNTAX", SCHEME.as_posix(), "shared scheme is not valid XML"))

    for path, target_name in TEST_PLANS.items():
        try:
            target = native_target(project_text, target_name)
            if target is None:
                raise ValueError("target not found")
            target_identifier, _ = target
            staged_plan = index_text_at(path)
            if staged_plan is None or app_identifier is None or not test_plan_matches_target(staged_plan, target_name, target_identifier, app_identifier):
                raise ValueError("target contract mismatch")
        except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError):
            findings.append(Finding("FAIL", "QC.XCODE.TEST_PLAN_CONTRACT", path.as_posix(), f"must be a version-1 plan for {target_name}"))
    if project_override is None and scheme_override is None:
        worktree_project = text_at(PROJECT) if PROJECT in worktree_changed else project_text
        staged_scheme = index_text_at(SCHEME)
        worktree_scheme = text_at(SCHEME) if SCHEME in worktree_changed else staged_scheme
        if worktree_project is not None and worktree_scheme is not None and (worktree_project != project_text or worktree_scheme != staged_scheme):
            findings += check_project_contract(files, cached, [], worktree_project, worktree_scheme)
        for path, target_name in TEST_PLANS.items():
            if path in worktree_changed:
                worktree_plan = text_at(path)
                target = native_target(worktree_project or project_text, target_name)
                worktree_app_target = native_target(worktree_project or project_text, "MVVMExample")
                if worktree_plan is None or target is None or worktree_app_target is None or not test_plan_matches_target(worktree_plan, target_name, target[0], worktree_app_target[0]):
                    findings.append(Finding("FAIL", "QC.XCODE.TEST_PLAN_CONTRACT", path.as_posix(), f"worktree plan must be a version-1 plan for {target_name}"))
    return findings


def check_resources(files: list[Path], cached: list[Path], worktree_changed: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    resource_paths = [path for path in cached if path.suffix in {".json", ".xcstrings"} and (path.parts[:1] == ("MVVMExample",) or any(component.endswith(".xcassets") for component in path.parts))]
    inputs = index_texts(resource_paths)
    for path in worktree_changed:
        if path.suffix not in {".json", ".xcstrings"}:
            continue
        if not (path.parts[:1] == ("MVVMExample",) or any(component.endswith(".xcassets") for component in path.parts)):
            continue
        text = text_at(path)
        if text is not None:
            inputs.append((path, text))
    for path, text in inputs:
        try:
            payload = json.loads(text)
            if path.suffix == ".xcstrings" and (payload.get("sourceLanguage") != "en" or not isinstance(payload.get("strings"), dict)):
                raise ValueError("catalog shape")
            if any(component.endswith(".xcassets") for component in path.parts) and (
                not isinstance(payload, dict)
                or not isinstance(payload.get("info"), dict)
                or not isinstance(payload["info"].get("author"), str)
                or not isinstance(payload["info"].get("version"), int)
            ):
                raise ValueError("asset catalog shape")
        except (OSError, ValueError, json.JSONDecodeError):
            findings.append(Finding("FAIL", "QC.RESOURCE.JSON_CONTRACT", path.as_posix(), "resource JSON is malformed or has an invalid catalog shape"))
    return findings


def check_app_architecture(files: list[Path], cached: list[Path], worktree_changed: list[Path]) -> list[Finding]:
    findings: list[Finding] = []
    forbidden_patterns = (
        ("QC.PERFORMANCE.SYNC_FILE_LOAD", re.compile(r"Data\s*\(\s*contentsOf\s*:"), "synchronous file load is forbidden in app source"),
        ("QC.PERFORMANCE.TYPE_ERASURE", re.compile(r"\bAnyView\s*\("), "unnecessary SwiftUI type erasure is forbidden"),
    )
    app_files = [path for path in cached if path.suffix == ".swift" and path.is_relative_to(APP_ROOT)]
    source_inputs = index_texts(app_files)
    for path in worktree_changed:
        if path.suffix == ".swift" and path.is_relative_to(APP_ROOT):
            text = text_at(path)
            if text is not None:
                source_inputs.append((path, text))
    for path, text in source_inputs:
        source = executable_text(text)
        for rule, pattern, message in forbidden_patterns:
            for match in pattern.finditer(source):
                findings.append(Finding("FAIL", rule, path.as_posix(), message, line_number(text, match.start())))
        path_string = path.as_posix()
        if "/Presentation/" in path_string or path.name.endswith("ViewModel.swift"):
            for position in generic_dispatch_positions(source):
                findings.append(Finding("FAIL", "QC.MVVM.GENERIC_ACTION_DISPATCH", path_string, "ViewModels must expose explicit intent methods", line_number(text, position)))
            for position in action_enum_positions(source):
                findings.append(Finding("FAIL", "QC.MVVM.ACTION_ENUM", path_string, "action enums require an approved reducer architecture", line_number(text, position)))
        if "/Domain/" in path_string and re.search(r"\bimport\s+SwiftUI\b|\bURLSession\b|\b(?:\w+DTO)\b", source):
            findings.append(Finding("FAIL", "QC.MVVM.DOMAIN_BOUNDARY", path_string, "Domain must not depend on SwiftUI, URLSession, or DTO types"))
        if "/Presentation/" in path_string and re.search(r"\bURLSession\b|\bURLRequest\b|\b(?:URLSession)?APIClient\b|\b(?:URLSession)?NetworkClient\b", source):
            findings.append(Finding("FAIL", "QC.MVVM.PRESENTATION_NETWORKING", path_string, "Presentation must depend on repositories, not transport clients"))
        if any(component in path_string for component in ("/Data/API/", "/Features/Auth/Data/", "/Infrastructure/Networking/", "/Infrastructure/LocalSupport/AppNetworking/")) and "try?" in source:
            findings.append(Finding("FAIL", "QC.NETWORK.SILENCED_FAILURE", path_string, "API boundary must not silence errors with try?"))

    receipt_path = APP_ROOT / "Infrastructure/Persistence/PendingMutationStore.swift"
    interaction_path = APP_ROOT / "Features/News/Domain/ArticleInteractionStore.swift"
    receipt_contract = ROOT / receipt_path
    interaction_contract = ROOT / interaction_path
    receipt_method_contracts = (
        ("clear", r"pendingMutation\s*\(\s*key:\s*receipt\.key\s*\)\?\.payloadData\s*==\s*receipt\.payloadData"),
        ("markAttempt", r"pendingMutation\s*\(\s*key:\s*receipt\.key\s*\).*mutation\.payloadData\s*==\s*receipt\.payloadData"),
        ("markFailure", r"pendingMutation\s*\(\s*key:\s*receipt\.key\s*\).*mutation\.payloadData\s*==\s*receipt\.payloadData"),
    )
    contract_inputs = [(index_text_at(receipt_path), index_text_at(interaction_path))]
    if receipt_path in worktree_changed or interaction_path in worktree_changed:
        contract_inputs.append((text_at(receipt_path), text_at(interaction_path)))
    for receipt_input, interaction_input in contract_inputs:
        receipt_text = executable_text(receipt_input or "")
        interaction_text = executable_text(interaction_input or "")
        for method, guard in receipt_method_contracts:
            body = swift_method_body(receipt_text, method)
            if body is None or re.search(guard, body, re.DOTALL) is None:
                findings.append(Finding("FAIL", "QC.MUTATION.RECEIPT_CONTRACT", receipt_contract.relative_to(ROOT).as_posix(), f"{method} must retain its receipt payload guard"))
        clear_pending_like = swift_method_body(interaction_text, "clearPendingLike")
        if clear_pending_like is None or re.search(r"pendingMutationStore\?\.clear\s*\(\s*receipt\s*\)", clear_pending_like) is None:
            findings.append(Finding("FAIL", "QC.MUTATION.RECEIPT_CONTRACT", interaction_contract.relative_to(ROOT).as_posix(), "clearPendingLike must clear through its receipt"))
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
        files = scanned_files()
        cached = cached_files()
        worktree_changed = worktree_changed_files()
        findings = (
            check_repository_hygiene(files, cached, worktree_changed)
            + check_project_contract(files, cached, worktree_changed)
            + check_resources(files, cached, worktree_changed)
            + check_app_architecture(files, cached, worktree_changed)
            + advisory_findings(files)
        )
    except Exception as error:  # Gate failures must never masquerade as PASS.
        print(f"FAIL QC.GATE.INTERNAL scripts/static_quality_gate.py — {error}")
        return 2

    blocking = [finding for finding in findings if finding.severity == "FAIL"]
    advisory = [finding for finding in findings if finding.severity == "ADVISORY"]
    for finding in findings:
        print(finding.render())
    print(f"Static quality gate: {len(files)} tracked/nonignored files, {len(blocking)} blocking findings, {len(advisory)} advisory findings")
    return 1 if blocking else 0


if __name__ == "__main__":
    raise SystemExit(main())
