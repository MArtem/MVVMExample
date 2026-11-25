# Design System Governance

## Purpose
Rules for evolving UI tokens, components, visual effects, and pixel-specific screen work.

## Token Policy
- Use existing semantic tokens when they match the design intent.
- Use local literals only for one-off pixel-perfect values or explicit design specs.
- Create a new semantic token only when value and meaning repeat.
- Do not create decorative tokens without reuse pressure.
- Prefer semantic tokens such as `backgroundPrimary`, `textSecondary`, `actionPrimary`, and `critical` over primitive color names in feature UI.
- Component tokens are allowed when a repeated component meaning exists; they must not become a backdoor for arbitrary one-off styling.

## Component Policy
- Reuse existing components when product behavior and visual semantics match.
- Extract a component when reuse or state complexity justifies it.
- Do not hide performance-critical repeated rows behind decorative abstraction.
- Component APIs should expose product/state variants, sizes, loading/disabled/error semantics, and actions. Avoid parameter bags of raw colors, radii, fonts, shadows, offsets, and booleans that permit unlimited visual drift.
- Every reusable component must define its required states before adoption in multiple screens: light/dark, Dynamic Type, RTL where relevant, enabled, disabled, loading, error, pressed, VoiceOver, and Reduce Motion where motion exists.

## Visual Effects
- Heavy shadows/materials/blur/masks/clipping in repeated UI require review.
- Animations must have clear value triggers and must respect Reduce Motion when non-essential.

## Accessibility And Localization
- Components must tolerate Dynamic Type and longer localized strings.
- Interactive controls need accessible labels/traits/hints where not obvious.
- State must not be conveyed only by color; use text, icon/shape, accessibility value, or another semantic signal.
- Prefer real SwiftUI controls such as `Button`, `Toggle`, and `TextField` over gesture-only custom controls unless the custom control provides equivalent traits, focus, keyboard, and VoiceOver behavior.
