# Reusable User And Agent Rules

## Purpose
Portable non-app-specific rules extracted from the current worktree preferences. Use this as the starting baseline for a new iOS project before app-specific rules exist.

## Model Rule
- Use and report `GPT-5.5` unless the user explicitly changes the model.
- UI/design work from screenshots, Figma, PDF, SVG, CSS, or visual references must use `GPT-5.5`.

## Working Response Header
Every working response should start with:
- model
- active phase
- files being inspected/changed
- next safe step
- whether a build is needed
- sandbox/worktree confirmation

## Implementation Style
- Do not guess product behavior. Ask when requirements, ownership, state flow, or acceptance criteria are unclear.
- Do not add speculative UI, speculative business logic, decorative wrappers, or extra abstractions.
- Prefer the simplest correct implementation that preserves runtime correctness, UX, and maintainability.
- New protocols, factories, adapters, use cases, services, per-view models, or managers require one concrete current problem.

## Testing And Verification Defaults
- Do not write or modify tests unless the user explicitly opens a test-writing phase or asks to fix a specific failing test.
- Do not run builds, tests, simulator UI, or Instruments by default unless requested or already approved for the current block.
- `git diff --check` and read-only/static documentation checks are allowed when useful.
- Claims such as done, fixed, verified, safe, smooth, production-ready, or clean require evidence.

## Review Trigger
When the user says `ревью`, `review`, `code review`, or `аудит`:
- run a production-grade review, not a narrow bug-only review, unless the user explicitly limits scope;
- check UI structure, hot paths, state invalidation, data identity, persistence, concurrency, memory/cache, navigation side effects, security/privacy, accessibility, observability, testing, and release risk where relevant;
- for every finding, report severity, affected files, evidence, why it is a problem, target state, remediation order, and verification required;
- if everything is claimed OK, show the checklist used;
- if correctness cannot be proven, report remaining risk instead of implying certainty.

## Context Transfer Rule
Every context-transfer prompt must include:
**"перечитать весь актуальный набор документации и правил для этого worktree и task-контекста"**.

## No-Loss Cumulative Transfer Rule
- Every new task/project must receive all reusable, non-app-specific documentation, rules, prompts, skills, templates, scripts, and environment skill snapshots accumulated so far.
- Nothing reusable may be dropped silently during transfer. If something cannot be copied or activated, record it as an explicit remaining risk and dependency.
- Reusable knowledge is cumulative: improvements made in one project should be promoted back into the reusable baseline before starting the next project.
- App-specific contracts must stay out of the reusable baseline unless generalized first.
- Before declaring a new task/project bootstrapped, verify that reusable docs, prompt presets, project-local skills, external skill dependencies, templates, and transfer scripts are present and indexed.
