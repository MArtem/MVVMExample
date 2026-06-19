# iOS Error Handling And User Feedback Standard

## Purpose
Avoid silent failure and make user-visible operations understandable, recoverable, and supportable.

## Required Rules
- User-visible operations must have loading, success, failure, retry, cancellation, and partial-success behavior where applicable.
- Do not collapse distinct technical errors into one product behavior unless explicitly intended.
- Error messages must be localized, actionable, and not leak internal implementation details.
- Critical failures must be observable through logs/crash/analytics without exposing sensitive data.
- Optimistic UI must define revert, retry, or pending-state behavior if persistence/network fails.

## Review Checklist
- What does the user see?
- Can the user retry?
- Is data safe after failure?
- Is support/debug information available without leaking secrets?
- Are errors accessible to VoiceOver users?
