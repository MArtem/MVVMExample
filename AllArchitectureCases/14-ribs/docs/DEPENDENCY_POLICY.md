# Dependency Policy

## Purpose
Rules for adding, updating, or removing third-party dependencies.

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

## Forbidden By Default
- Dependency for trivial code.
- Abandoned or unclear-license package.
- SDK that collects user data without privacy review.
- Large UI framework for a small one-off component.

## Update Policy
- Review changelog and migration notes.
- Run affected build/test/QA scope.
- Watch for privacy manifest and signing changes.
