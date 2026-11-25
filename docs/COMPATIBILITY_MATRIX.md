# Compatibility Matrix

## Purpose
Tracks supported runtime compatibility across devices, OS versions, app versions, extensions, and backend contracts.

Planning scope: apply [USER.VERIFICATION.SCOPE](CURRENT_USER_OVERRIDES.md#verification-and-quality).
Exclude all iPad verification and every physical-device check, including actual VoiceOver,
from plans and exit gates. Keep implementation requirements, source-level accessibility
review and permitted iPhone Simulator checks; exclusion does not establish coverage.

## Matrix Dimensions
- Xcode/toolchain and compiler version
- Swift language mode and strict-concurrency settings
- SDK version and default actor isolation
- upcoming language features and stability status
- iOS versions
- device classes and screen sizes
- permitted iPhone Simulator destinations
- app versions
- backend/API versions
- persistence schema versions
- app extensions/widgets
- localization/RTL support
- feature flag states
- App Store Connect upload SDK/Xcode floor (separate from deployment target)
- privacy manifest/API/SDK/data-flow agreement
- launch, interaction, frame/hitch, main-thread and memory budgets
- VoiceOver, Dynamic Type, contrast, Reduce Motion, RTL, keyboard/pointer and window support
- experimental capability/model availability and fallback

## Entry Template
- Area
- Supported versions/devices
- Required verification
- Known limitations
- Owner
- Source revision/date and evidence status

## Journey evidence

Bind each approved runtime row to selected critical journeys using
[QA journey selection](QA_TEST_PLAN_STANDARD.md#critical-iphone-journey-selection).
Compilation/API availability, fixture UI, ordinary launch and visual checks are separate evidence.
Record exactly which runtime/configuration was observed; one version does not stand for a range.
