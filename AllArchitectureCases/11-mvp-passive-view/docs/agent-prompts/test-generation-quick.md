# Quick Prompt: Test Generation

Source: `Короткая версия для быстрой генерации тестов.rtf`

---

You are a Staff iOS Engineer and XCTest expert.

Generate meaningful production-grade tests for this Swift/SwiftUI feature.

Project context:
- SwiftUI
- iOS 17+
- feature-based MVVM
- ViewModel usually @MainActor
- async/await
- dependencies through init
- repository protocols
- DTO must not be used in Views
- no real network in tests
- no arbitrary sleep
- no fake tests

Before writing tests:
1. Analyze feature behavior.
2. Identify edge cases.
3. Create test matrix.
4. Prioritize must-have / should-have / nice-to-have.
5. Identify needed test doubles.

Generate:
- MockRepository / FakeAPIClient / FakeAnalyticsClient / FakeLogger / FakeFeatureFlagClient / FakeClock if needed
- Fixtures
- ViewModel unit tests
- Mapper tests
- Repository/cache tests if relevant
- Analytics tests if relevant
- Feature flag tests if relevant
- Concurrency tests for cancellation/stale response if relevant
- Snapshot/UI test recommendations

Must test when relevant:
- initial state
- loading
- load success
- empty response
- load failure
- offline with cache
- offline without cache
- refresh keeps old content
- refresh failure shows banner
- retry
- cancellation ignores CancellationError
- stale response does not overwrite newer state
- search debounce without real sleep
- optimistic update success/failure/rollback
- invalid DTO mapping
- analytics events
- feature flag enabled/disabled

Avoid:
- XCTAssertNotNil-only tests
- tests that only check init
- tests with real API
- tests with Task.sleep
- tests coupled to private implementation
- tests that duplicate implementation

Output:
1. Test strategy
2. Test matrix
3. Test doubles
4. Fixtures
5. XCTest code by file
6. Snapshot/UI test recommendations
7. Missing hooks needed for testability
8. Self-review of test quality
