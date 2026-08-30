# Explicit Intent MVVM Case

`ExplicitIntentMVVMCase` is a standalone full-functional architecture case that preserves the app behavior/design while using MVVM with explicit user-intent methods.

## Project
- Xcode project: `./ExplicitIntentMVVMCase.xcodeproj`
- Scheme: `ExplicitIntentMVVMCase`
- App module folder: `./ExplicitIntentMVVMCase/ExplicitIntentMVVMCaseApp`
- Unit tests: `./ExplicitIntentMVVMCaseTests`
- UI smoke target: `./ExplicitIntentMVVMCaseUITests`

## Architecture
- SwiftUI views render state and call explicit ViewModel intent methods.
- ViewModels own screen-level loading/error/content state and async task lifecycle.
- Repositories and local persistence are injected; views do not create API, database, or keychain clients.
- Coordinators/routers own navigation state only.

## Verification
```zsh
./scripts/verify.sh static
./scripts/verify.sh build
./scripts/verify.sh test-build
```
