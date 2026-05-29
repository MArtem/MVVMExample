# Agent Prompt Presets

## Purpose
Reusable prompt presets for implementation, review, refactoring, testing, CI/debugging, ADR, release, and iOS production workflows.

## Usage
- Apply project/user overrides before any preset.
- Treat prompts as workflow templates, not as authority above active project/task rules.
- If a prompt conflicts with explicit user instructions or active docs, follow the higher-priority rule.

## Review Rule
When the user asks for `ревью`, `review`, `code review`, or `аудит`, use `./docs/agent-prompts/production-review-completeness.md` together with `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md` unless the user explicitly limits scope.
