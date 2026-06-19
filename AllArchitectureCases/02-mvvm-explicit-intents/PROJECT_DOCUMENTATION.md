# MVVMExample Developer Onboarding Guide

## Purpose
Stable onboarding document for `MVVMExample`.

Read this file for:
- current app shape
- architecture boundaries
- runtime baselines
- documentation entry points
- top-level folder ownership

Do not use this file for temporary task history or debugging notes.

## First Read For Agents
When starting or resuming work in this worktree, read in this order:
1. `./docs/README.md`
2. `./PROJECT_DOCUMENTATION.md`
3. `./PROJECT_HEALTH.md`
4. `./TESTING_INSTRUCTIONS.md`
5. `./docs/CURRENT_USER_OVERRIDES.md`
6. `./docs/AGENT_RULES.md`
7. `./docs/WORK_CONTINUITY.md`
8. `./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md`
9. `./docs/MODEL_ROUTING_RULE.md`
10. current task docs under `./.zenflow/tasks/mvvmexample-3c80/` when available

For context transfer, include this exact rule:
**"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.

## Quick Orientation
`MVVMExample` is a SwiftUI iOS 17+ MVVM demo app with:
- auth gate and login flow
- main tab coordinator
- news list/detail flow backed by DummyJSON-style API data
- profile viewing/editing flow
- app-local minimal infrastructure support under `./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport`

The project is demo/pre-production. Test API usage is allowed only when configured explicitly as demo/debug behavior.

## Stable Runtime Baselines
- Deployment target: `iOS 17.0`
- UI state approach: SwiftUI + `@Observable` ViewModels where the feature owns async state or navigation intent
- ViewModel API: explicit intent methods, not default `send(_ action:)`
- Persistence: in-memory session store for demo mode; production persistence policy is not approved yet
- Networking/API: environment-owned configuration through app-local `LocalSupport` primitives copied from the reusable baseline
- Localization: user-facing strings should flow through localization helpers/resources rather than ad-hoc literals
- Architecture constraints: keep the example small, explicit, educational, and avoid speculative layers

## Top-Level Ownership
### `./MVVMExample/`
Owns app target code, assets, SwiftUI composition, app-specific feature contracts, DTO mapping, and demo UI.

### `./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport`
Owns the minimal app-local copies of infrastructure mechanics currently needed by this project:
- configuration/session primitives
- error taxonomy and user-safe mapping support
- localization facade
- redacted logging facade
- network client/request primitives
- remote image loading/cache primitives
- Liquid Glass availability/fallback helpers

This project intentionally does not keep standalone package folders locally. Reusable rules and source context are tracked through the central documentation vault at `/Users/Artem/.zenflow/worktrees/new-task-be0b/documentation-vault`; package-mode adoption requires explicit user approval before recreating `./Packages`.

### `./docs/` and `./.codex/skills/`
Own reusable production baseline, prompt presets, skills, and static quality gates.


## Test And Release Readiness
- Fast deterministic unit tests live in `./MVVMExample.xctestplan`.
- UI accessibility smoke tests live in `./MVVMExampleUI.xctestplan` and are not part of the default unit lane.
- `./scripts/verify.sh` owns the supported local verification commands and keeps DerivedData/package cache output inside `/Users/Artem/.zenflow`.
- The app is not release-ready until a separate release phase establishes signing, bundle identity, privacy manifest, analytics/crash routing, and rollout/rollback policy.

## Current Task Overrides
Current task/user overrides live in `./docs/CURRENT_USER_OVERRIDES.md`.

## Knowledge Organization
- Reusable cross-project knowledge: `./docs/knowledge/global/`
- App-specific knowledge: `./docs/knowledge/MVVMExample/`


### Local Liquid Glass support
`./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport/AppGlassUI/` owns the local Liquid Glass availability/fallback helper. App code still owns `AppTheme`, surface placement, and interaction/accessibility semantics.


## Documentation Vault Ownership
- Reusable/cross-project docs: `/Users/Artem/.zenflow/worktrees/new-task-be0b/documentation-vault/reusable/`
- MVVMExample app-specific docs: `/Users/Artem/.zenflow/worktrees/new-task-be0b/documentation-vault/apps/MVVMExample/`
- Cross-app context must be read through `documentation-vault/apps/<AppName>/`; do not copy TchopApp-specific rules into MVVMExample docs.
