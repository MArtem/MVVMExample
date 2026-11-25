# iOS PR Review Template

## Scope
- What changed:
- User-visible behavior:
- Out of scope:

## PR Authority And Internal Gate
- Implementation reported ready at:
- User explicitly authorized PR creation at:
- Intended target remote ref:
- Internal Exhaustive candidate-range review: pending | pass | findings
- Corrective findings resolved and complete review repeated: not needed | pending | pass

Readiness is not PR authority. Complete this gate only after the user says to create the PR. The
implementing agent performs it directly over the complete target merge-base through candidate diff;
it does not invoke external Codex Review or grant build, test, Simulator, GitHub-run, or paid-service
permission. Do not push or create the PR while a P0–P2 remains.

## Risk Card (complete before implementation)
- Primary risk class: UI/accessibility | state/concurrency | persistence/import/export | external input | dependency | build graph/workflow | security/privacy | control-plane | domain/product logic | other (define evidence):
- Required invariant and explicitly unchanged behavior:
- State ordering to preserve (success / empty / error / cancellation / retry / concurrent action):
- Authority and data-safety boundary (trusted input, untrusted input, or data that must not be lost):
- Affected producers, consumers, callers, schemas, configuration, and claims:
- Smallest sufficient evidence and intentionally omitted evidence:
- Residual risk or user decision still required:

Use one primary high-risk class per PR. Combine two only when they are inseparable; explain the
dependency above and select evidence for both. This is a scoping aid, not a reason to split a
correct atomic fix.

## Required Checks
- [ ] Product requirements and states are clear.
- [ ] Architecture/state/data ownership is correct.
- [ ] UI hot paths are clean.
- [ ] Concurrency/lifecycle/cancellation are safe.
- [ ] Persistence/network/offline behavior is correct where applicable.
- [ ] Security/privacy/logging are safe.
- [ ] Accessibility/localization are covered.
- [ ] Errors/retry/empty/loading/offline states are covered.
- [ ] Memory/cache/media behavior is bounded where applicable.
- [ ] Observability is sufficient.
- [ ] Verification evidence is attached.
- [ ] Every selected check has an honest terminal result; missing/skipped/unavailable evidence is
      not represented as PASS.
- [ ] The complete candidate PR range was internally reviewed after PR authorization.
- [ ] After fixes, the complete review was repeated and the exact committed PR range was reviewed.
- [ ] Risks/debt/exceptions are recorded.

## Reviewer Output
- Blocking findings:
- Non-blocking findings:
- Remaining risks:
- Required follow-up:
- Approval condition:

## Review Receipt
- Global baseline revision / unavailable:
- Target remote ref:
- Target remote SHA:
- Target ref freshness check before push:
- Derived merge-base SHA:
- Reviewed HEAD SHA and range:
- Relevant profile identity / not applicable:
- Relevant configuration identity / not applicable:
- Selected permission-set identity / not applicable:
- Toolchain identity / not applicable:
- Clean-worktree result:
- Change-contract / risk-card rows reviewed:
- Proposed-diff self-review:
- Internal Exhaustive candidate-range review and findings:
- Full candidate-range repeat after fixes / not needed:
- Exact-SHA complete PR-range self-review:
- Findings and disposition:
- Relevant commands and results:
- Pre-push receipt-input revalidation:
- Evidence reused:
- Evidence intentionally omitted and why:
- GitHub manual check recommendation/result (`NOT_RUN_BY_USER_DECISION` until the user runs it):
- External Codex Review recommendation/user-provided result (never agent-triggered):
- Whole-project or feature review user-provided result / not requested:
- Residual risk:
- Escaped finding feedback record, if any:
