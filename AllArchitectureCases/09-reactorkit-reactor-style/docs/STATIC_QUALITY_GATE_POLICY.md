# Static Quality Gate Policy

## Purpose
Define how static scripts should be interpreted so they improve engineering quality without creating noisy or misleading CI failures.

## Severity Levels
- **Fail**: likely production defect, secret leak, generated artifact committed, app-breaking config, or known forbidden hot-path pattern.
- **Warn**: suspicious pattern requiring human classification.
- **Review Candidate**: context-dependent signal that must be checked during review but should not block alone.
- **Allowed Exception**: explicitly documented tradeoff with owner, reason, scope, and expiry/revisit condition.

## Rules For Scripts
- Scripts must prefer deterministic checks over subjective style opinions.
- A script that produces broad pattern matches must state whether output is fail, warning, or review candidate.
- Generated files, build outputs, dependency caches, traces, and task attachments should be excluded unless the script explicitly audits artifacts.
- False positives should be reduced by scope, naming, allowlist comments, or severity downgrade; they must not be silently ignored.
- New forbidden-pattern rules should include target state and remediation guidance.

## Review Rules
- Passing scripts is not enough to claim production-ready.
- Failing scripts must be either fixed, classified, or recorded as remaining risk.
- Allowed exceptions are temporary; permanent exceptions should become documented architecture rules.
