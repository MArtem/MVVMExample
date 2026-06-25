# ReactorKit / Reactor-style Case

`ReactorStyleCase` is a standalone full-functional architecture case that preserves the source app behavior/design while expressing presentation ownership with feature-local Reactors and Action → Mutation → State flow.

## Project
- Xcode project: `./ReactorStyleCase.xcodeproj`
- Scheme: `ReactorStyleCase`
- App module folder: `./ReactorStyleCase/ReactorStyleCaseApp`
- Unit tests: `./ReactorStyleCaseTests`
- UI smoke target: `./ReactorStyleCaseUITests`

## Source Organization
- `./ReactorStyleCase/ReactorStyleCaseApp/AppShell/`: app composition, dependency wiring, auth gate, tab coordination, and root navigation.
- `./ReactorStyleCase/ReactorStyleCaseApp/Features/`: feature slices for `Auth`, `News`, and `Profile`; presentation state owners are Reactors.
- `./ReactorStyleCase/ReactorStyleCaseApp/Core/`: cross-feature mechanics such as design system, networking, persistence, configuration, logging, localization, image loading, and platform fallback support.
- `./ReactorStyleCase/ReactorStyleCaseApp/Shared/`: narrow reusable presentation helpers and accessibility identifiers.

## Architecture
- SwiftUI views call explicit Reactor intent methods such as `appeared()`, `loginTapped()`, `refreshRequested()`, `likeTapped(id:)`, `saveTapped()`, and `logoutTapped()`.
- Reactors translate those intents into typed feature-local `Action` values.
- `mutate(_ action:)` maps actions to synchronous mutations or side effects.
- `reduce(_ mutation:)` applies state transitions only.
- Network, persistence, pending sync, routing, and cancellation behavior stay outside reducers.
- This case intentionally uses local Reactor-style mechanics inside one standalone Xcode target and does not add local `./Packages` folders or third-party dependencies.

## Verification
```zsh
./scripts/verify.sh static
./scripts/verify.sh build
./scripts/verify.sh test-build
```
