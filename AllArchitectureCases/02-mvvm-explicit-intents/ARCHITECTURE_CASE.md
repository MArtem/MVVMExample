# MVVM Explicit Intents Architecture Case

## Project
`ExplicitIntentMVVMCase`

## Goal
Full functional clone using MVVM with explicit intent methods and standalone project identity.

## Current Status
- [x] Full app functionality/design baseline copied into a standalone project name.
- [x] Source app project name removed from paths and identifiers.
- [x] Feature presentation ownership verified as MVVM explicit intents.
- [x] Build verified after identity conversion.
- [x] Test-build verified after identity conversion.

## Target State
- **View**: SwiftUI views render immutable view state and call explicit ViewModel methods such as `loginTapped()`, `refreshRequested()`, `favoriteTapped()`, `saveTapped()`, and `logoutTapped()`.
- **ViewModel**: owns screen state, cancellable tasks, user-safe error mapping, and orchestration of repository calls.
- **Domain/Data**: repositories, DTO mapping, persistence, and pending sync remain outside SwiftUI views.
- **Coordinator/Router**: navigation state only; no API, persistence, or business work.

## Architecture Review
- **Detected style**: MVVM with explicit intents plus separate navigation coordination.
- **Evidence**: presentation files retain ViewModel roles, SwiftUI screens use `@State` model ownership only to retain observable ViewModels, and UI events call named methods instead of generic dispatch.
- **Applicable gate**: dependencies enter through initializers; DTO/database/keychain types do not leak into views; row views receive narrow state/callbacks.
- **Rejected for this case**: no generic `send(_:)`, no UI action-enum reducer loop, no TCA/UDF scaffolding, no decorative use-case layer.

## Verification
- `./scripts/verify.sh static`
- `./scripts/verify.sh build`
- `./scripts/verify.sh test-build`
- Source-identity grep for stale project/product names
- Architecture grep for generic `send(_:)`, `dispatch(_:)`, and action-enum reducer boilerplate
