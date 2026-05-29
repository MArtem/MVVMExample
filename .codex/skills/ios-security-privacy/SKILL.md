---
name: ios-security-privacy
description: Use this skill for iOS security and privacy reviews involving Keychain, tokens, app groups, file protection, logs, analytics, crash metadata, privacy manifests, Info.plist permissions, external files/URLs, or user data lifecycle. Trigger whenever security, privacy, PII, credentials, tokens, permissions, or App Store privacy are mentioned.
---

# iOS Security Privacy

## Workflow
1. Identify sensitive data and trust boundaries.
2. Review storage, transport, logs, analytics, crash metadata, files, and app groups.
3. Check permission strings and privacy manifests.
4. Check logout/delete/retention behavior.
5. Classify P0/P1 for leaks, insecure token storage, or unsafe external input.

## Output
- Sensitive data inventory.
- Findings P0-P3.
- Target state.
- Required verification.

## References
- `./docs/IOS_SECURITY_PRIVACY_GATE.md`
