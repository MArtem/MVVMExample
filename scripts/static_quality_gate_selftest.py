#!/usr/bin/env python3
"""Regression checks for false-success and false-failure boundaries in the static gate."""

import sys

sys.dont_write_bytecode = True

import re
import unittest
import xml.etree.ElementTree as element_tree
from pathlib import Path

from static_quality_gate import (
    app_build_action_has_required_flags,
    action_enum_positions,
    contains_pbx_object,
    executable_text,
    generic_dispatch_positions,
    is_allowlisted_demo_credential,
    scheme_action_has_target,
    scheme_reference_matches_target,
    source_member_paths,
    swift_method_body,
    test_plan_matches_target,
)


class StaticQualityGateSelfTests(unittest.TestCase):
    def test_empty_xcode_section_is_not_a_dependency(self) -> None:
        self.assertFalse(contains_pbx_object("/* Begin XCLocalSwiftPackageReference section */", "XCLocalSwiftPackageReference"))
        self.assertTrue(contains_pbx_object("object = { isa = XCLocalSwiftPackageReference; };", "XCLocalSwiftPackageReference"))

    def test_comments_cannot_trigger_domain_dependency_rule(self) -> None:
        source = "// URLSession belongs to Infrastructure\n/* ProductDTO is transport-only */\nimport Foundation\n"
        cleaned = executable_text(source)
        self.assertFalse(re.search(r"\bURLSession\b|\b(?:\w+DTO)\b", cleaned))

    def test_demo_credential_allowlist_requires_literal_boundaries(self) -> None:
        self.assertTrue(is_allowlisted_demo_credential("dev-access-demo"))
        self.assertTrue(is_allowlisted_demo_credential("fixture-not-a-secret"))
        self.assertFalse(is_allowlisted_demo_credential("real-dev-access-secret"))
        self.assertFalse(is_allowlisted_demo_credential("real-secret-not-a-secret-suffix"))

    def test_source_membership_resolves_file_reference_paths(self) -> None:
        project = """\
\trootObject = A0 /* Project object */;
\t\tA0 /* Project object */ = {
\t\t\tisa = PBXProject;
\t\t\tmainGroup = A1 /* Root */;
\t\t\ttargets = ( B0 /* MVVMExample */, );
\t\t};
\t\tA1 /* Root */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\tA2 /* MVVMExample */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t};
\t\tA2 /* MVVMExample */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\tA3 /* First */,
\t\t\t\tA4 /* Second */,
\t\t\t);
\t\t\tpath = MVVMExample;
\t\t\tsourceTree = "<group>";
\t\t};
\t\tA3 /* First */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\tPF0001 /* Duplicate.swift */,
\t\t\t);
\t\t\tpath = First;
\t\t\tsourceTree = "<group>";
\t\t};
\t\tA4 /* Second */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\tF2 /* Duplicate.swift */,
\t\t\t);
\t\t\tpath = Second;
\t\t\tsourceTree = "<group>";
\t\t};
\t\tPF0001 /* Duplicate.swift */ = {isa = PBXFileReference; path = Duplicate.swift; sourceTree = "<group>"; };
\t\tF2 /* Duplicate.swift */ = {
\t\t\tisa = PBXFileReference;
\t\t\tpath = Duplicate.swift;
\t\t\tsourceTree = "<group>";
\t\t};
\t\tB0 /* MVVMExample */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildPhases = ( B2 /* Sources */, );
\t\t\tname = MVVMExample;
\t\t};
\t\tB2 /* Sources */ = {
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tfiles = ( C3 /* Included.swift in Sources */, );
\t\t};
\t\tC3 /* Duplicate.swift in Sources */ = {isa = PBXBuildFile; fileRef = PF0001 /* Duplicate.swift */; };
"""
        self.assertEqual(source_member_paths(project, "MVVMExample"), {Path("MVVMExample/First/Duplicate.swift")})

    def test_receipt_guard_is_read_from_the_mutating_method(self) -> None:
        source = """
        func clear(_ receipt: Receipt) { delete(key: receipt.key) }
        func markFailure(_ receipt: Receipt) {
            guard mutation.payloadData == receipt.payloadData else { return }
        }
        """
        self.assertNotIn("payloadData == receipt.payloadData", swift_method_body(source, "clear") or "")
        self.assertIn("payloadData == receipt.payloadData", swift_method_body(source, "markFailure") or "")

    def test_generic_send_detection_does_not_depend_on_parameter_spelling(self) -> None:
        source = "func send(action: LoginIntent) {}\nfunc dispatch(_ intent: LoginIntent) {}\nfunc sendAnalytics() {}"
        self.assertEqual(len(generic_dispatch_positions(source)), 2)

    def test_action_enum_detection_includes_the_bare_action_name(self) -> None:
        source = "enum Action {}\nenum LoginAction {}\nenum Actionable {}"
        self.assertEqual(len(action_enum_positions(source)), 2)

    def test_scheme_reference_requires_current_target_identity(self) -> None:
        targets = {"A1": "MVVMExample"}
        valid = element_tree.fromstring('<BuildableReference BlueprintIdentifier="A1" BlueprintName="MVVMExample" ReferencedContainer="container:MVVMExample.xcodeproj" />')
        stale = element_tree.fromstring('<BuildableReference BlueprintIdentifier="A0" BlueprintName="MVVMExample" ReferencedContainer="container:MVVMExample.xcodeproj" />')
        self.assertTrue(scheme_reference_matches_target(valid, targets))
        self.assertFalse(scheme_reference_matches_target(stale, targets))

    def test_scheme_action_requires_its_own_target_reference(self) -> None:
        scheme = element_tree.fromstring('''
            <Scheme><BuildAction><BuildActionEntries><BuildActionEntry>
            <BuildableReference BlueprintIdentifier="A1" BlueprintName="MVVMExample" ReferencedContainer="container:MVVMExample.xcodeproj" />
            </BuildActionEntry></BuildActionEntries></BuildAction></Scheme>
        ''')
        targets = {"A1": "MVVMExample"}
        self.assertTrue(scheme_action_has_target(scheme, ".//BuildAction/BuildActionEntries/BuildActionEntry/BuildableReference", "A1", targets))
        self.assertFalse(scheme_action_has_target(scheme, ".//LaunchAction/BuildableProductRunnable/BuildableReference", "A1", targets))

    def test_app_build_action_requires_every_build_flag(self) -> None:
        valid = element_tree.fromstring('''
            <Scheme><BuildAction><BuildActionEntries><BuildActionEntry
            buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES"
            buildForArchiving="YES" buildForAnalyzing="YES"><BuildableReference
            BlueprintIdentifier="A1" BlueprintName="MVVMExample" ReferencedContainer="container:MVVMExample.xcodeproj" />
            </BuildActionEntry></BuildActionEntries></BuildAction></Scheme>
        ''')
        invalid = element_tree.fromstring(element_tree.tostring(valid, encoding="unicode").replace('buildForRunning="YES"', 'buildForRunning="NO"'))
        targets = {"A1": "MVVMExample"}
        self.assertTrue(app_build_action_has_required_flags(valid, "A1", targets))
        self.assertFalse(app_build_action_has_required_flags(invalid, "A1", targets))

    def test_test_plan_requires_boolean_enabled_flags(self) -> None:
        valid = '{"version": 1, "defaultOptions": {"targetForVariableExpansion": {"containerPath": "container:MVVMExample.xcodeproj", "identifier": "APP", "name": "MVVMExample"}}, "testTargets": [{"enabled": true, "target": {"containerPath": "container:MVVMExample.xcodeproj", "identifier": "A1", "name": "MVVMExampleTests"}}]}'
        invalid = valid.replace('"enabled": true', '"enabled": "true"')
        stale_expansion_target = valid.replace('"identifier": "APP"', '"identifier": "STALE"')
        self.assertTrue(test_plan_matches_target(valid, "MVVMExampleTests", "A1", "APP"))
        self.assertFalse(test_plan_matches_target(invalid, "MVVMExampleTests", "A1", "APP"))
        self.assertFalse(test_plan_matches_target(stale_expansion_target, "MVVMExampleTests", "A1", "APP"))


if __name__ == "__main__":
    unittest.main()
