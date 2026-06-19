# Quick Prompt: SwiftUI Screen From Design

Source: `Короткая версия SwiftUI screen from Figma для быстрой задачи.rtf`

---

You are a Staff iOS Engineer.

Convert this Figma design into production-ready SwiftUI.

Rules:
- Do not blindly copy Figma CSS.
- Do not use absolute positioning from Figma.
- Do not use fixed screen width/height.
- Fixed size only for icons, avatars, small controls, FAB, or media aspect ratio.
- Use adaptive SwiftUI layout: VStack/HStack/ZStack, ScrollView/LazyVStack, frame(maxWidth: .infinity), padding, safeAreaInset, aspectRatio.
- Do not manually draw status bar, Dynamic Island, or home indicator.
- Use design tokens: AppTheme, AppSpacing, AppTypography, AppRadius.
- Use AppLocalization for strings.
- Break UI into separate View structs.
- Avoid large private var some View and @ViewBuilder private func helpers inside screen-level Views.
- Use ViewState models.
- Views render ViewState and emit actions/callbacks.
- No DTO/API/DB models in Views.
- Support loading, content, empty, error, offline states.
- Support long text, Dynamic Type, iPhone SE, normal iPhone, Pro Max.
- Add accessibility labels for icon-only buttons.
- Add accessibilityIdentifiers for important UI-test targets.
- No heavy formatting/mapping/filtering in body.

Before code:
1. Analyze layout.
2. Extract design tokens.
3. Explain what from Figma is literal and what must be adapted.
4. Define components.
5. Define ViewState.
6. Define previews.

Then generate:
- file structure;
- SwiftUI components;
- ViewState models;
- preview data;
- previews for content/loading/empty/error/offline/long text/Dynamic Type/small device/large device;
- final review checklist.
