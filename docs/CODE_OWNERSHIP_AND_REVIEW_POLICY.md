# Code Ownership And Review Policy

## Purpose
Defines review ownership for large iOS projects.

## Ownership Areas
- Product/domain behavior
- UI/design system
- Persistence/migration
- Networking/API/sync
- Security/privacy
- Accessibility
- Release/signing/CI
- Observability/performance

## Review Rules
For shared changes, identify the existing module/feature reviewer and escalation owner; do not
invent a team process or bottleneck. Explain contract/evidence trade-offs rather than rewriting
to reviewer preference. Process automation needs demonstrated gate signal or recurring-cost
benefit and separate authorization.

- High-risk changes require area-specific review.
- Critical flows must not be self-approved.
- Security/privacy and migration changes require explicit gate review.
- Release branches require release engineering review.

Where the existing project contract requires it, record review response expectations, escalation
and backup ownership/knowledge continuity for critical modules and incident paths. Identify
single-owner bottlenecks without inventing people, staffing targets or an unapproved review SLA.

## Output For Reviews
- Owners/reviewers needed.
- Areas reviewed.
- Areas deferred.
- Blocking findings.
