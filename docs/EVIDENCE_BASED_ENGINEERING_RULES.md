# Evidence-Based Engineering Rules

<!-- Rule ID: QC.EVIDENCE.FRESHNESS v1.0 -->

## Purpose
Prevents unsupported claims such as “fixed”, “optimized”, “safe”, or “production-ready”.

## Evidence Rule
Every strong completion claim must include evidence:
- source/code evidence
- build result
- test result
- static check
- simulator/manual verification
- Instruments/profiler metric
- release/CI result

When adequate evidence is unavailable, report the claim as unverified and state the remaining risk; recording a risk is not evidence that the claim is true.

Evidence classes do not imply one another. A source/document/diff check, compiled target,
passing test, runtime observation or production cohort supports only its declared scope and
conditions. In particular, a passing test does not establish that every affected app/extension
target builds, that a screen matches its design, or that races and memory leaks are absent.
Negative and failure paths need their own evidence. Missing, partial, stale, failed or skipped
observations remain explicit gaps; another passing check cannot turn them into PASS.

## Forbidden Claims Without Evidence
- “performance improved” without metric or code-level proof and remaining-risk note
- “production-ready” without production readiness gate
- “secure” without security/privacy gate
- “migration safe” without migration reasoning/check
- “accessible” without accessibility review
- “done” without definition-of-done check

## Report Template
- Claim
- Evidence
- Scope
- Verification not run
- Remaining risk

For meaningful completion reports, use the stricter shape in `./docs/COMPLETION_REPORT_CONTRACT.md`.

## Evidence lifecycle and cleanup

Select when preserving, reusing, invalidating or deleting verification artifacts. The evidence
owner maintains this contract after retention/privacy or verifier changes. It complements existing
claim/freshness rules, not an automatic cleanup, download or rerun permission.

Keep two facts separate: the recorded result of a completed scoped observation, and whether its
raw artifact is currently available. Before authorized cleanup preserve a compact receipt with:

- claim/scenario, source SHA or source digests, configuration and exact selected target/runtime;
- toolchain/verifier identity, command/selection, terminal result, failed/retried/skipped counts;
- meaningful diagnostics and limits, original artifact location/digest where available;
- artifact owner/class (regenerable build/cache, raw diagnostic, compact acceptance/recovery,
  shipped archive/dSYM, user data/source), retention decision and current raw availability;
- cleanup date/scope/reason/authority and what can no longer be inspected or reproduced directly.

Remove only identified owned regenerable/raw inputs under current permission; never infer that an
untracked file is disposable. Preserve original failures and unique evidence needed for an open
finding, source/resource/Git state, ambiguous files and required recovery material. Release archives,
dSYMs, credentials and user data have separate owner/retention rules; they are not ordinary caches.
Do not read unrelated personal paths or delete simulator runtimes as a cleanup side effect.

After deletion mark the raw artifact removed/unavailable. The historical receipt may still say that
the named scenario passed at its recorded revision; do not retain a live raw-proof link or claim it
is now reproducible from that artifact. A digest without bytes is identity metadata, not recoverable
proof. New source/configuration/runtime/verifier changes require applicability/freshness review;
reuse only unchanged evidence whose exact scope still supports the claim. Rerun only with current
permission when the missing evidence is necessary, otherwise retain the explicit gap.

Compact acceptance records have no blanket expiry merely because caches were cleared. Their useful
lifetime follows the claim/source/profile and retention decision. This does not extend an old
runtime result to a new candidate, erase an earlier failure, or justify indefinite raw-log retention.
