---
name: ios-test-strategy
description: Use this skill to choose a permission-bounded iOS verification strategy when the user asks what/how to test, requests a verification matrix, or explicitly opens a production-confidence planning phase. Do not trigger for an ordinary code review merely because verification is mentioned.
---

# iOS Test Strategy

## Workflow
1. Classify the change: UI, domain, persistence, network, auth, media, migration, release, or refactor.
2. Pick the smallest verification that proves the risk.
3. Identify applicable evidence and current permissions. Apply `DOC:CURRENT_USER_OVERRIDES.md`: omit iPad, physical-device and actual VoiceOver checks from plans and gates; mark excluded evidence `OMITTED_BY_USER`, never PASS. Report resulting confidence gaps without creating or executing tests or runtime checks without authorization.
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
