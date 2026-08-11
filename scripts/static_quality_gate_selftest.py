#!/usr/bin/env python3
"""Regression checks for false-success and false-failure boundaries in the static gate."""

import sys

sys.dont_write_bytecode = True

import re
import unittest

from static_quality_gate import (
    contains_pbx_object,
    executable_text,
    is_allowlisted_demo_credential,
    source_member_names,
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

    def test_source_membership_uses_the_app_sources_phase(self) -> None:
        project = """\
\t\tA1 /* MVVMExample */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildPhases = ( B2 /* Sources */, );
\t\t\tname = MVVMExample;
\t\t};
\t\tB2 /* Sources */ = {
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tfiles = ( C3 /* Included.swift in Sources */, );
\t\t};
\t\tD4 /* Omitted.swift */ = { isa = PBXFileReference; };
"""
        self.assertEqual(source_member_names(project, "MVVMExample"), {"Included.swift"})


if __name__ == "__main__":
    unittest.main()
