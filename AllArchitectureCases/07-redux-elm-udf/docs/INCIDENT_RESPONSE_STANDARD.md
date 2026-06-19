# Incident Response Standard

## Purpose
Operational response for production iOS incidents.

## Severity Levels
- **SEV0**: data loss, widespread crash, security/privacy leak, app unusable.
- **SEV1**: critical flow broken, severe performance regression, auth/sync outage impact.
- **SEV2**: degraded feature, limited crash spike, localized backend issue.
- **SEV3**: minor issue or cosmetic regression.

## Incident Workflow
1. Detect and classify.
2. Assign owner.
3. Mitigate: kill switch, rollback, server-side mitigation, hotfix.
4. Communicate status.
5. Verify recovery.
6. Write postmortem for SEV0/SEV1.

## Postmortem Template
- Summary
- Timeline
- Impact
- Root cause
- Detection gap
- Fix
- Prevention actions
- Owners and deadlines
