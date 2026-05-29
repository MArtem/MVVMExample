# Work Continuity

## Purpose
Durable resume checkpoint for `MVVMExample` when chat/task context is lost.

## Chat Transition Rule
- Keep and update a universal transition prompt here.
- After reset, run bootstrap read once per new chat.
- Every context-transfer prompt must include:
  **"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.

## Universal Transition Prompt Template
```text
Работаем в проекте `MVVMExample` в worktree:
`/Users/Artem/.zenflow/worktrees/mvvmexample-3c80`

Перед началом прочитай:
1) ./docs/README.md
2) ./PROJECT_DOCUMENTATION.md
3) ./PROJECT_HEALTH.md
4) ./docs/CURRENT_USER_OVERRIDES.md
5) ./docs/AGENT_RULES.md
6) ./docs/WORK_CONTINUITY.md
7) текущие task docs under ./.zenflow/tasks/mvvmexample-3c80/ если есть

Правило после очистки контекста:
- перечитать весь актуальный набор документации и правил для этого worktree и task-контекста
- reusable baseline является накопительным и не должен теряться при переходе между проектами
```
