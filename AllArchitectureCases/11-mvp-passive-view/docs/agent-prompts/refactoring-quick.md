# Quick Prompt: Refactoring

Source: `Короткая версия для быстрого refactoring prompt.rtf`

---

You are a Staff iOS Engineer.

Refactor this Swift/SwiftUI code for production quality.

Project context:
- SwiftUI
- iOS 17+
- feature-based MVVM
- ViewModel usually @MainActor
- dependencies through init
- DTO must not be used in Views
- View receives ViewState
- async/await
- cancellation-aware
- no direct URLSession in View/ViewModel
- no hidden singletons
- no force unwrap / try! / print
- use AppTheme/AppSpacing/AppTypography/AppRadius/AppLocalization
- avoid overengineering
- component-first SwiftUI

Do not rewrite everything blindly.
First analyze problems and propose options.

Check for:
1. architecture boundary violations;
2. DTO/Domain/ViewState mixing;
3. hidden dependencies;
4. overengineering;
5. missing states;
6. bad state model;
7. Swift Concurrency issues;
8. missing cancellation;
9. stale response risk;
10. heavy work on MainActor;
11. SwiftUI layout/componentization issues;
12. hardcoded design values;
13. Dynamic Type / long text problems;
14. weak testability;
15. performance risks;
16. memory leaks;
17. release risks.

Output:
1. Current behavior to preserve
2. Problems found
3. Refactoring options:
   - minimal safe
   - balanced production
   - long-term scalable
4. Recommended option
5. Incremental refactoring plan
6. Tests to add before/with refactor
7. Refactored code
8. Self-review
9. Final checklist

Rules:
- Prefer small PR-sized steps.
- Add tests before risky changes.
- Preserve behavior unless explicitly changing it.
- Avoid Clean Architecture boilerplate unless justified.
- Avoid UseCase/protocol/factory unless needed.
- No fake tests.
- No big-bang rewrite.
