# iOS Observability Standard

## Purpose
Defines production diagnostics for crash, non-fatal error, analytics, logging, and performance instrumentation.

For crash/hang diagnosis or incident telemetry, consult the relevant sections of
`./docs/knowledge/global/ios/TESTING_DEBUGGING_AND_DIAGNOSTICS.md` and
`./docs/knowledge/global/ios/PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md`; distinguish
observed evidence from proposed instrumentation.

## Required Signals
### Crash And Non-Fatal Reporting
- Define the release crash-diagnosis path and its owner, privacy, retention and availability limits.
  Configure external reporting only when the product adopts it and required consent exists.
- Verify symbolication for the adopted diagnosis path, including matching dSYM availability and
  upload where the service requires it.
- Define privacy-safe diagnostics and user-visible handling for applicable non-fatal failures in
  persistence, sync, auth, media import and critical actions; do not infer telemetry permission.

### Performance Metrics
Track or signpost where relevant:
- cold launch and warm launch
- primary list/feed scroll scenario
- media preview generation/load
- API latency and failure
- database save/load latency
- sync duration/conflict/error
- memory growth in repeated navigation/scrolling

### Analytics
- Event names are stable and documented.
- Events represent product decisions, not implementation noise.
- No PII/secrets/private payloads in event properties.

### Logging
- Debug logs may be more detailed locally, but must still exclude secrets and credentials and
  follow current privacy, minimization, redaction, retention and authorization rules for sensitive data.
- Production logs are redacted, bounded, and action-oriented.
- Logs distinguish user-facing failures from developer diagnostics.

## Required Review Output
For any new critical flow, state:
1. What failures can happen.
2. What is logged/reported.
3. What user sees.
4. What metric proves health after release.
