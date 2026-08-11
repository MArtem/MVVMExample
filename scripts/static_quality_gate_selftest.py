#!/usr/bin/env python3
"""Regression checks for false-success and false-failure boundaries in the static gate."""

import sys

sys.dont_write_bytecode = True

import re
import unittest
from pathlib import Path

from static_quality_gate import (
    contains_pbx_object,
    executable_text,
    is_allowlisted_demo_credential,
    source_member_paths,
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
\t\tA0 /* Project object */ = {
\t\t\tisa = PBXProject;
\t\t\tmainGroup = A1 /* Root */;
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


if __name__ == "__main__":
    unittest.main()
