# iOS Accessibility Standard

## Purpose
Accessibility gate for production iOS UI.

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
P1 by default:
- critical action inaccessible to VoiceOver
- unreadable layout under larger text
- hidden/unlabeled destructive action
- input/error state not exposed to assistive tech
