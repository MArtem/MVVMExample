# Definition Of Done

## Purpose
Minimum completion contract for production iOS work.

A task is done only when:
1. Product behavior is implemented as specified; no guessed behavior remains.
2. Relevant production gates are checked.
3. P0–P2 findings are closed or covered by an explicit higher-authority accepted-risk record;
   P3 findings are fixed or explicitly reported.
4. Architecture/ownership is clear.
5. Hot paths, state invalidation, persistence, network/sync, memory, security/privacy, accessibility, and observability were considered where relevant.
6. Verification appropriate to the change was run or explicitly deferred with remaining risk.
7. Documentation/plan/handoff is updated when the task changes durable behavior.
8. Code documentation contracts are updated when public/internal APIs, ownership/lifecycle, external usage, side effects, concurrency, errors, invariants, or temporary workarounds change.

`PASS`, `NOT_READY`, `READY_WITH_ACCEPTED_RISK`, `BLOCKED`, and `NOT_APPLICABLE` follow the shared
governance contract. Local completion does not imply merge or release readiness, and unrun,
denied, stale, partial, or unavailable evidence is never a normal PASS.

## Completion Report Template
- Scope completed.
- Files changed.
- Behavior changed.
- Gates applied.
- Verification run.
- Verification not run and why.
- Remaining risks.
- Code documentation updated or explicitly not needed.

Use `./docs/COMPLETION_REPORT_CONTRACT.md` for the full required report shape, including context health, model result, local exceptions, and intentionally skipped work.
