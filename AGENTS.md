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
4. `./docs/CURRENT_USER_OVERRIDES.md`
5. `./docs/AGENT_RULES.md`
6. `./docs/WORK_CONTINUITY.md`
7. current Zenflow task plan if present

## Current Project Mode
- This is a clean `MVVMExample` baseline project.
- Do not implement app-specific demo features unless the user explicitly asks.
- Do not continue old `TaskDemo` / `TaskDemoViewModel` / behavior-test plans.
- The user may provide Swift files or text fragments to add iteratively.
- When the user provides source fragments/files, preserve the code content unless the user explicitly asks for changes.
- Add files meaningfully to the project structure and Xcode project when requested.

## Tests And Verification
- Do not write or modify tests unless the user explicitly opens a test-writing phase or asks to fix a specific failing test.
- Do not run builds/tests/simulator UI/Instruments unless explicitly requested or already approved.
- `git diff --check`, docs index checks, and project-list checks are allowed when useful.

## Plan Rule
If new user-approved work benefits from a breakdown, update the local task plan with checkbox steps and mark completed steps before reporting completion.
