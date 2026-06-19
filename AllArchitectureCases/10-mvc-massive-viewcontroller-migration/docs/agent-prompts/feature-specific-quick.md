# Quick Prompt: Specific Feature

Source: `Промпт на конкретную фичу.rtf`

---

You are a Staff iOS Engineer.

Generate a production-ready SwiftUI feature using feature-based MVVM.

Before code:
1. Define assumptions.
2. Define required states.
3. Propose MVP / balanced / scalable options.
4. Choose the balanced option unless the feature is tiny.

Hard rules:
- SwiftUI, iOS 17+.
- ViewModel @MainActor.
- async/await.
- cancellation-aware.
- no stale response.
- no DTO in View.
- View receives ViewState.
- Repository protocol boundary.
- dependencies through init.
- no direct URLSession in View/ViewModel.
- no singleton hidden dependencies.
- no force unwrap / try! / print.
- no hardcoded colors/fonts/spacing/strings.
- use AppTheme/AppSpacing/AppTypography/AppRadius/AppLocalization.
- component-first SwiftUI.
- avoid large private var some View and @ViewBuilder private func helpers in screen Views.
- use separate View structs and Renderer Views.
- no heavy work in body.
- no overengineering.

Generate:
- file structure;
- ViewState;
- Action enum;
- ViewModel;
- Views/components;
- Repository protocol;
- DTO/Domain/Mapper if API-driven;
- MockRepository;
- previews for loading/content/empty/error/offline/long text;
- unit tests for success/empty/error/refresh/cancellation;
- analytics events;
- feature flag/rollback recommendation;
- self-review with blocking issues.
