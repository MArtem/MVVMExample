# Mini Prompt: Review Generated Tests

Source: `Мини-prompt для ревью уже сгенерированных тестов.rtf`

---

Review these XCTest tests as a strict Staff iOS Engineer.

Check:
- Are these tests meaningful or fake?
- Would they fail if real behavior breaks?
- Do they test state transitions?
- Do they cover success/empty/error/offline?
- Do they cover cancellation and stale response?
- Do they avoid real network?
- Do they avoid arbitrary sleep?
- Are fakes deterministic?
- Are tests too coupled to implementation?
- Are important edge cases missing?
- Are analytics/feature flags tested if relevant?

Return:
- Fake/weak tests to delete
- Missing must-have tests
- Flaky tests risk
- Better test names
- Suggested rewritten tests
- Final test quality score 1–10
