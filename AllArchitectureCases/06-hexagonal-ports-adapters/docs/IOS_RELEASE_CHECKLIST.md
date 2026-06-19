# iOS Release Checklist

## Purpose
Production release gate for TestFlight/App Store delivery.

## Checklist
### Build And Signing
- Correct bundle IDs.
- Correct entitlements and App Groups.
- Signing/provisioning profiles valid.
- Version and build number updated.
- Archive succeeds on clean machine/CI.

### App Store / TestFlight
- Privacy labels reviewed.
- Privacy manifest reviewed.
- Usage descriptions reviewed.
- Export compliance reviewed if relevant.
- TestFlight notes and review notes prepared.

### Runtime Readiness
- P0/P1 findings closed.
- Critical flows smoke-tested.
- Persistence/migration checked.
- Offline/error/session-expired states checked where relevant.
- Performance-sensitive screens exercised.

### Diagnostics
- Crash reporting configured.
- dSYM upload verified.
- Analytics/performance events verified.
- Production logging redaction verified.

### Rollout
- Feature flags/remote config defaults safe.
- Rollback/kill-switch policy known where relevant.
- Support/debug instructions prepared.
