---
name: ios-test-strategy
description: Use this skill to choose a permission-bounded iOS verification strategy when the user asks what/how to test, requests a verification matrix, or explicitly opens a production-confidence planning phase. Do not trigger for an ordinary code review merely because verification is mentioned.
---

# iOS Test Strategy

## Workflow
1. Classify the change: UI, domain, persistence, network, auth, media, migration, release, or refactor.
2. Pick the smallest verification that proves the risk.
3. Identify what build/tests/manual/profiling are required for production confidence.
4. State what is intentionally deferred and the remaining risk.

## Output
- Change classification.
- Required verification matrix.
- Commands/manual scenarios.
- Remaining risks.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_TESTING_STRATEGY.md`
- Project-root `TESTING_INSTRUCTIONS.md`, when present; resolve from the active project root, not this skill directory.
