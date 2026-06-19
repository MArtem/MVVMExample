# iOS App Lifecycle And Background Work Standard

## Purpose
Make lifecycle, scene, background, push, widgets, extensions, and deep-link behavior predictable.

## Required Rules
- App, scene, session, and feature state must have explicit owners.
- Startup work must be bounded, prioritized, and observable.
- Background work must declare trigger, deadline, cancellation, retry, and user-visible effect.
- Deep links and notifications must route through domain/navigation ownership, not view implementation details.
- Widgets/extensions must not depend on app process memory.
- Background modes and entitlements require product justification and release verification.

## Review Checklist
- What runs on cold launch?
- What runs on foreground activation?
- What survives scene recreation?
- Can background work race with manual refresh?
- Are pending deep links preserved across auth/session transitions?
