---
name: ios-accessibility
description: Use this skill for iOS accessibility reviews or implementation involving VoiceOver, Dynamic Type, focus order, contrast, tap targets, Reduce Motion, forms, accessible labels, localization length, or assistive technology behavior. Trigger whenever accessibility, VoiceOver, Dynamic Type, contrast, or inclusive UX is mentioned.
---

# iOS Accessibility

## Workflow
1. Identify user-facing flows and interactive controls.
2. Check VoiceOver labels/traits/hints and focus order.
3. Check Dynamic Type, contrast, tap targets, Reduce Motion, and localized text length.
4. Report user impact, not just code style.

## Output
- Screen/flow scope.
- Findings P0-P3.
- Target state.
- Currently authorized verification and evidence gaps. Apply `DOC:CURRENT_USER_OVERRIDES.md`: omit iPad, physical-device and actual VoiceOver checks from plans and gates; mark excluded evidence `OMITTED_BY_USER`, never PASS. Preserve accessibility implementation requirements.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_ACCESSIBILITY_STANDARD.md`
