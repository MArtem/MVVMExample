# iOS Configuration And Environments Standard

## Purpose
Prevent development/staging/production behavior from mixing accidentally.

## Required Rules
- Every environment must define base URLs, auth mode, logging level, feature flags, analytics/crash routing, and secret source.
- Production builds must not silently use demo/stub/local fallback services.
- Configuration must be explicit, inspectable, and testable.
- Secrets must come from secure build/runtime channels, never from committed defaults.
- Debug-only UI and logs must be gated out of production.

## Review Checklist
- Can a production build accidentally hit demo services?
- Can dev credentials ship?
- Are feature flags default-safe?
- Is environment visible in diagnostics without exposing secrets?
