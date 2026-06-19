# MVVMExample Test Coverage Plan

## Purpose
Define the staged test coverage plan for `MVVMExample` without writing tests yet.

This plan follows the current project rule: tests are not added or modified until the user explicitly opens a test-writing phase.

## Current Test Baseline

Current project inspection shows:

- App target exists: `MVVMExample`.
- No app test target is currently present in `MVVMExample.xcodeproj`.
- No `.xctestplan` file is currently present.
- Local package schemes exist for standalone `App*` packages modules.

Before implementation, create test targets deliberately rather than mixing tests into the app target.

## Testing Stack

### Unit Tests
Use Swift Testing by default:

- `import Testing`
- `@Suite`
- `@Test`
- `#expect`
- `#require` when later assertions depend on an unwrapped/precondition value
- parameterized tests for repeated input/output cases

### XCTest
Keep XCTest for:

- UI automation through `XCUIApplication`
- performance metrics through `XCTMetric`
- launch-flow smoke tests where UI automation is required

### Test Isolation Rules

- Tests must be parallel-safe by default.
- Prefer isolated in-memory dependencies over `.serialized`.
- Use `.serialized` only as a temporary transition with a written rationale.
- No live network calls in unit tests.
- No production credentials, demo tokens, or token-like fixtures that can be mistaken for real secrets.

## Deterministic Async Testing Rules

ViewModel and repository tests must not rely on timing as the primary synchronization mechanism.

Required rules:

- do not use `Task.sleep` or polling loops as the main way to wait for state;
- use controllable fake repositories that complete via stored continuations or explicit `Result` queues;
- test cancellation and stale-result behavior by completing async operations in a controlled order;
- isolate state per test instead of marking suites `.serialized`;
- use `.serialized` only when an external shared resource cannot be isolated and document why.

These rules apply especially to `NewsListViewModel` pagination, refresh, like/favorite flows, and `ProfileEditViewModel` save behavior.

## Proposed Test Target Layout

### Package Tests

Package tests are not active in this worktree because local package folders were removed. Infrastructure behavior should be covered through app/unit tests when the user explicitly opens a test-writing phase.

Required `.testTarget` setup:

```swift
.testTarget(
    name: "AppConfigurationTests",
    dependencies: ["AppConfiguration"]
),
.testTarget(
    name: "AppNetworkingTests",
    dependencies: ["AppNetworking", "AppErrors", "AppConfiguration", "AppLogging"]
),
.testTarget(
    name: "AppLocalizationTests",
    dependencies: ["AppLocalization", "AppErrors"]
),
.testTarget(
    name: "AppImageLoadingTests",
    dependencies: ["AppImageLoading", "AppErrors"]
)
```

Expected folders:

```text
./Packages/<AppPackage>/Tests/AppConfigurationTests/
./Packages/<AppPackage>/Tests/AppNetworkingTests/
./Packages/<AppPackage>/Tests/AppLocalizationTests/
./Packages/<AppPackage>/Tests/AppImageLoadingTests/
```

### App Tests

Create an actual `MVVMExampleTests` target in `./MVVMExample.xcodeproj`; a folder alone is not sufficient.

Required integration:

- create `./MVVMExampleTests/` and add it to the `MVVMExampleTests` target;
- use `@testable import MVVMExample` from app unit tests;
- ensure app source visibility is through the test target, not by copying app files into tests;
- connect the target to the project scheme or `.xctestplan` so CI and local `xcodebuild test` run it.

Recommended folders:

```text
./MVVMExampleTests/Auth/
./MVVMExampleTests/News/
./MVVMExampleTests/Profile/
./MVVMExampleTests/TestSupport/
```

### UI Tests Later

Create a separate `MVVMExampleUITests` target only after unit coverage is stable.

Required integration:

- keep UI tests in `./MVVMExampleUITests/`;
- do not mix UI automation into the app unit test target;
- configure the `.xctestplan` so unit and UI tests can run in separate configurations/CI lanes;
- keep UI tests slower and fewer than unit tests.

```text
./MVVMExampleUITests/
```

### Xcode Test Plan

Create and attach an `.xctestplan` to the `MVVMExample` scheme before considering test setup complete.

Acceptance:

- package tests run through the iOS package scheme because standalone `App*` packages contains UIKit-backed iOS code:

```zsh
for pkg in AppErrors AppLogging AppConfiguration AppLocalization AppNetworking AppImageLoading AppGlassUI; do
  ./Packages/$pkg/Scripts/verify_package.sh
done
```

- app unit tests run through the Xcode scheme/test plan:

```zsh
xcodebuild test -project MVVMExample.xcodeproj -scheme MVVMExample -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO
```

- UI tests are a separate configuration/lane after `MVVMExampleUITests` exists;
- local and CI commands cannot silently skip a created test folder because no target references it.


## Test Support Minimalism Stop Rules

Test support must not become a parallel architecture.

Stop rules:

- no mega `TestAppFactory`;
- no protocols created only for tests unless the boundary is also correct for runtime;
- colocate test doubles by feature unless reused three or more times;
- use `TestSupport` only for genuinely reused helpers;
- do not change production code only to satisfy tests;
- production changes for testability are allowed only when they create a correct runtime dependency seam.

## Coverage Phases

## Phase 1 — Test Infrastructure

Goal: create the minimum reliable test harness.

Scope:

1. Add app unit test target.
2. Add package test targets where package ownership needs direct testing.
3. Add an `.xctestplan` with clear grouping:
   - infrastructure unit tests;
   - app unit tests;
   - UI tests later, disabled until created.
4. Add test support helpers only where they remove real duplication:
   - fake repositories;
   - controllable network client/session;
   - deterministic image data builder;
   - no broad factory layer.

Acceptance:

- Test targets compile.
- Empty or smoke tests run successfully.
- Tests do not require live network or simulator UI.

## Phase 2 — Standalone Package Unit Tests

Goal: cover reusable infrastructure contracts first because app features depend on them.

### `AppConfiguration`

Files:

- `./Packages/<AppPackage>/Sources/AppConfiguration/APIConfiguration.swift`
- `./Packages/<AppPackage>/Sources/AppConfiguration/SessionStore.swift`

Test cases:

1. Missing `MVVMEXAMPLE_API_BASE_URL` uses demo default only through documented fallback.
2. Valid explicit `MVVMEXAMPLE_API_BASE_URL` is accepted.
3. Invalid explicit `MVVMEXAMPLE_API_BASE_URL` fails fast or is covered through an extracted throwing validator if implementation is adjusted for testability.
4. `MVVMEXAMPLE_ALLOW_DEMO_CREDENTIALS` parses `1`, `true`, and default behavior correctly.
5. `MVVMEXAMPLE_API_TIMEOUT_SECONDS` applies timeout override.
6. `InMemorySessionStore` saves and clears session state.

### `AppNetworking`

Files:

- `./Packages/<AppPackage>/Sources/AppNetworking/URLSessionNetworkClient.swift`
- `./Packages/<AppPackage>/Sources/AppNetworking/JSONRequestBodyEncoder.swift`
- `./Packages/<AppPackage>/Sources/AppNetworking/NetworkPrimitives.swift`

Test cases:

1. Request body encoding errors propagate as `AppAPIError.encoding`.
2. Non-HTTP response maps to `AppAPIError.invalidResponse`.
3. HTTP `401` maps to `.unauthorized`.
4. HTTP `403` maps to `.forbidden`.
5. Other non-2xx statuses map to `.server`.
6. Decoding failure maps to `.decoding`.
7. Offline and timeout `URLError` map to `.offline` / `.timeout`.
8. Cancellation maps to `.cancelled`.
9. Idempotent GET retry is attempted according to policy.
10. Non-idempotent mutations are not retried by default.
11. Logged URLs redact sensitive query fields and credentials.

### `AppLocalization`

Files:

- `./Packages/<AppPackage>/Sources/AppLocalization/AppErrorMapper.swift`
- `./Packages/<AppPackage>/Sources/AppLocalization/AppStrings.swift`

Test cases:

1. Every `AppAPIError` maps to a user-safe message.
2. Unknown errors map to generic retry-safe copy.
3. Mapping does not expose technical transport strings directly.

### `AppImageLoading`

Unit-test the pipeline and cache. Do not deeply unit-test SwiftUI view lifecycle for `CachedRemoteImageView` without a justified UI inspection dependency.

Files:

- `./Packages/<AppPackage>/Sources/AppImageLoading/ImageMemoryCache.swift`
- `./Packages/<AppPackage>/Sources/AppImageLoading/RemoteImagePipeline.swift`
- `./Packages/<AppPackage>/Sources/AppImageLoading/CachedRemoteImageView.swift`

Unit test cases:

1. Cache key includes URL and target pixel size.
2. Memory cache stores and returns images for exact keys.
3. Downsampled image respects target dimensions within scale tolerance.
4. Invalid image data maps to decoding failure.
5. Non-2xx image response maps to invalid response.
6. Pipeline cancellation is verified where it can be observed without SwiftUI lifecycle inspection.

Light UI/manual validation later:

1. Placeholder has stable size.
2. Failure view appears for failed loads.
3. Loaded image replaces placeholder.
4. Disappearing/reappearing list rows do not visibly publish stale images.

## Phase 3 — Domain / Mapping Tests

Goal: cover data boundary correctness before ViewModel behavior.

### Auth

Files:

- `./MVVMExample/MVVMExampleDemo/Features/Auth/Data/AuthMapper.swift`
- `./MVVMExample/MVVMExampleDemo/Features/Auth/Data/AuthRequests.swift`

Test cases:

1. Login request encodes expected body and expiration.
2. Auth DTO maps to `AuthSession` without exposing DTO types.

### News

Files:

- `./MVVMExample/MVVMExampleDemo/Features/News/Data/API/NewsRequests.swift`
- `./MVVMExample/MVVMExampleDemo/Features/News/Data/Mapping/NewsDTOMapper.swift`
- `./MVVMExample/MVVMExampleDemo/Features/News/Domain/ArticleInteractionStore.swift`

Test cases:

1. List request uses `limit` and `skip` query items.
2. Detail request path is stable.
3. Like mutation request body is throwing and encodes `isLiked`.
4. DTO mapper handles valid image URLs.
5. DTO mapper handles invalid/missing image URLs without crashing.
6. Date parsing is deterministic.
7. `ArticleInteractionStore` merges updated like state into list and detail articles.
8. Like count never becomes negative.

### Profile

Files:

- `./MVVMExample/MVVMExampleDemo/Features/Profile/Data/API/ProfileRequests.swift`
- `./MVVMExample/MVVMExampleDemo/Features/Profile/Data/Mapping/ProfileDTOMapper.swift`

Test cases:

1. Current-user request sets bearer authorization header.
2. Profile update request encodes first name, last name, and email separately.
3. Profile DTO maps `firstName` / `lastName` without deriving from `displayName`.

## Phase 4 — ViewModel Behavior Tests

Goal: verify user-visible state machines and side effects.

### `LoginViewModel`

Files:

- `./MVVMExample/MVVMExampleDemo/Features/Auth/Presentation/LoginViewModel.swift`

Test cases:

1. `loginTapped()` trims username and calls repository.
2. Success clears loading and emits `onLoginSuccess` exactly once.
3. Failure clears loading and uses `AppErrorMapper` message.
4. Cancellation does not publish error.
5. Demo credentials button is present only when credentials are injected.
6. `useDemoCredentialsTapped()` fills fields and clears error.

### `NewsListViewModel`

Files:

- `./MVVMExample/MVVMExampleDemo/Features/News/Presentation/List/NewsListViewModel.swift`
- `./MVVMExample/MVVMExampleDemo/Features/News/Presentation/List/NewsListViewStateBuilder.swift`

Test cases:

1. `appeared()` loads first page once from idle.
2. Empty first page becomes `.empty`.
3. First-page failure becomes full-screen `.error`.
4. `refreshRequested()` preserves content on failure and shows banner.
5. Refresh success replaces first page and resets pagination.
6. `loadNextPageIfNeeded(currentItemID:)` triggers only near threshold.
7. Duplicate pagination requests are prevented while a page is loading.
8. Pagination failure keeps existing content and sets footer error.
9. Like success updates only the matching card state.
10. Like failure marks only the matching card as failed and shows banner.
11. `articleTapped(id:)` routes only when the card exists.
12. Cancellation is ignored and does not overwrite latest state.

### `NewsDetailViewModel`

Files:

- `./MVVMExample/MVVMExampleDemo/Features/News/Presentation/Detail/NewsDetailViewModel.swift`

Test cases:

1. `appeared()` loads detail and publishes content.
2. Load failure without content publishes full-screen error.
3. Favorite success updates content and shared interaction store.
4. Favorite failure rolls back optimistic state and keeps content visible.
5. Cancellation does not show error.

### `ProfileViewModel`

Files:

- `./MVVMExample/MVVMExampleDemo/Features/Profile/Presentation/Profile/ProfileViewModel.swift`

Test cases:

1. `appeared()` loads profile.
2. Load failure maps to full-screen error.
3. `profileUpdated(_:)` updates content from edit flow result without another fetch.
4. `editTapped()` routes only from content state.
5. `logoutTapped()` delegates to app owner.

### `ProfileEditViewModel`

Files:

- `./MVVMExample/MVVMExampleDemo/Features/Profile/Presentation/Edit/ProfileEditViewModel.swift`

Test cases:

1. Initial form preserves first name, last name, and email from payload.
2. Save trims all editable fields.
3. Save success calls `onSaveSuccess` with updated profile and pops route.
4. Save failure uses `AppErrorMapper.userMessage(for:)`.
5. Cancellation does not show error.
6. Repeated save cancels previous save task.

## Phase 5 — View State Builder Tests

Goal: keep UI formatting out of SwiftUI hot paths and make state output deterministic.

Files:

- `./MVVMExample/MVVMExampleDemo/Features/News/Presentation/List/NewsListViewStateBuilder.swift`
- `./MVVMExample/MVVMExampleDemo/Features/News/Presentation/Detail/NewsDetailViewStateBuilder.swift`
- `./MVVMExample/MVVMExampleDemo/Features/Profile/Presentation/Profile/ProfileViewStateBuilder.swift`

Test cases:

1. News card state precomputes `sourceDisplayText`.
2. Like icon and accessibility labels reflect like state.
3. Comments accessibility label matches comments text.
4. Pagination footer states expose user-safe messages.
5. Detail favorite state exposes non-blocking error message separately from full-screen error.
6. Profile state builder preserves `firstName` and `lastName` separately.

## Phase 6 — Navigation / Integration Unit Tests

Goal: cover app-owned route transitions without UI automation.

Files:

- `./MVVMExample/MVVMExampleDemo/App/AppRootCoordinator.swift`
- `./MVVMExample/MVVMExampleDemo/App/MainCoordinator.swift`
- `./MVVMExample/MVVMExampleDemo/Features/News/Navigation/NewsRouter.swift`
- `./MVVMExample/MVVMExampleDemo/Features/Profile/Navigation/ProfileRouter.swift`

Test cases:

1. Login success stores session and moves root scene to main.
2. Logout clears session, resets main coordinator, and returns to login.
3. Main logout resets feature routers before app logout.
4. News router opens detail and can reset path.
5. Profile router opens edit and can reset path.

## Phase 7 — UI Smoke Tests

Goal: validate only critical user flows after unit coverage is stable.

Use XCTest UI tests.

Flows:

1. App launches to login when no session exists.
2. Demo credentials button appears only in allowed debug/demo configuration.
3. Login reaches main tabs.
4. News list loads and opens detail.
5. Pull-to-refresh does not break visible content.
6. Profile opens edit, saves, and updated values are visible after returning.
7. Logout returns to login.

Accessibility smoke checks:

1. Login fields and buttons are reachable and labelled.
2. News card open action does not hide like/comment controls from accessibility traversal.
3. Profile edit fields and save/cancel buttons are reachable and labelled.
4. Loading and error states expose understandable labels/messages.

Constraints:

- UI tests should use controlled demo configuration.
- Avoid asserting fragile layout details.
- Accessibility identifiers should be added intentionally only for stable controls and screens.

## Phase 8 — Performance / Regression Tests

Use XCTest performance only after functional coverage is reliable.

Candidates:

1. `NewsListViewStateBuilder` large input mapping cost.
2. `RemoteImagePipeline` downsampling memory behavior with fixture images.
3. Pagination state update path with many cards.
4. ViewModel like update cost for a large list.

Profiler/Instruments remains required for real scroll-hitch and memory validation; performance tests only catch regressions in deterministic code paths.

Required profiler scenarios before claiming smoothness or leak-free behavior:

1. Scroll news list with cold image cache.
2. Scroll news list with warm image cache.
3. Append pagination near bottom.
4. Rapid like/favorite taps in list and detail.
5. Open/close profile image and detail image flows repeatedly.
6. Repeat scroll/navigation loops and check memory growth.

Evidence rule:

- Without a profiler run, completion reports may say only `static/perf-unit clean`.
- Do not claim `smooth`, `no leaks`, or `memory stable` without Instruments/profiler evidence.

## CI / Quality Gates

Recommended order once tests exist:

```zsh
# static
./scripts/run_static_quality_gates.sh

# package tests
# Package folders are not present in this worktree. Use app/Xcode verification instead.

# app unit tests
xcodebuild test \
  -project MVVMExample.xcodeproj \
  -scheme MVVMExample \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0'
```

UI tests should be separate from unit tests and may run in a slower CI lane.

## Initial Priority Order

1. Create test targets/test plan.
2. standalone package configuration/network/error/image tests.
3. Profile edit/save regression tests for the latest findings.
4. News list pagination/refresh/like ViewModel tests.
5. Detail favorite rollback tests.
6. Login/session coordinator tests.
7. UI smoke flow for profile edit save visibility.
8. Performance regression tests and Instruments validation.

## Definition Of Done For First Test Phase

The first test-writing phase is complete when:

- app and package test targets compile;
- critical infrastructure tests pass;
- profile edit save regression is covered;
- no tests use live network;
- all new tests are deterministic and parallel-safe;
- no production code imports `Testing`;
- static quality gates and targeted test command pass.
