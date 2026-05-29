---
name: ios-production-auditor
description: Use this skill for broad production-readiness audits of any iOS app or feature. Trigger whenever the user asks if an iOS implementation is production-ready, asks for a full iOS audit, says review should not be narrowly scoped, or wants to find hidden production risks across lifecycle, UI, data, networking, security, accessibility, observability, testing, and release readiness.
---

# iOS Production Auditor

## Workflow
1. Read project active docs first if available.
2. Apply the production readiness standard and review completeness gate.
3. Inspect beyond the immediate bug: lifecycle, UI hot paths, state ownership, persistence, network/sync, security/privacy, accessibility, observability, release, and verification.
4. Classify findings P0/P1/P2/P3.
5. Do not say production-ready unless every relevant area is checked or explicitly not applicable.

## Output
- Scope and exclusions.
- Gate coverage table.
- Findings with evidence, target state, remediation order, verification.
- Remaining risks.

## References
- `./docs/IOS_PRODUCTION_READINESS_STANDARD.md`
- `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`
- `./docs/DEFINITION_OF_DONE.md`
