---
name: ios-product-governance
description: Use this skill for iOS product requirement reviews, acceptance criteria, non-goals, feature definition, ADR/RFC decisions, product ambiguity, and preventing guessed behavior. Trigger whenever the user asks to define a feature, clarify product behavior, review requirements, or make an architecture/product decision.
---

# iOS Product Governance

## Workflow
1. Check product requirements before implementation.
2. Identify missing acceptance criteria, states, edge cases, analytics, accessibility, localization, rollout, and non-goals.
3. Require ADR/RFC for broad architecture or irreversible decisions.
4. Ask questions instead of guessing product behavior.

## Output
- Missing requirements.
- Questions for product/user.
- ADR/RFC need.
- Implementation blockers and risks.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:PRODUCT_REQUIREMENTS_STANDARD.md`
- `DOC:ARCHITECTURE_DECISION_GOVERNANCE.md`
