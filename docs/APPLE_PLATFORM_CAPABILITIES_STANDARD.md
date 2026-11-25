# Apple Platform Capabilities Standard

## Purpose
Review gate for Apple platform integrations.

The mandatory reusable core is iPhone+iPad as defined by `./docs/IOS_PLATFORM_SCOPE_AND_KNOWLEDGE_POLICY.md`. Use `./docs/knowledge/global/ios/APPLE_CAPABILITIES_AND_EXTENSIONS.md` for capability prerequisites, ownership, lifecycle, alternatives, and evidence classes.

## Capability Checks
### Push Notifications
- Permission rationale, token lifecycle, payload routing, notification settings, privacy.

### Background Modes
- Justification, expiration handling, battery impact, App Store risk.

### Universal Links / Deep Links
- Validation, routing ownership, auth/session behavior, fallback.

### Widgets / App Extensions
- App Group data ownership, timeline refresh, size/performance limits, extension isolation.

### In-App Purchase / Subscriptions
- StoreKit flow, restore, receipt/server verification, entitlement state, failure states.

### Sign in with Apple
- Credential state, revocation, account linking, privacy.

### Photos / Files / Camera / Microphone
- Permissions, temporary vs durable files, privacy strings, cleanup.

### App Intents / Siri / Shortcuts
- Privacy, user confirmation, failure states, localization.

### Live Activities / Spotlight / Associated Domains / App Groups
- Authorization and token lifecycle, stable identifiers, shared-data versioning, privacy, entitlement/server configuration, stale-state recovery.

### Evidence Classification
- State separately what is statically inspectable, Simulator-verifiable, physical-device-only, multi-device/service-dependent, and distribution-dependent.
- Compilation does not prove entitlement, provisioning, account, server, region, hardware, or App Review readiness.
