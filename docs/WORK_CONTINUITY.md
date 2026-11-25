# Work Continuity

## Purpose
Define compact resume-state ownership without duplicating task history or the Level 0 list.

## Canonical State
- `plan.md` contains only the current executable checklist.
- `handoff.md` contains the compact current resume state.
- App decisions and ADRs belong in the matching app documentation boundary.
- Superseded plans, long logs, and recovery snapshots belong in task archive/history.
- Reusable rules stay in the canonical reusable baseline, not in task docs.

Apply `./docs/TASK_STATE_DOCUMENTATION_STANDARD.md` before moving or rewriting task state.

## Resume Rule
On a new chat or explicit rules refresh:

1. Read `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md`.
2. Read its current Level 0 set once.
3. Select only task-relevant routes.
4. Re-read additional files only when their source changed or the task route changes.

Do not duplicate the numbered Level 0 list here; the router is its sole source of truth.

## Transition Spec
When recommending a new chat, provide a compact spec with:

- worktree/task/app identifiers;
- current restrictions and permissions;
- changed files and verification state;
- exact current task state and next safe step;
- must-not-do items;
- selected documentation route;
- context-health reason;
- **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.

Do not include raw logs, full diffs, tool output, or long scripts unless requested.

## Context Health
Meaningful completion reports state one of:

- `контекст обновлять не нужно`;
- `желательно обновить контекст`;
- `нужен новый чат`.

Recommend a new chat before reliability degrades, especially at a major phase boundary or before high-risk work after a long context.
