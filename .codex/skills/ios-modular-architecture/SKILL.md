---
name: ios-modular-architecture
description: Use this skill for large iOS codebase architecture, modules/packages, dependency direction, feature boundaries, build performance, ownership, and developer experience. Trigger whenever the user mentions modularization, packages, architecture scaling, build time, code ownership, or large-team iOS structure.
---

# iOS Modular Architecture

## Workflow
1. Map module boundaries and dependency direction.
2. Check for circular dependencies and app-specific logic leaking into shared modules.
3. Evaluate whether extraction solves a real current problem.
4. Include build time and developer experience impact.
5. Identify owners/reviewers for high-risk areas.

## Output
- Boundary findings.
- Dependency risks.
- Recommended module/API target state.
- Build/dev-experience impact.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:MODULAR_ARCHITECTURE_STANDARD.md`
- `DOC:DEVELOPER_EXPERIENCE_STANDARD.md`
- `DOC:CODE_OWNERSHIP_AND_REVIEW_POLICY.md`
