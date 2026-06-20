# Clean Layered Case

`CleanLayeredCase` is a standalone full-functional architecture case preserving app behavior/design while making Presentation → Domain → Data separation explicit.

## Project
- Xcode project: `./CleanLayeredCase.xcodeproj`
- Scheme: `CleanLayeredCase`
- App module folder: `./CleanLayeredCase/CleanLayeredCaseApp`
- Unit tests: `./CleanLayeredCaseTests`
- UI smoke target: `./CleanLayeredCaseUITests`

## Architecture
- Presentation owns SwiftUI screens, view state, and ViewModels.
- Domain owns app entities and repository contracts.
- Data owns DTOs, request builders, mappers, and repository implementations.
- Infrastructure owns cross-feature networking, configuration, persistence, logging, localization, and image loading support.

## Verification
```zsh
./scripts/verify.sh static
./scripts/verify.sh build
./scripts/verify.sh test-build
```
