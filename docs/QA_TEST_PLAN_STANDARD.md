# QA Test Plan Standard

## Purpose
Provides reusable QA planning artifacts for production iOS releases and critical features.

Planning scope: apply [USER.VERIFICATION.SCOPE](CURRENT_USER_OVERRIDES.md#verification-and-quality).
Exclude all iPad verification and every physical-device check, including actual VoiceOver,
from plans and exit gates. Keep implementation requirements, source-level accessibility
review and permitted iPhone Simulator checks; exclusion does not establish coverage.

## Test Plan Sections
- Scope
- Devices/iOS versions
- Accounts/test data
- Critical paths
- Regression areas
- Offline/network scenarios
- Accessibility scenarios
- Localization scenarios
- Media/file scenarios
- Migration/relaunch scenarios
- Known risks
- Exit criteria

## Smoke Matrix Template
- Flow
- Steps
- Expected result
- Device/iOS
- Pass/fail
- Notes

## Critical iPhone journey selection

Use for a new app/critical feature or platform-sensitive change, not every text edit. Start from the
app-owned supported/runtime matrix and current permissions. An example iPhone18.2/27 pair means
those selected runtimes only; it neither changes deployment floors nor establishes latest-version,
intermediate-version, iPad, hardware or release coverage. Missing approved runtimes remain unavailable;
never install one implicitly. Apply current user exclusions before constructing the plan.

| Trigger | Smallest relevant scenario | Observable acceptance |
| --- | --- | --- |
| Search/navigation/container change | Open search, enter/replace/clear query, leave/return; include keyboard submit/dismiss. | Search remains reachable; latest criteria/results persist as intended; obsolete error does not replace them. |
| Sheet/composer/draft ownership | Present, edit, cancel, reopen; then separately submit when submission changed. | No accidental publication; fresh/restored draft matches the product contract. |
| Layout/localization change | Relevant compact iPhone size, supported orientation, long/RTL content and affected Dynamic Type boundary. | Required text/actions remain visible and operable; no invented translation or global locale mutation. |
| Failure/retry/offline path | Trigger the actual error boundary, retry with retained input, include permission denial if involved. | Error differs from empty success; retry produces the intended state without duplicate durable action. |
| Persistence/session boundary | Relaunch after committed save; change account/logout during outstanding work when applicable. | Agreed data/session ownership survives or is cleared; old owner cannot republish. |

For each selected row record initial state, steps, expected result, exact configuration/runtime,
composition deltas, source digest/SHA, actual result and evidence status. Use pairwise/risk selection;
do not multiply every locale/size/state/runtime into a blanket Cartesian suite. A snapshot may
support visual layout but does not replace interaction/state assertions. The fixture/composition
contract is owned by the testing deep reference. Unexecuted rows stay NOT_RUN, not successful plans.
Maintenance: QA owner; revisit on product journey, supported runtime or observed compatibility defect.
