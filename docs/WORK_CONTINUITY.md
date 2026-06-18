# Work Continuity

## Purpose
Durable resume checkpoint for `MVVMExample` when chat/task context is lost.

## Chat Transition Rule
- Keep and update a universal transition prompt here.
- After reset, run bootstrap read once per new chat.
- Every context-transfer prompt must include:
  **"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.

## Filesystem Sandbox Rule
- All project work, build output, package caches, Xcode DerivedData, cloned package state, logs, traces, and temporary project artifacts must stay inside `/Users/Artem/.zenflow`.
- Never use `/Users/Artem/Library`, `/tmp`, global SwiftPM/Xcode caches, or any other path outside `/Users/Artem/.zenflow` for project work.
- If a command/tool would default outside the worktrees sandbox, override its output paths before running it.

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
7) ./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md
8) ./docs/MODEL_ROUTING_RULE.md
9) текущие task docs under ./.zenflow/tasks/mvvmexample-3c80/ если есть

Правило после очистки контекста:
- перечитать весь актуальный набор документации и правил для этого worktree и task-контекста
- reusable baseline является накопительным и не должен теряться при переходе между проектами
- никогда не выходить за файловую границу `/Users/Artem/.zenflow`; build/cache/DerivedData/package verification output тоже должны быть внутри этой границы
- применять `./docs/MODEL_ROUTING_RULE.md`, не старое правило GPT-5.5-for-all
```
