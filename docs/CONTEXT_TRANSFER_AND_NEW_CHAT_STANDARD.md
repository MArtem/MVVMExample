# Context Transfer And New Chat Standard

## Purpose
Prevent context overload and preserve work continuity when a chat becomes too large or the current agent context becomes risky.

## Agent Responsibility
The agent must proactively tell the user when it is time to move to a new chat. Do not wait until the context is already unreliable.

On every new meaningful task request, decide before task actions whether the current chat needs a
context refresh. If it does not, proceed without asking the user to monitor context health. If it
does, stop before the task, state the reason briefly, and provide a ready-to-paste new-chat prompt
that includes the required transition spec. Do not create or move the user to a new chat silently.

## Trigger Conditions
Recommend a new chat when one or more conditions are true:

- the conversation has accumulated multiple large implementation/review phases;
- the agent starts relying on summaries instead of current files/docs for important decisions;
- the user asks to start a new independent phase or project;
- the current answer would need to restate too much history to stay safe;
- task state, docs, plans, or changed files are becoming hard to track;
- there was a tool/runtime interruption and continuity is not fully obvious;
- the next block is high-risk and should start from a clean reread of docs and current files.

## Required Transition Spec
When recommending a new chat, provide a compact handoff spec with:

1. project/worktree/task/chat identifiers;
2. current model rule;
3. mandatory startup read order;
4. current user rules and restrictions;
5. changed files and verification status;
6. exact current task state;
7. next safe steps;
8. what must not be done;
9. the rule: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.

## Meaning Of "Current Set"

For this rule, the current set is only the documentation that can govern the resumed work:

1. the router's Level 0 baseline;
2. the active task handoff and plan, when present;
3. the routes selected for the resumed task;
4. the current app or project overlay when the task uses one; and
5. any document changed since the preceding receipt or explicitly required by the user.

It does not mean the entire documentation library, archives, unrelated app boundaries, or every
deep reference. Load a deep reference only when its selected route requires it, its stated trigger
applies, the task risk or ambiguity rises, or the user asks for it. When classification is unclear,
broaden the route before acting rather than guessing.

## Output Size Rule
The transition spec should be complete but compact. Do not include raw command logs, full diffs, tool output, or long scripts unless the user explicitly requests them.

## After Transfer
The new chat must start by rereading the defined current set before making code, docs, git, or
project changes.
