# Evidence-Based Engineering Rules

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
- or explicit remaining risk when evidence is unavailable

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
