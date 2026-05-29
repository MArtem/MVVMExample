# Reusable Baseline Transfer Checklist

## Purpose
Repeatable checklist for moving the accumulated non-app-specific baseline into a new task/project without losing documentation, rules, prompts, skills, templates, or environment knowledge.

## Before Transfer
- Confirm target project/task name.
- Confirm target repository URL.
- Confirm target worktree path.
- Confirm whether the target already has app-specific docs.

## Copy Required Baseline
- Copy `./docs/` from this reusable baseline into the target project.
- Copy `./.codex/skills/` from this reusable baseline into the target project.
- Copy `./external-environment/skills/` into the target project documentation or recovery area.
- Copy `./REUSABLE_USER_AND_AGENT_RULES.md`, `./EXTERNAL_SKILL_DEPENDENCIES.md`, and this checklist.
- Copy `./templates/` and instantiate project-specific docs from them.

## Instantiate Project-Specific Files
Create or update:
- `./PROJECT_DOCUMENTATION.md`
- `./PROJECT_HEALTH.md`
- `./TESTING_INSTRUCTIONS.md`
- `./docs/README.md`
- `./docs/CURRENT_USER_OVERRIDES.md`
- `./docs/WORK_CONTINUITY.md`
- app-specific feature contracts when known

## Replace Placeholders
Replace:
- `<AppName>`
- `<task-id>`
- `<worktree-path>`
- `<repository-url>`
- bundle IDs
- device/simulator assumptions
- build/test commands

## Verify No Source-App Leakage
Search the target for source-app tokens before first commit.

```zsh
rg -n "<SourceAppName>|<SourceTaskId>|<SourceUserHome>|<SourceAppSpecificToken>" ./docs ./.codex ./PROJECT_DOCUMENTATION.md ./PROJECT_HEALTH.md ./TESTING_INSTRUCTIONS.md || true
```

Any hit must be intentionally app-specific for the new project or removed.

## Verify Baseline Integrity
Run:

```zsh
git diff --check
```

If the new project has a docs index checker, run it too.

## Completion Report
Report:
- files copied
- templates instantiated
- external skills available/missing
- placeholder replacements done
- checks run
- remaining risks
