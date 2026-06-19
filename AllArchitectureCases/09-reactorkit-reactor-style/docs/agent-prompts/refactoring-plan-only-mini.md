# Mini Prompt: Refactoring Plan Only

Source: `Мини-prompt для “сначала только план refactor, без кода”.rtf`

---

You are a Staff iOS Architect.

Analyze this code and create an incremental refactoring plan.
Do not write code yet.

Context:
- SwiftUI
- feature-based MVVM
- iOS 17+
- production app
- small team
- avoid overengineering

For the provided code, return:

1. Current behavior to preserve
2. Main problems
3. Risk level
4. Minimal safe refactor
5. Balanced production refactor
6. Long-term scalable refactor
7. Recommended option
8. Step-by-step PR plan
9. Tests to add before each step
10. Rollback strategy
11. What not to refactor now

Focus on:
- architecture boundaries;
- state management;
- Swift Concurrency;
- testability;
- SwiftUI componentization;
- design tokens;
- performance;
- release risk.
