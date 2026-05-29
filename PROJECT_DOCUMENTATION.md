# MVVMExample Developer Onboarding Guide

## Purpose
Stable onboarding document for `MVVMExample`.

Read this file for:
- app shape
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
4. `./docs/CURRENT_USER_OVERRIDES.md`
5. `./docs/AGENT_RULES.md`
6. `./docs/WORK_CONTINUITY.md`
7. current task docs under `./.zenflow/tasks/mvvmexample-3c80/` when available

For context transfer, include this exact rule:
**"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.

## Quick Orientation
`MVVMExample` is an educational SwiftUI iOS sample app for demonstrating a small MVVM flow.

Replace this section with:
- main user flows
- primary modules/features
- persistence/runtime choices
- package/shared-code boundaries
- extension/widget/background capabilities when relevant

## Stable Runtime Baselines
- Deployment target: `iOS 17.0`
- UI state approach: SwiftUI state first; introduce ViewModels only when the demo feature needs explicit state ownership
- Persistence: none for the initial bootstrap; demo data should stay deterministic/offline
- Networking/API: none for the initial bootstrap
- Architecture constraints: keep the example small, explicit, and educational; no speculative layers

## Current Task Overrides
Current task/user overrides live in `./docs/CURRENT_USER_OVERRIDES.md`.

## Knowledge Organization
- Reusable cross-project knowledge: `./docs/knowledge/global/`
- App-specific knowledge: `./docs/knowledge/MVVMExample/`
