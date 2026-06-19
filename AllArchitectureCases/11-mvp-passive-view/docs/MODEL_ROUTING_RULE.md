# Model Routing Rule

## Purpose
Use models by task risk, not habit. Save limits on reversible execution work, but do not lower model quality on decisions that shape architecture, data ownership, user data, security, or long-term maintenance.

## Mandatory Task Classification
Before editing code or documentation for a task, classify it as one of:

1. `GPT-5.5 Planning Required`
2. `GPT-5.4 Execution Only`
3. `GPT-5.4 Execution + GPT-5.5 Final Review`
4. `GPT-5.5 Full Task Required`

Explain the classification in 3–5 bullets before making changes. For tiny conversational answers with no file/tool work, keep the answer concise and do not force a heavy ceremony.

## Default Executor: GPT-5.4
Use `GPT-5.4` for routine implementation when the architecture and ownership are already decided.

Appropriate `GPT-5.4` work includes:
- small and medium changes that follow an approved plan;
- implementation of an already chosen pattern;
- local SwiftUI updates from an accepted spec;
- DTO/model mapping after the data flow is defined;
- repository/use-case/view-model wiring when the boundary is already chosen;
- unit tests for known behavior when tests are allowed;
- compiler-error fixes with a clear cause;
- renaming, moving files, formatting, cleanup, and documentation/comments for accepted code;
- simple bug fixes with a concrete local cause.

`GPT-5.4` must not invent architecture. If the work raises ownership, boundary, data-flow, persistence, concurrency, navigation, public API, or long-term structure questions, stop and escalate to `GPT-5.5`.

## Critical Gate: GPT-5.5
Use `GPT-5.5` for irreversible, high-risk, or quality-gate decisions.

`GPT-5.5` is required for:
- initial task decomposition and implementation contracts;
- choosing between implementation strategies;
- architecture, module boundaries, public protocols, and reusable package boundaries;
- data flow design from API DTO to domain/UI model to database model;
- SwiftData/CoreData/UserDefaults/files/app-group persistence strategy;
- concurrency, `@MainActor`, actor ownership, cancellation, and `Sendable` decisions;
- navigation architecture and app-wide state ownership;
- large refactors or changes touching many unrelated files;
- performance-sensitive SwiftUI decisions and scroll/media hot paths;
- security, privacy, authentication, authorization, token storage, data loss, migration, synchronization, offline/cache, uploads/downloads, or file-system safety;
- package adoption into `./PackagesInUse`, Xcode integration, or app runtime changes;
- important final reviews before merge/completion.

UI/design work from screenshots, Figma, PDF, SVG, CSS, visual references, or pixel-perfect comparison remains `GPT-5.5` unless the user explicitly relaxes that requirement. Routine SwiftUI implementation from an already approved spec may use `GPT-5.4`.

## Two-Phase Workflow For Non-Trivial Tasks
### Phase 1 — `GPT-5.5` Planning Gate
`GPT-5.5` creates a concise implementation contract:

1. goal;
2. affected files;
3. chosen architecture;
4. rejected alternatives and why;
5. step-by-step implementation plan;
6. invariants that must not be broken;
7. test/verification plan;
8. rollback plan;
9. exact limits for `GPT-5.4` execution.

The plan must be specific enough that `GPT-5.4` can implement without rethinking architecture.

### Phase 2 — `GPT-5.4` Execution
`GPT-5.4` implements only the approved contract.

`GPT-5.4` must:
- follow the contract exactly;
- avoid broad refactoring unless explicitly included;
- touch the minimum necessary files;
- keep diffs small;
- report ambiguity before changing architecture;
- run approved checks/tests;
- summarize changed files and important decisions without long theory.

If the plan is wrong, incomplete, unsafe, or starts requiring new architecture, stop and request `GPT-5.5` review instead of improvising.

## Final Review Rule
Use `GPT-5.5` for final review when:
- the diff touches architecture, persistence, concurrency, navigation, public protocols, app-wide state, package adoption, security/privacy, user data, cache, database, API contracts, or sync;
- the diff touches more than five files;
- the change is hard to revert;
- tests/checks fail or warnings appear;
- implementation deviated from the approved plan;
- the result affects future extensibility or repeated patterns.

For small isolated low-risk changes, `GPT-5.4` may self-review.

## Context Budget Rule
Do not load the full repository unless necessary.

Before starting, select only:
- directly edited files;
- protocols/interfaces used by those files;
- nearby tests when tests are allowed or verification requires them;
- architecture notes relevant to the task.

Prefer summaries over full files when the file is not directly edited. For review, prefer diffs over full files when possible.

## Output Budget Rule
Responses are concise by default.

For implementation tasks:
- no long theory;
- no repeated explanations;
- no full-file rewrites unless needed;
- summarize decisions in 5–10 bullets maximum.

For planning tasks:
- include enough reasoning to prevent architectural mistakes;
- do not generate implementation code unless requested;
- produce an executable plan.

## Escalation Triggers
Escalate from `GPT-5.4` to `GPT-5.5` immediately if any of these appear:

- “Where should this logic live?”
- “Should this be ViewModel, UseCase, Repository, Service, Actor, Store, or Environment?”
- “Should this be cached, persisted, mocked, or fetched?”
- “Does this affect offline behavior?”
- “Does this affect `MainActor` or async flow?”
- “Does this affect navigation or app-wide state?”
- “Does this create a new abstraction?”
- “Will this pattern be repeated across screens?”
- “Could this cause data loss or inconsistent UI?”
- “Does this touch security, privacy, auth, token storage, files, uploads/downloads, or app groups?”
- “The fix requires touching many unrelated files.”

## Current Session Implementation Note
If the primary assistant in a session is already `GPT-5.5`, use `GPT-5.4` through available subagents/tools for suitable execution/review blocks when that actually saves resources. `GPT-5.5` remains the planner, orchestrator, escalation target, and final decision model for high-risk work.

If `GPT-5.4` is unavailable, unsuitable for the tool, repeatedly fails, or produces lower-quality output, keep the work on `GPT-5.5` and report the reason briefly.
