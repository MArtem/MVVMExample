# iOS Testing Strategy

<!-- Rule ID: QC.TEST.PERMISSIONS v1.0 -->

## Purpose
Defines when production iOS work requires unit, integration, UI, manual, relaunch, offline, migration, or performance verification.

This does not override task-local instructions that tests are opt-in. It defines what a production strategy should require when the user opens testing or release-readiness work.

Use `./docs/knowledge/global/ios/TESTING_DEBUGGING_AND_DIAGNOSTICS.md` for Swift Testing/XCTest selection, deterministic test design, doubles, flaky tests, LLDB, sanitizers, memory graph, crash/hang triage, and evidence limits.

## Permission Boundary

Test need and test authority are separate decisions. The assistant may recommend tests while still
being forbidden to create, modify, or execute them.

Track independently:

- test creation: `allow`, `deny`, or `ask`;
- test modification: `allow`, `deny`, or `ask`;
- local execution: `allow`, `deny`, or `ask`;
- GitHub execution: `off` or `manual`;
- UI tests, Simulator/device work, and performance/Instruments work: separate permission states.

Project-mode defaults and the controlling user policy live in
`./docs/UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md`. A denied, unavailable, or unrun test must be
reported with residual risk and must not be replaced by a hidden test-like artifact or false PASS.

`manual` means the user chooses whether and when to trigger the GitHub workflow; it does not
authorize the agent to start it. A selected workflow mode may execute existing tests only when the
current profile permits that test phase. If a requested mode requires tests but permission,
toolchain, runtime, scheme, destination, or test plan is unavailable, report `BLOCKED` or
`NOT_RUN_BY_USER_DECISION` as applicable; do not downgrade silently to a passing build-only run.

Test applicability belongs in the project profile: authoritative schemes/targets, test plans,
destinations, release-critical UI/snapshot suites, migration fixtures, and capabilities that are
truly absent. `NOT_APPLICABLE` requires a validated project fact, not convenience or missing setup.

Apply [USER.VERIFICATION.SCOPE](CURRENT_USER_OVERRIDES.md#verification-and-quality) before
constructing any matrix: omit all iPad and physical-device checks, including actual
VoiceOver sessions, from plans and acceptance gates. Static accessibility analysis and
permitted iPhone Simulator audits remain applicable; omitted evidence is never PASS.

## Test Decision Matrix
### Unit Tests
Use for:
- pure domain logic
- validation rules
- mappers/formatters/parsers
- reducers/state transitions
- date/number/string edge cases
- retry/backoff/idempotency decisions

### Integration Tests
Use for:
- repository + persistence
- API client + DTO mapping with mocked transport
- sync/outbox/conflict flows
- file import/export and media ownership logic
- auth/session refresh policy

### UI Tests
Use for:
- login/signup/logout smoke
- critical navigation paths
- composer/form submission
- destructive confirmations
- permission prompts where practical
- accessibility identifiers on critical flows

### Manual iPhone Simulator QA
Use for:
- gestures, scrolling, animations, sheets
- visual polish
- keyboard/focus behavior
- device-size-specific layouts
- share extension and system integration flows
- iPhone adaptive layouts, orientation, keyboard and supported Simulator system integration

### Instruments / Performance Verification
Use for:
- feed/list scrolling
- media-heavy screens
- launch performance
- memory growth/leaks
- repeated navigation
- main-thread stalls

### Relaunch / Migration Verification
Use for:
- persistence changes
- schema changes
- app group shared data
- token/session storage
- settings/preferences
- draft/offline data

### Network/Offline Verification
Use for:
- API-backed screens
- sync flows
- login/session refresh
- upload/download
- retry and partial failure

## Required Production Test Report
For production-ready claims, state:
1. Test types required.
2. Test types executed.
3. Test types intentionally deferred and why.
4. Remaining risk if any required test was not run.
5. Permission state for creation, modification, local execution, GitHub execution, UI/device, and
   performance work where relevant.
6. Exact source SHA, profile/engine/toolchain identity, selected mode, and terminal result for each
   applicable test phase.

Passing the selected tests reduces known risk; it never proves that all possible defects were
found. A production-ready verdict requires the relevant non-test review, build, privacy,
accessibility, release, and product evidence in addition to the test report.
