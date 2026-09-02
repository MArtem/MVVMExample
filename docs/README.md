# Documentation Map

## Purpose
Entry point for active project documentation, production standards, prompt presets, reusable skills, and static quality gates.

## Default Read Order
1. `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md` and its Level 0 set once.
2. Current task plan/handoff when present.
3. Only the selected task routes.
4. `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/MVVMExample/MANIFEST.md` for
   MVVMExample product work.

The canonical root `MANIFEST.md` is used only for documentation-library completeness/recovery,
not normal startup.

## Mandatory Active Documentation Index

### Project Baseline
- `./docs/TEST_COVERAGE_PLAN.md`
- `./PROJECT_DOCUMENTATION.md`
- `./PROJECT_HEALTH.md`
- `./TESTING_INSTRUCTIONS.md`
- `./docs/AGENT_RULES.md`
- `./docs/WORK_CONTINUITY.md`
- `./docs/CURRENT_USER_OVERRIDES.md`
- `./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md`
- `./docs/MODEL_ROUTING_RULE.md`

### Reusable Production Standards
- `./docs/IOS_PRODUCTION_FRAMEWORK.md`
- `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`
- `./docs/PRODUCTION_QUALITY_GATES.md`
- `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`
- `./docs/DEFINITION_OF_DONE.md`
- `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md`

### Prompt Presets
- `./docs/agent-prompts/README.md`

### Reusable Skills
- `./.codex/skills/`

### Learning / Handbook Plans
- `./docs/IOS_SENIOR_LEAD_ARCHITECT_STAFF_HANDBOOK_OUTLINE.md`

### App-Specific Docs
- `./docs/PACKAGE_USAGE_IN_MVVMEXAMPLE.md`
Add app-specific docs here after the product shape is known.


### Documentation Vault
- Central git-backed vault: `/Users/Artem/.zenflow/worktrees/documentation-vault`
- Reusable rules/prompts/templates/scripts belong under `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/`.
- MVVMExample-specific durable docs belong under `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/MVVMExample/`.
- Do not copy TchopApp-specific docs into MVVMExample docs; read cross-app context through `documentation-vault/apps/<AppName>/`.

## Shared Documentation Library Rule
- The single shared documentation library is `/Users/Artem/.zenflow/worktrees/documentation-vault`.
- Do not copy the full shared documentation library into this worktree.
- Use local docs for MVVMExample-specific state and central docs for reusable/cross-task knowledge.
