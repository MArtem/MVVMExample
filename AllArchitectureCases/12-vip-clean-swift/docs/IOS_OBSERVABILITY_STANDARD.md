# iOS Observability Standard

## Purpose
Defines production diagnostics for crash, non-fatal error, analytics, logging, and performance instrumentation.

## Required Signals
### Crash And Non-Fatal Reporting
- Crash reporting configured before release.
- dSYM upload verified.
- Non-fatal errors reported for persistence, sync, auth, media import, and critical user actions.

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
- Debug logs can be verbose locally.
- Production logs are redacted, bounded, and action-oriented.
- Logs distinguish user-facing failures from developer diagnostics.

## Required Review Output
For any new critical flow, state:
1. What failures can happen.
2. What is logged/reported.
3. What user sees.
4. What metric proves health after release.
