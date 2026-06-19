# Apple Platform Capabilities Standard

## Purpose
Review gate for Apple platform integrations.

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
