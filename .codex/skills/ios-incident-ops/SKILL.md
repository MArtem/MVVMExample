---
name: ios-incident-ops
description: Use this skill for iOS production operations: incidents, crash spikes, bad releases, rollbacks, feature flags, staged rollouts, SLOs, product health, risk registers, and postmortems. Trigger whenever the user mentions incident, rollout, rollback, hotfix, kill switch, SLO, production health, or accepted risk.
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
- `./docs/INCIDENT_RESPONSE_STANDARD.md`
- `./docs/FEATURE_FLAGS_AND_ROLLOUTS.md`
- `./docs/PRODUCT_HEALTH_SLO.md`
- `./docs/RISK_REGISTER.md`
- `./docs/TECH_DEBT_REGISTER.md`
