# iOS Production Readiness Standard

## Purpose
Defines what “production-ready” means for any iOS app before release, major feature delivery, or high-risk refactor completion.

Use together with:
- `./docs/PRODUCTION_QUALITY_GATES.md`
- `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`
- `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`
- `./docs/DEFINITION_OF_DONE.md`

## Production-Ready Definition
A change or app version is production-ready only when:
1. Product behavior is explicit and implemented without speculative behavior.
2. Core flows work through lifecycle transitions: cold launch, warm launch, foreground/background, logout/login, and relaunch.
3. Data is durable where required and recoverable after failure/restart.
4. UI is responsive under realistic data/media volume.
5. Errors, empty states, offline/degraded states, and retries are handled intentionally.
6. Security, privacy, accessibility, localization, observability, release, and verification gates are checked or explicitly marked not applicable.

## Required Review Areas
### App Lifecycle
- Cold/warm launch behavior.
- Foreground/background transitions.
- Scene/session restoration.
- Background task expiration.
- Push/deep-link entry points.
- Extension/app handoff if relevant.

### Product Contract
- Feature states are defined before implementation.
- No hidden stub/demo fallback in production runtime.
- No UI behavior is invented without product confirmation.
- Critical user actions have explicit success/failure behavior.

### Performance And Responsiveness
- Primary screens have a scroll/render performance budget.
- Main-thread work is bounded.
- Media/file/database/network work is off render paths.
- Memory use after repeated navigation/scrolling is bounded.

### Data Durability
- Persistence ownership is explicit.
- Migration/backward compatibility is reviewed.
- Logout/delete/reset behavior is defined.
- Local and remote data conflict policy is defined where sync exists.

### Security And Privacy
- Token/session storage is secure.
- PII/secrets are not logged.
- Files/app-group data use appropriate protection and backup policy.
- Privacy manifests and Info.plist usage descriptions are accurate.

### Accessibility And Localization
- VoiceOver, Dynamic Type, contrast, focus order, and hit targets are checked for user-facing UI.
- User-facing strings are localized.
- Layout tolerates longer text and larger text sizes.

### Observability
- Crash reporting and non-fatal reporting are configured before release.
- Key flows expose privacy-safe analytics/performance events.
- Production logs are redacted and actionable.

### Release Readiness
- Signing, provisioning, App Groups, entitlements, dSYM upload, build numbers, TestFlight/App Store metadata, and rollback plan are checked.

## Required Output For Readiness Review
Return:
1. Scope and exclusions.
2. Gate status: pass/fail/not applicable/remaining risk.
3. P0-P3 findings.
4. Required fixes before release.
5. Required verification before release.
