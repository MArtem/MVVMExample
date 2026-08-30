# MVVMExample Project Health

## Current Shape

- App target: `MVVMExample`; iOS 17+ SwiftUI MVVM demo/pre-production app.
- App-local support: `MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport/`.
- App unit and UI test targets plus `MVVMExample.xctestplan` and `MVVMExampleUI.xctestplan` exist;
  running them remains user-owned.

## Active Risks

- In-memory demo session state is not approved production persistence.
- Release readiness is not established: signing, bundle identity, privacy manifest, analytics/crash
  routing, and rollout/rollback need a separate release phase.
- Demo credentials and test API use must remain explicit debug/demo behavior.

## Boundaries

Feature policy, DTO mapping, routes, ViewModels, and UI remain in the app. The app does not create
local package mirrors or speculative infrastructure layers. The canonical MVVMExample overlay is
`/Users/Artem/.zenflow/worktrees/documentation-vault/apps/MVVMExample/project-rules.md`.

## Verification

Use `./scripts/verify.sh static` for the deterministic local check. Builds, tests, Simulator UI,
and release verification require user delegation.
