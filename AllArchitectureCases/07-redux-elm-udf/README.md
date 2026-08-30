# Redux / Elm / UDF Case

`ReduxElmUDFCase` is a standalone full-functional architecture case that preserves the source app behavior/design while expressing presentation ownership through feature-local Stores, typed Actions, typed Mutations, reducer-style state transitions, and isolated Effects.

## Project
- Xcode project: `./ReduxElmUDFCase.xcodeproj`
- Scheme: `ReduxElmUDFCase`
- App module folder: `./ReduxElmUDFCase/ReduxElmUDFCaseApp`
- Unit tests: `./ReduxElmUDFCaseTests`
- UI smoke target: `./ReduxElmUDFCaseUITests`

## Source Organization
- `./ReduxElmUDFCase/ReduxElmUDFCaseApp/AppShell/`: app composition, dependency wiring, auth gate, tab coordination, and root navigation.
- `./ReduxElmUDFCase/ReduxElmUDFCaseApp/Features/`: feature slices for `Auth`, `News`, and `Profile`; presentation state owners are feature Stores.
- `./ReduxElmUDFCase/ReduxElmUDFCaseApp/Core/`: cross-feature mechanics such as design system, networking, persistence, configuration, logging, localization, image loading, and platform fallback support.
- `./ReduxElmUDFCase/ReduxElmUDFCaseApp/Shared/`: narrow reusable presentation helpers and accessibility identifiers.

## Architecture
- SwiftUI views call explicit Store intent methods such as `appeared()`, `loginTapped()`, `refreshRequested()`, `likeTapped(id:)`, `saveTapped()`, and `logoutTapped()`.
- Stores translate those intents into typed feature-local `Action` values.
- Stores apply typed `Mutation` values through reducer-style `reduce(_ mutation:)` methods.
- Async effects remain in Store-owned tasks and repository calls; reducers do not perform network, persistence, routing, or logging side effects.
- `AppShell` owns composition and session/app flow; it does not own DTO mapping, persistence internals, or feature state transitions.
- This case intentionally uses source-level UDF boundaries inside one standalone Xcode target and does not reintroduce local `./Packages` folders.

## Verification
```zsh
./scripts/verify.sh static
./scripts/verify.sh build
./scripts/verify.sh test-build
```


## Feature-state traceability
Screen-scoped Stores intentionally keep rendered SwiftUI state public, but non-rendered cache/form/pagination state must stay named and reviewable as feature state. Do not hide new state-machine data in anonymous private fields without adding matching actions/mutations or an explicit `FeatureState` member.
