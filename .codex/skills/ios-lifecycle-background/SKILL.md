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
5. Select only currently authorized verification for affected flows. Apply `DOC:CURRENT_USER_OVERRIDES.md`: omit iPad, physical-device and actual VoiceOver checks from plans and gates; mark excluded evidence `OMITTED_BY_USER`, never PASS. Report unverified lifecycle behavior and do not run runtime checks without current authorization.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md`
- `DOC:APPLE_PLATFORM_CAPABILITIES_STANDARD.md`
