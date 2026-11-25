---
name: ios-evidence-gate
description: "Use this skill whenever an iOS completion claim needs validation: done, fixed, optimized, safe, secure, production-ready, no risk, or clean review. Trigger whenever the user challenges confidence, asks for proof, or wants assurance that issues were not missed."
---

# iOS Evidence Gate

## Workflow
1. Extract all claims made by the agent or implementation.
2. Require evidence for each claim: code evidence, build, test, static check, manual check, profiler, CI/release result, or documented remaining risk.
3. Reject unsupported claims.
4. Recommend the smallest verification that would prove each unsupported claim.

## Output
- Supported claims.
- Unsupported claims.
- Evidence gaps.
- Required verification.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:EVIDENCE_BASED_ENGINEERING_RULES.md`
- `DOC:DEFINITION_OF_DONE.md`
