# Dependency Policy

## Purpose
Rules for adding, updating, or removing third-party dependencies.

For SwiftPM, plugins, macros, binary targets, XCFrameworks, module/linker behavior, supply-chain inventory, license evidence, and SBOM decisions, load `./docs/knowledge/global/ios/XCODE_BUILD_BINARY_AND_SUPPLY_CHAIN.md`.

## Approval Criteria
Before adding a dependency, review:
- concrete current need
- platform support
- maintenance activity
- license
- security history
- binary size/build time impact
- privacy/data collection behavior
- replaceability/removal plan
- transitive dependencies, executable plugins/macros/scripts, and binary provenance
- privacy manifest, required-reason API, signing, and minimum-platform impact

## Forbidden By Default
- Dependency for trivial code.
- Abandoned or unclear-license package.
- SDK that collects user data without privacy review.
- Large UI framework for a small one-off component.

## Removal Policy
Before an authorized removal, account for public and transitive usage and affected consumers;
define migration and compatibility criteria rather than inferring non-use from direct imports.

## Update Policy
- Review changelog and migration notes.
- Select the affected build/test/QA scope and recommend it to the user. Run
  each check only when separately authorized by the current permission policy;
  otherwise record it as not run with the remaining integration risk.
- Watch for privacy manifest and signing changes.
- Re-check transitive dependency, license, vulnerability, build-tool, and binary compatibility changes.
