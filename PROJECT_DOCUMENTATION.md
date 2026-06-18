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
8. current task docs under `./.zenflow/tasks/mvvmexample-3c80/` when available

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
- Networking/API: environment-owned configuration through standalone neutral packages
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

This project intentionally does not keep standalone package folders locally. Reusable package source is preserved in the TchopApp `./PackagesForReuse` vault and can be copied into a project later when package-mode adoption is explicitly desired.

### `./docs/` and `./.codex/skills/`
Own reusable production baseline, prompt presets, skills, and static quality gates.

## Current Task Overrides
Current task/user overrides live in `./docs/CURRENT_USER_OVERRIDES.md`.

## Knowledge Organization
- Reusable cross-project knowledge: `./docs/knowledge/global/`
- App-specific knowledge: `./docs/knowledge/MVVMExample/`


### Local Liquid Glass support
`./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport/AppGlassUI/` owns the local Liquid Glass availability/fallback helper. App code still owns `AppTheme`, surface placement, and interaction/accessibility semantics.
