---
name: ios-test-strategy
description: Use this skill to decide the right iOS verification strategy for a change: unit tests, integration tests, UI tests, manual QA, relaunch checks, migration checks, offline/network checks, performance profiling, or CI gates. Trigger whenever the user asks what/how to test, asks for verification scope, or wants production confidence.
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
- `./docs/IOS_TESTING_STRATEGY.md`
- `./TESTING_INSTRUCTIONS.md`
