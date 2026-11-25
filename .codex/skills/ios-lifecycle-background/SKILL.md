---
name: ios-lifecycle-background
description: Review or change iOS app or extension lifecycle behavior, including launch/scene transitions, background execution, notification or deep-link entry, and widget/extension execution boundaries; not for an incidental mention of these surfaces or a UI-only text/layout change.
---

# iOS Lifecycle Background

## Workflow
1. Map the entry, transition, and exit paths affected by the task.
2. Check startup work budget, cancellation, and observability when launch or activation is affected.
3. Check background task triggers, deadlines, retry, and user-visible effects when background execution is affected.
4. Check extension/widget independence from app process memory when their execution or shared data is affected.
5. Report verification needed for simulator/device/manual flows.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md`
- `DOC:APPLE_PLATFORM_CAPABILITIES_STANDARD.md`
