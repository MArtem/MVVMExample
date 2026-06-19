# Mini Prompt: Flaky Tests

Source: `Мини-prompt для flaky tests.rtf`

---

Analyze this flaky iOS test failure.

Check:
- real network usage;
- arbitrary sleep;
- async race;
- shared mutable state between tests;
- test order dependency;
- MainActor isolation;
- simulator state;
- UI animation/timing;
- missing accessibilityIdentifier;
- dependency on localized visible text;
- clock/time dependency.

Return:
1. Why the test is flaky
2. How to make it deterministic
3. Required fake/mock/clock changes
4. Rewritten test approach
5. Whether this is product bug or test bug
