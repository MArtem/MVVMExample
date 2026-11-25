# iOS Accessibility Standard

## Purpose
Accessibility gate for production iOS UI.

Record applicable permitted iPhone Simulator and source-review coverage for Dynamic Type, RTL,
keyboard/pointer, contrast and Reduce Motion in `./docs/IOS_RELEASE_PRIVACY_PERFORMANCE_MATRIX.md`.
Preserve accessibility implementation requirements across supported platforms without adding excluded
iPad, physical-device or actual VoiceOver checks to the matrix. A screenshot is supporting visual
evidence only; it does not prove assistive-technology or device behavior.

Planning scope: apply [USER.VERIFICATION.SCOPE](CURRENT_USER_OVERRIDES.md#verification-and-quality).
Exclude all iPad verification and every physical-device check, including actual VoiceOver,
from plans and exit gates. Keep implementation requirements, source-level accessibility
review and permitted iPhone Simulator checks; exclusion does not establish coverage.

## Required Checks
- VoiceOver labels, traits, hints, and grouping.
- Logical focus order.
- Dynamic Type support and layout resilience.
- Sufficient contrast in light/dark modes.
- Tap targets meet platform guidance.
- Reduce Motion respected for non-essential animation.
- Important state changes are announced when needed.
- Forms expose validation errors accessibly.
- Media has accessible labels/metadata where product requires it.

## Blocking Issues
Classify demonstrated impact with `IOS_PRODUCTION_AUDIT_MATRIX.md`; keep confidence and
applicability separate under `UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md`. A category
name alone does not assign severity. Blocking examples include:
- critical action inaccessible to VoiceOver
- unreadable layout under larger text
- hidden/unlabeled destructive action
- input/error state not exposed to assistive tech

## Explanation And Failure Trace
A visual icon and its accessible action are separate consumers of the same product intent.
A decorative image need not become an extra focus stop; an actionable custom control needs
an exposed name, role, value and supported action. Group related output according to the
user's task, not merely the view tree. Prefer a native control when it already supplies the
right behavior; add custom semantics when the actual interaction requires them.

For example, a save operation still loading has an unknown result. Announcing a default
`false` value as “not saved” invents an outcome. Trace pending, success and failure through
both the visual and accessible presentation. Check long localized labels, large text and
alternative cues for motion/color. Source review supports the mapping only; actual traversal
and hardware experience remain unverified under the current exclusion.

Primary theory: [Apple accessibility guidance](https://developer.apple.com/design/human-interface-guidelines/accessibility)
and [localization guidance](https://developer.apple.com/localization/). The shared deep
interaction model is `knowledge/global/ios/SWIFTUI_UIKIT_AND_ADAPTIVE_IPAD_UI.md`, sections
Accessible And Localized Interaction Review and Evidence Matrix; select it only for that subtask.
