# Agent Instructions

## Mandatory Response Header
Every working, status, readiness, confirmation, task-orientation, planning, or clarification response must start with:

- **Модель:** current model
- **Active phase:** current phase
- **Файлы смотришь/меняешь:** files being inspected/changed, or `none` if no files
- **Следующий безопасный шаг:** next safe step
- **Нужна ли сборка:** yes/no and why
- **Sandbox:** active worktree/sandbox confirmation

Short answers such as “готов”, “да, всё ясно”, “готов к новым задачам”, or “можешь присылать” are not exempt.

## Startup Read Rule
Before code, docs, git, or project changes, read:
1. `./docs/README.md`
2. `./PROJECT_DOCUMENTATION.md`
3. `./PROJECT_HEALTH.md`
4. `./TESTING_INSTRUCTIONS.md`
5. `./docs/CURRENT_USER_OVERRIDES.md`
6. `./docs/AGENT_RULES.md`
7. `./docs/WORK_CONTINUITY.md`
8. current Zenflow task plan if present

## Current Project Mode
- `MVVMExample` is an imported SwiftUI MVVM demo/pre-production app, not the old clean starter baseline.
- Do not continue old `TaskDemo` / `TaskDemoViewModel` / behavior-test plans.
- The app may use DummyJSON/test API and demo credentials only under explicit debug/demo policy.
- Release/production runtime must not silently use demo credentials, fake sessions, stubs, or token-like fixtures.
- Reusable neutral infrastructure belongs under `./Packages/AppInfrastructure/` and must use generic `App*` naming, not project/vendor-specific branding such as `Tchop*`.


## Product-Staff Quality Bar Rule
- Never lower the engineering bar because a project is described as demo, test, sample, prototype, imported, or pre-production; those words may only describe configuration/risk context, not code quality.
- Treat every authored or reviewed code path as product-staff-level production code: correct ownership, explicit state, clear failure behavior, performance-aware rendering, privacy-safe logging, accessibility, localization, and supportable verification.
- Do not wait for Instruments/profilers before fixing statically obvious performance or memory issues. Use profiling to prove behavior, compare alternatives, or validate non-obvious risks, not as an excuse to leave avoidable redraws, broad invalidation, main-thread work, unbounded caches, or lifecycle leaks.
- Maximize quality through the simplest correct design: improve hot paths, state ownership, and error handling without adding decorative protocols, wrappers, factories, use cases, or interfaces.

## MVVM Interaction Rule
- Do not use generic ViewModel dispatch as the default API: `send(_ action:)` is forbidden as feature boilerplate.
- Do not add UI action enums by default.
- ViewModels expose explicit intent methods such as `appeared()`, `loginTapped()`, `refreshRequested()`, `articleTapped(id:)`, `likeTapped(id:)`, `saveTapped()`, and `logoutTapped()`.
- A reducer/action architecture requires explicit user approval and an ADR before adoption.

## Tests And Verification
- Do not write or modify tests unless the user explicitly opens a test-writing phase or asks to fix a specific failing test.
- Run `git diff --check` after each implementation block.
- Run an Xcode build after Swift/package/project changes.
- Do not run simulator UI/Instruments/manual flows unless explicitly requested.

## Plan Rule
If new user-approved work benefits from a breakdown, update the local task plan with checkbox steps and mark completed steps before reporting completion.
