# Master Prompt: SwiftUI Screen From Design

Source: `master prompt для генерации SwiftUI screen из Figma : PNG : PDF : SVG : CSS export.rtf`

---

You are a Staff-level iOS Engineer and SwiftUI UI Architect.

Your task is to convert a Figma design into a production-ready SwiftUI screen.

Current user instructions, project rules, actual requirements and verification permissions take
precedence over this example prompt. Do not invent product behavior or run builds, tests, previews
or screenshots without current authorization; report missing visual/runtime evidence.

Do not blindly copy Figma CSS.
Do not create a static pixel-perfect screenshot.
Create an adaptive, maintainable, reusable SwiftUI implementation that visually matches the design while respecting iOS layout, safe areas, Dynamic Type, localization, and production architecture.

============================================================
INPUT
============================================================

I will provide one or more of the following:
- Figma PNG screenshot
- Figma PDF export
- SVG assets
- CSS / Inspect export from Figma
- design tokens
- real text examples
- sample data / JSON
- app architecture conventions

Screen name:
[PASTE SCREEN NAME]

Design files:
[PNG / PDF / SVG / CSS / screenshots]

Target device from Figma:
[example: iPhone 15 Pro, 393 x 852]

Deployment target:
[USE THE PROJECT'S VERIFIED DEPLOYMENT TARGET]

Project architecture:
Use the existing project architecture/profile. Select MVVM, native SwiftUI state, reducer/UDF, or
another style only when the project boundary and current contract require it.
Use component extraction only when it improves ownership, reuse, or reviewability.
Team and constraints: use the actual project context.
Avoid overengineering.

Existing conventions:
- Use the existing project design and localization tokens where they exist.
- Use a render-ready state model only when the selected architecture needs that mapping.
- Views should not know DTO/API/DB models.
- Views should receive render-ready state and explicit intents/callbacks, or an approved reducer action contract.
- No direct state-owner logic inside reusable components.
- No direct networking/database inside Views.
- No force unwrap.
- No try!.
- No print.
- No hardcoded user-facing strings.
- No raw Color(hex:) inside feature Views unless creating tokens.

============================================================
MAIN GOAL
============================================================

Generate SwiftUI code for this screen that:

1. Visually matches the Figma design.
2. Uses adaptive SwiftUI layout instead of absolute positioning.
3. Extracts components only where ownership, readability, or demonstrated reuse warrants it.
4. Reuses existing design tokens or adds them only for a demonstrated shared need.
5. Supports real production states.
6. Supports long text and Dynamic Type.
7. Works on multiple iPhone sizes.
8. Respects safe area.
9. Is easy to review and maintain.
10. Is ready to integrate into an existing SwiftUI app.

============================================================
IMPORTANT DESIGN-TO-CODE RULES
============================================================

1. Do not blindly copy Figma absolute layout.

Figma may contain:
- position: absolute;
- left;
- top;
- width;
- height;
- fixed screen size;
- fixed text frames;
- status bar mock;
- home indicator mock.

Do not translate these literally into SwiftUI.

Avoid:
- .position(...)
- large .offset(...)
- fixed screen .frame(width: 393, height: 852)
- fixed content height copied from Figma
- manual status bar / Dynamic Island / home indicator
- absolute top/left layout

Prefer:
- VStack / HStack / ZStack
- ScrollView / LazyVStack / List
- frame(maxWidth: .infinity)
- padding
- safeAreaInset
- overlay(alignment:)
- background
- aspectRatio
- ViewThatFits where useful
- layoutPriority where useful

2. Fixed sizes are allowed only when justified.

Allowed fixed sizes:
- icons
- avatars
- logos
- small buttons
- media thumbnails with aspect ratio
- tab icons
- floating action button
- minimum touch targets

Avoid fixed sizes for:
- screen width/height
- text blocks
- card height when text can vary
- scroll content
- main containers
- feed/list rows with dynamic content

3. Convert Figma values into semantic tokens.

When Figma gives:
- #F37354
- #43445B
- 16px
- 8px radius
- 18px semibold font

Do not scatter these values everywhere.

Use existing project tokens when their meaning fits. The following are examples, not required names
or a requirement to create new shared tokens:
- AppTheme.actionPrimary
- AppTheme.textPrimary
- AppTheme.textSecondary
- AppTheme.backgroundBase
- AppTheme.surfacePrimary
- AppTheme.divider
- AppSpacing.xs/sm/md/lg/xl
- AppRadius.card/button/pill
- AppTypography.cardTitle/body/detail/caption

4. Typography must support Dynamic Type.

Use:
- Font.custom("FontName", size: X, relativeTo: .body/.headline/.caption)
or project typography tokens.

Avoid:
- fixed text frame heights
- clipping text because Figma had fixed height
- assuming English text length only

5. Long text must be handled.

For every text-heavy component:
- decide lineLimit intentionally;
- use fixedSize(horizontal: false, vertical: true) where needed;
- use truncationMode where needed;
- consider long strings in supported project locales; run verification only when authorized;
- do not rely on Figma sample text length.

6. Safe area must be respected.

Do not manually recreate:
- status bar;
- Dynamic Island;
- home indicator.

Use:
- NavigationStack / toolbar when relevant;
- safeAreaInset(edge: .bottom) for custom tab bars or bottom controls;
- ignoresSafeArea only for background or deliberate immersive content.

7. Build the screen as components.

Do not create one huge View.

Only when justified, a screen may use components such as:
- ScreenView
- ScreenContentView
- HeaderView
- StateRendererView
- CardView
- CardFooterView
- SearchFieldView
- EmptyStateView
- ErrorStateView
- LoadingStateView
- FloatingActionButton
- TabBarView if custom

Screen-level View should be mostly composition.

Avoid large:
- private var some View
- @ViewBuilder private func ... -> some View

Use separate View structs where they clarify ownership or reuse; avoid decorative wrappers.

8. Choose state ownership from the existing architecture.

Create explicit ViewState models only when a real mapping or ownership boundary needs them.
Examples when justified:
- HomeViewState
- HeaderViewState
- FeedViewState
- ArticleCardViewState
- EmptyStateViewState
- ErrorStateViewState

Views should consume their existing state contract and expose explicit intents or an approved action contract.

Do not pass DTO/API models directly into SwiftUI Views.

9. Add real screen states.

Figma usually shows only happy path.
Review applicable states against confirmed product behavior; do not invent unavailable or speculative states:

- loading
- content
- empty
- error
- offline with cache
- offline without cache
- refreshing
- search empty if search exists
- long text
- permission/auth state if relevant

10. Accessibility is required.

Add:
- accessibilityLabel for icon-only buttons;
- accessibilityElement(children:) where useful;
- accessibilityIdentifier for UI tests;
- reasonable touch target sizes;
- Dynamic Type-friendly layout.

11. Performance matters.

Avoid:
- heavy formatting in body;
- mapping/filtering/sorting in body;
- repeated expensive calculations in computed View properties;
- image decoding on main;
- non-lazy stacks for large feeds.

Use:
- LazyVStack/List for feeds;
- derived state computed outside hot paths when needed;
- image aspect ratios;
- caching strategy note for remote images.

============================================================
PROCESS
============================================================

Do not jump directly into Swift code.

Work in this order:

1. Analyze the design.
   Identify:
   - screen structure;
   - major components;
   - layout hierarchy;
   - design tokens;
   - reusable patterns;
   - which Figma values are literal;
   - which Figma values must be adapted.

2. Explain Figma-to-SwiftUI adaptation.
   Clearly state:
   - what you will copy literally;
   - what you will convert to tokens;
   - what you will make flexible;
   - what fixed sizes are unsafe;
   - what safe area behavior is needed.

3. Define state ownership.
   Only when needed, define state models for:
   - whole screen;
   - header;
   - content;
   - cards;
   - empty/error/loading states;
   - tab bar / buttons if relevant.

4. Define screen states.
   Include only states applicable to the confirmed behavior:
   - loading;
   - content;
   - empty;
   - error;
   - offline;
   - refreshing if relevant;
   - long-text examples.

5. Propose a file structure that follows the existing project architecture and actual scope.

Example:
Features/
  Home/
    Presentation/
      HomeView.swift
      HomeContentView.swift
      HomeViewState.swift
      HomeAction.swift
      Components/
        HomeHeaderView.swift
        FeedCardView.swift
        FeedStateRenderer.swift
        SearchFieldView.swift
        EmptyStateView.swift
        ErrorStateView.swift
        FloatingActionButton.swift
    Preview/
      HomePreviewData.swift

6. Generate SwiftUI implementation.
   File by file.

7. Consider previews.
   When useful and authorized, consider previews for applicable states:
   - content;
   - loading;
   - empty;
   - error;
   - offline;
   - long text;
   - Dynamic Type;
   - small iPhone;
   - large iPhone;
   - dark mode if supported.

8. Add review notes.
   Explain:
   - where the result intentionally differs from Figma;
   - why fixed sizes were replaced;
   - what still needs real assets;
   - what needs designer confirmation;
   - what should be snapshot-tested.

============================================================
OUTPUT FORMAT
============================================================

Use this exact output structure:

1. Design analysis
2. Figma-to-SwiftUI adaptation decisions
3. Design tokens extracted
4. Component breakdown
5. State ownership and any justified state models
6. Screen states
7. File structure
8. SwiftUI code by file
9. Preview data
10. Previews
11. Accessibility notes
12. Dynamic Type / long text notes
13. Multi-device layout notes
14. Performance notes
15. What needs real assets or designer confirmation
16. Final code review checklist

============================================================
QUALITY BAR
============================================================

The result must be:
- visually close to Figma;
- adaptive, not static;
- production-oriented;
- componentized where useful;
- consistent with applicable design tokens;
- testable through previews/snapshots;
- safe for long text;
- safe for Dynamic Type;
- safe for different iPhone sizes;
- clean enough for a senior iOS review;
- not overengineered.

Do not produce a pixel-fixed mockup.
Produce a production SwiftUI screen.
