# Modular Feature-Sliced Case

`ModularFeatureSlicedCase` is a standalone full-functional architecture case that preserves the source app behavior/design while expressing ownership as app shell, core/shared support, and independently reviewable feature slices.

## Project
- Xcode project: `./ModularFeatureSlicedCase.xcodeproj`
- Scheme: `ModularFeatureSlicedCase`
- App module folder: `./ModularFeatureSlicedCase/ModularFeatureSlicedCaseApp`
- Unit tests: `./ModularFeatureSlicedCaseTests`
- UI smoke target: `./ModularFeatureSlicedCaseUITests`

## Source Organization
- `./ModularFeatureSlicedCase/ModularFeatureSlicedCaseApp/AppShell/`: app composition, dependency wiring, auth gate, tab coordination, and root navigation.
- `./ModularFeatureSlicedCase/ModularFeatureSlicedCaseApp/Features/`: independently owned feature slices for `Auth`, `News`, and `Profile`.
- `./ModularFeatureSlicedCase/ModularFeatureSlicedCaseApp/Core/`: cross-feature mechanics such as design system, networking, persistence, configuration, logging, localization, image loading, and platform fallback support.
- `./ModularFeatureSlicedCase/ModularFeatureSlicedCaseApp/Shared/`: narrow reusable presentation helpers and accessibility identifiers.

## Architecture
- Feature slices own their presentation, navigation, domain contracts, data adapters, DTOs, mappers, and feature-local stores.
- `AppShell` owns composition and product routing; it does not own DTO mapping, persistence internals, or feature business logic.
- `Core` provides reusable mechanics only; it must not embed product policy for a specific feature.
- Shared UI helpers remain narrow and reusable; repeated rows still receive immutable state plus explicit callbacks.
- This case intentionally uses source-level modular boundaries inside one standalone Xcode target. It does not reintroduce local `./Packages` folders.

## Verification
```zsh
./scripts/verify.sh static
./scripts/verify.sh build
./scripts/verify.sh test-build
```
