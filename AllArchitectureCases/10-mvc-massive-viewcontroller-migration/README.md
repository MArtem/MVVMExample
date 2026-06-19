# MVVMExample

`MVVMExample` is an iOS 17+ SwiftUI demo/pre-production project that demonstrates a small MVVM app with explicit intent methods, typed navigation, DTO mapping, and neutral reusable infrastructure.

## Current Scope

- Auth login gate
- News list/detail flow
- Profile view/edit flow
- DummyJSON-style test API integration
- In-memory demo session store
- Minimal app-local infrastructure copied from the reusable baseline

## Architecture Rules

- ViewModels expose explicit intent methods such as `appeared()`, `loginTapped()`, `refreshRequested()`, `articleTapped(id:)`, `likeTapped(id:)`, `saveTapped()`, and `logoutTapped()`.
- Generic `send(_ action:)` ViewModel dispatch is not default project style.
- UI action enums are not used as feature boilerplate unless a reducer architecture is explicitly approved and documented by ADR.
- App-specific feature behavior stays in `./MVVMExample/`.
- This worktree intentionally has no local `./Packages` folder; minimal infrastructure lives in `./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport`.

## Demo/Test API Policy

- Test API base URL is owned by configuration.
- Demo credentials are allowed only in debug/demo mode.
- Release/production runtime must not silently use demo credentials, fake sessions, stubs, or token-like fixtures.

## Verification

```zsh
git diff --check
xcodebuild -list -project MVVMExample.xcodeproj
xcodebuild -project MVVMExample.xcodeproj -scheme MVVMExample -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Tests are not written or modified unless explicitly requested.
