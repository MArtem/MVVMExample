#!/usr/bin/env python3
"""Regression checks for false-success and false-failure boundaries in the static gate."""

import sys

sys.dont_write_bytecode = True

import re
import unittest

from static_quality_gate import contains_pbx_object, executable_text


class StaticQualityGateSelfTests(unittest.TestCase):
    def test_empty_xcode_section_is_not_a_dependency(self) -> None:
        self.assertFalse(contains_pbx_object("/* Begin XCLocalSwiftPackageReference section */", "XCLocalSwiftPackageReference"))
        self.assertTrue(contains_pbx_object("object = { isa = XCLocalSwiftPackageReference; };", "XCLocalSwiftPackageReference"))

    def test_comments_cannot_trigger_domain_dependency_rule(self) -> None:
        source = "// URLSession belongs to Infrastructure\n/* ProductDTO is transport-only */\nimport Foundation\n"
        cleaned = executable_text(source)
        self.assertFalse(re.search(r"\bURLSession\b|\b(?:\w+DTO)\b", cleaned))


if __name__ == "__main__":
    unittest.main()
