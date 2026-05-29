# External Skill Dependencies

## Purpose
Environment-level reusable skills that are not originally stored inside the source project. They are snapshotted here so reusable skill knowledge is not lost when moving to a new task/project.

## Rule
- New projects must receive both project-local reusable skills and this external skill snapshot.
- If the target Zenflow/Codex environment already exposes these skills, use the environment version.
- If a skill is not exposed in the new task, use this snapshot as the recovery/source-of-truth copy or report the missing skill as a remaining risk.
- Plugin-backed skills may also require their plugin/MCP/app connector to be installed; copying documentation alone may not recreate connector permissions.

## Snapshotted Sources
### `codex-home`
- Source: `<user-home>/.codex/skills`
- Status: `copied`
- Skills:
  - `.system/imagegen`
  - `.system/openai-docs`
  - `.system/plugin-creator`
  - `.system/skill-creator`
  - `.system/skill-installer`
  - `swift-concurrency`
  - `swift-testing-expert`
  - `swiftui-expert-skill`
  - `zen-discovery`
  - `zen-office-docx`
  - `zen-office-pdf`
  - `zen-office-pptx`
  - `zen-office-xlsx`
  - `zenflow-brainstormer`
  - `zenflow-codebase-explorer`
  - `zenflow-fixer`
  - `zenflow-implementer`
  - `zenflow-plan-designer`
  - `zenflow-plan-orchestrator`
  - `zenflow-planner`
  - `zenflow-researcher`
  - `zenflow-review-orchestrator`
  - `zenflow-review-worker`

### `agents-home`
- Source: `<user-home>/.agents/skills`
- Status: `copied`
- Skills:
  - `agent-browser`
  - `cross-review`
  - `frontend-design`
  - `init`
  - `plan`
  - `research`
  - `skill-creator`
  - `zen-comprehensive-review`
  - `zen-review`

### `codex-system`
- Source: `<user-home>/.codex/skills/.system`
- Status: `copied`
- Skills:
  - `imagegen`
  - `openai-docs`
  - `plugin-creator`
  - `skill-creator`
  - `skill-installer`

### `plugin-browser-use`
- Source: `<user-home>/.codex/plugins/cache/openai-bundled/browser-use/0.1.0-alpha1/skills`
- Status: `copied`
- Skills:
  - `browser`

### `plugin-openai-primary-runtime`
- Source: `<user-home>/.codex/plugins/cache/openai-primary-runtime`
- Status: `copied`
- Skills:
  - `documents/26.426.12240/skills/documents`
  - `presentations/26.426.12240/skills/presentations`
  - `spreadsheets/26.426.12240/skills/spreadsheets`

### `plugin-github`
- Source: `<user-home>/.codex/plugins/cache/openai-curated/github/acdd3141/skills`
- Status: `copied`
- Skills:
  - `gh-address-comments`
  - `gh-fix-ci`
  - `github`
  - `yeet`

