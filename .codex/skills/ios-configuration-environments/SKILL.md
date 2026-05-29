---
name: ios-configuration-environments
description: Use this skill for iOS configuration and environment reviews involving dev/staging/production routing, base URLs, auth modes, feature flags, secrets, debug-only behavior, analytics/crash routing, and production fallback safety. Trigger whenever environment, config, staging, production, debug, feature flag, base URL, or secret source is mentioned.
---

# iOS Configuration Environments

## Workflow
1. Enumerate environments and runtime/build-time settings.
2. Check production cannot silently use demo/stub/local services.
3. Check secret sources and debug-only gating.
4. Verify flag defaults, diagnostics, analytics, and crash routing.
5. Report release verification requirements.

## References
- `./docs/IOS_CONFIGURATION_ENVIRONMENTS_STANDARD.md`
- `./docs/FEATURE_FLAGS_AND_ROLLOUTS.md`
