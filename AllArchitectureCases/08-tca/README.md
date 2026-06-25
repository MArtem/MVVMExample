# TCA Case

`TCACase` is a standalone full-functional architecture case that preserves the source app behavior/design while expressing presentation ownership with TCA-style Stores, typed State, typed Actions, typed Effects, and reducer-style state mutation paths.

## Project
- Xcode project: `./TCACase.xcodeproj`
- Scheme: `TCACase`
- App module folder: `./TCACase/TCACaseApp`
- Unit tests: `./TCACaseTests`
- UI smoke target: `./TCACaseUITests`

## Source Organization
- `./TCACase/TCACaseApp/AppShell/`: app composition, dependency wiring, auth gate, tab coordination, and root navigation.
- `./TCACase/TCACaseApp/Features/`: feature slices for `Auth`, `News`, and `Profile`; presentation state owners are TCA-style Stores.
- `./TCACase/TCACaseApp/Core/`: cross-feature mechanics such as design system, networking, persistence, configuration, logging, localization, image loading, and platform fallback support.
- `./TCACase/TCACaseApp/Shared/`: narrow reusable presentation helpers and accessibility identifiers.

## Architecture
- SwiftUI views call explicit Store intent methods such as `appeared()`, `loginTapped()`, `refreshRequested()`, `likeTapped(id:)`, `saveTapped()`, and `logoutTapped()`.
- Stores translate those intents into typed feature-local `Action` values.
- Stores model side effects with typed `Effect` values and execute them through Store-owned `run` methods.
- Reducer-style `reduce(_ mutation:)` methods apply synchronous state transitions only.
- Network, persistence, pending sync, routing, and cancellation behavior stay outside reducers.
- This case intentionally uses local TCA-style mechanics inside one standalone Xcode target and does not add local `./Packages` folders or third-party dependencies.

## Verification
```zsh
./scripts/verify.sh static
./scripts/verify.sh build
./scripts/verify.sh test-build
```
