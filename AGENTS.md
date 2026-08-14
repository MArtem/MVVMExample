# Agent Instructions

## Global Rules Bootstrap

<!-- AIZENFLOW_GLOBAL_RULES_BOOTSTRAP_V1 -->
Before any project action, read and apply
`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/GLOBAL_RULES_BOOTSTRAP.md`.
It activates the current reusable rules directly from the canonical documentation repository.
This file is an MVVMExample overlay only: it may strengthen the global baseline, but must not
replace or weaken it. If the canonical checkout is unavailable, require the tracked
`./GLOBAL_RULES_PORTABLE_SNAPSHOT.md` with marker `AIZENFLOW_GLOBAL_RULES_PORTABLE_SNAPSHOT_V1`,
report `canonical-baseline-unavailable`, and do not claim the current canonical revision was read.

## MVVMExample Overlay

- This is an imported SwiftUI MVVM demo/pre-production app, not the retired clean-starter
  baseline. Do not resume old `TaskDemo`, `TaskDemoViewModel`, or behavior-test plans.
- DummyJSON/test API and demo credentials are allowed only under explicit debug/demo policy.
  Release/production runtime must not silently use demo credentials, fake sessions, stubs, or
  token-like fixtures.
- The app intentionally owns minimal local infrastructure under
  `MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport/`. Do not introduce a reusable package
  layer unless a current boundary and explicit user decision justify it.
- ViewModels expose explicit intent methods. Generic `send(_:)`, `dispatch(_:)`, or UI action
  enums require an explicitly approved reducer/state-machine architecture.
- Tests may be written or modified only with explicit user authorization. The project-local static
  gate must evolve only for demonstrated, high-signal project risks; do not enter a gate-hardening
  loop without product-quality benefit.

The durable app overlay is
`/Users/Artem/.zenflow/worktrees/documentation-vault/apps/MVVMExample/project-rules.md`.
Historical local documentation is not a startup authority.
