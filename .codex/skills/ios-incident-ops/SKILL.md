---
name: ios-incident-ops
description: "Use this skill for iOS production operations: incidents, crash spikes, bad releases, rollbacks, feature flags, staged rollouts, SLOs, product health, risk registers, and postmortems. Trigger whenever the user mentions incident, rollout, rollback, hotfix, kill switch, SLO, production health, or accepted risk."
---

# iOS Incident Ops

## Workflow
1. Classify severity.
2. Identify mitigation: rollback, kill switch, hotfix, backend mitigation.
3. Check SLO/observability coverage.
4. Update risk or tech debt registers when explicitly accepted.
5. Require postmortem for severe incidents.

## Output
- Severity.
- Immediate actions.
- Owners.
- Verification.
- Follow-ups.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:INCIDENT_RESPONSE_STANDARD.md`
- `DOC:FEATURE_FLAGS_AND_ROLLOUTS.md`
- `DOC:PRODUCT_HEALTH_SLO.md`
- `DOC:RISK_REGISTER.md`
- `DOC:TECH_DEBT_REGISTER.md`
