# Data Governance And Compliance

## Purpose
Rules for user data classification, retention, deletion, export, and regulatory considerations.

## Required Checks
- Classify data: public, internal, user private, PII, sensitive, secret.
- Define legal basis/consent when needed.
- Define retention and deletion policy.
- Define account deletion/export behavior.
- Review third-party SDK data sharing.
- Review regional requirements: GDPR/CCPA/children/health/finance where relevant.
- Keep audit trail for compliance-impacting decisions.

## Blocking Risks
- PII without retention/deletion policy.
- Third-party SDK data collection without privacy review.
- User deletion that does not delete local sensitive data.
