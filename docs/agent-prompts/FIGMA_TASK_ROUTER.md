# Figma Task Router

## Purpose

Use this compact router first for work that starts from a Figma URL, selection, frame, or design
comparison. It keeps normal Figma tasks small while preserving the full
`figma-mcp-swiftui-implementation.md` reference for complex implementation.

## Fast Intake

Before code or Figma inspection, establish only what can change the result:

1. Exact file/frame/node and whether access works.
2. Fidelity mode: `pixel-perfect`, `native-adaptive`, or `design-system-first`.
3. Required states/variants and target devices/orientations.
4. Missing assets/fonts and the approved treatment: export, existing asset/SF Symbol, or explicit
   deferred item.
5. Intended behavior of controls when it is not visible in the design.
6. Existing project tokens/components that must be preserved.

Ask only for missing, behavior-changing answers. Do not invent navigation, persistence, API, or
other product behavior from a visual design.

## Minimum Implementation Contract

- Figma is design context, not web code: implement native SwiftUI and manually translate any CSS
  description.
- Prefer existing semantic tokens/components when they match. Keep exact one-off measurements
  local; introduce a token only for repeated semantic meaning.
- Preserve Dynamic Type, longer localization, VoiceOver semantics, contrast, safe area, and Reduce
  Motion where the visual effect is non-essential.
- Keep Views presentation-focused. Do not place DTOs, API/database work, or unrelated business
  logic in a View.
- Name changed files, required states, asset decisions, and intentional visual differences before
  implementation. Do not broaden the task into unrelated design-system or architecture work.
- Build, Simulator, screenshot, and visual comparison remain user-owned unless separately
  authorized.

## Read Depth

Always add:

- `../UI_PIXEL_PERFECT_WORKFLOW.md`
- `../DESIGN_SYSTEM_GOVERNANCE.md`

Read the deep `figma-mcp-swiftui-implementation.md` reference only when the task has multiple
screens or variants, complex Auto Layout/components, uncertain assets/fonts, a new interaction
contract, repeated visual mismatch, or an explicit request for a full Figma implementation plan.
For a simple, fully specified screen/component, this router plus the two standards is sufficient.

## Before Coding Report

```text
Figma intake:
- Access:
- Target node:
- Fidelity mode:
- Required states:
- Assets/fonts:
- Open questions:
- Deep reference loaded: yes/no and why
```

Report the changed visual target, files, skipped or run verification, and remaining visual/product
risk at completion.
