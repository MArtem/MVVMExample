# External Skill Dependencies

## Purpose
Environment-level reusable skills that are not originally stored inside the source project. They are snapshotted here so reusable skill knowledge is not lost when moving to a new task/project.

## Rule
- New projects do not copy this snapshot by default. If the target Codex app environment exposes a
  required skill, use that environment version.
- If a required skill is not exposed, report it as unavailable and use an authorized provider installation or recovery path only where its terms and permissions allow. A historical snapshot is not a guarantee of availability or redistribution rights. A normal project bootstrap must not silently import external skills or permissions.
- Plugin-backed skills may also require their plugin/MCP/app connector to be installed; copying documentation alone may not recreate connector permissions.

## Current snapshot and licensing status — 2026-11-20

The current `reusable/baseline/external-environment/skills/` tree contains 166 files across six
source groups: `agents-home`, `codex-home`, `codex-system`, `plugin-browser-use`, `plugin-github`,
and `plugin-openai-primary-runtime`. Eight license files are present; the inspected headers identify
Apache License 2.0. Their coverage of neighboring files and the exact upstream revisions of the
snapshot groups have not been established. A license file or its name does not grant rights to
other copied files.

`tasks/kb-audit-2026-11-11/external-skill-snapshot-inventory.md` is a historical receipt of
entrypoint hashes at vault revision `14045ebdf91c9af1ec268226e14ea4c92e080d00`. Those hashes
identify that historical snapshot only; they are not current environment, version, license-scope, or
redistribution evidence. Do not copy this snapshot into a new project by default.

## Snapshotted Sources

The list below records a historical environment, not a claim of present installation, complete snapshots, permitted redistribution, or current versions. Check each provider and its terms. Snapshot entrypoint inventory: `tasks/kb-audit-2026-11-11/external-skill-snapshot-inventory.md` in the documentation vault.

### `codex-home`
- Source: `<user-home>/.codex/skills`
- Status: historical snapshot; five byte-identical system-skill copies were deduplicated to `codex-system/`, with their earlier paths recoverable in Git.
- Skills:
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
- Status: historical inventory; the documents snapshot was removed. Other entries have not been validated for current availability or retention rights.
- Skills:
  - `documents/26.426.12240/skills/documents` — historical snapshot removed because its included license restricts retained copies; use the currently provided environment skill when available.
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

## User-provided Apple Xcode skill references

A separate user-provided Xcode skill export was recorded in `reusable/local-ios-skills/README.md`
(source location reported as `<zenflow-root>/xcode-skills`, received 2026-10-30). The canonical
reference tree contains ten skill folders and 83 files totaling 941,152 bytes. The README records
941,232 bytes for the supplied export and says trailing whitespace/terminal blank lines were
normalized; the 80-byte difference has not been reconciled against a raw-export checksum. No
`LICENSE`, `NOTICE`, `COPYRIGHT`, or provenance manifest is present in those reference folders.
Authorship, license, and the source export's version remain UNKNOWN. Do not infer Apple authorship or
redistribution permission from the folder name, URL citations, or prior publication.

These files are reference data under their governed top-level skill wrappers, not standalone skills,
executable instructions, or evidence that every API statement is current. Check exact availability
against the active SDK or current official documentation. No new project should copy these references
by default; any further retention or distribution must follow an explicit source/rights decision.
