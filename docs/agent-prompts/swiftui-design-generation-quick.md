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
- Use existing project design and localization tokens where they exist.
- Extract separate View structs only when they improve ownership, reuse, or reviewability.
- Avoid large private var some View and @ViewBuilder private func helpers inside screen-level Views.
- Use a render-ready state model when the selected architecture needs that mapping.
- Views render state and emit explicit intents/callbacks, or an approved reducer action contract.
- No DTO/API/DB models in Views.
- Support only the loading, content, empty, error, or offline states required by the approved feature contract.
- Support long text, Dynamic Type, iPhone SE, normal iPhone, Pro Max.
- Add accessibility labels for icon-only buttons.
- Add accessibilityIdentifiers for important UI-test targets.
- No heavy formatting/mapping/filtering in body.

Before code:
1. Analyze layout.
2. Identify existing design tokens and propose additions only when justified by the design and project.
3. Explain what from Figma is literal and what must be adapted.
4. Identify component boundaries when they improve the design or ownership.
5. Define the selected state contract.
6. Define previews only when the preview seam is in scope.

Then generate:
- file structure;
- SwiftUI components;
- state models only when needed by the selected architecture;
- preview data when previews are in scope;
- previews for relevant states and devices when previews are in scope;
- final review checklist.
