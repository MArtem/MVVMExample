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
- High-risk changes require area-specific review.
- Critical flows must not be self-approved.
- Security/privacy and migration changes require explicit gate review.
- Release branches require release engineering review.

## Output For Reviews
- Owners/reviewers needed.
- Areas reviewed.
- Areas deferred.
- Blocking findings.
