# MVVMExample Developer Orientation

## Authority

Start with the canonical global-rules bootstrap in `AGENTS.md`, then read the MVVMExample overlay
at `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/MVVMExample/project-rules.md` when the
task concerns this app. Do not use the local historical documentation tree as a startup route.

## Current Shape

MVVMExample is an iOS 17+ SwiftUI MVVM demo/pre-production app with an auth gate, news list/detail,
profile editing, an explicitly configured DummyJSON-style API, and in-memory demo session state.
Feature code, DTO mapping, navigation, and UI composition live under `./MVVMExample/`; minimal
app-local support lives under `./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport/`.

## Verification

`./scripts/verify.sh static` is the local deterministic check. Builds, tests, Simulator UI,
screenshots, Instruments, archive, and signing remain user-owned unless separately delegated.

## Documentation Boundaries

- Reusable policy is loaded from the canonical vault through the bootstrap.
- Durable MVVMExample decisions and exceptions belong in `apps/MVVMExample/` in that vault.
- Local legacy material is recovery-only and must not be copied back into active policy.
