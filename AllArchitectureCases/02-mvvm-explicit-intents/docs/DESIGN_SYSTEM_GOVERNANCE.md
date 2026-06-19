# Design System Governance

## Purpose
Rules for evolving UI tokens, components, visual effects, and pixel-specific screen work.

## Token Policy
- Use existing semantic tokens when they match the design intent.
- Use local literals only for one-off pixel-perfect values or explicit design specs.
- Create a new semantic token only when value and meaning repeat.
- Do not create decorative tokens without reuse pressure.

## Component Policy
- Reuse existing components when product behavior and visual semantics match.
- Extract a component when reuse or state complexity justifies it.
- Do not hide performance-critical repeated rows behind decorative abstraction.

## Visual Effects
- Heavy shadows/materials/blur/masks/clipping in repeated UI require review.
- Animations must have clear value triggers and must respect Reduce Motion when non-essential.

## Accessibility And Localization
- Components must tolerate Dynamic Type and longer localized strings.
- Interactive controls need accessible labels/traits/hints where not obvious.
