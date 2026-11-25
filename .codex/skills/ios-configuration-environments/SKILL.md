---
name: ios-configuration-environments
description: Review or change iOS environment selection, build configuration, base URLs, feature flags, secret sources, debug-only behavior, or production fallback; not for an incidental mention of production or debug.
---

# iOS Configuration Environments

## Workflow
1. Identify the affected environment and build-time/runtime selection path; enumerate other environments only when the contract crosses them.
2. Check that production cannot silently use demo/stub/local services, and inspect relevant secret sources and debug-only gating without opening real secrets.
3. Check affected flag defaults, diagnostics, analytics, and crash routing; report release verification requirements and unknowns.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_CONFIGURATION_ENVIRONMENTS_STANDARD.md`
- `DOC:FEATURE_FLAGS_AND_ROLLOUTS.md`
