# Coordinator Flow Case

`CoordinatorFlowCase` is a standalone full-functional architecture case that preserves the app behavior/design while making navigation ownership the primary architecture concern.

## Project
- Xcode project: `./CoordinatorFlowCase.xcodeproj`
- Scheme: `CoordinatorFlowCase`
- App module folder: `./CoordinatorFlowCase/CoordinatorFlowCaseApp`
- Unit tests: `./CoordinatorFlowCaseTests`
- UI smoke target: `./CoordinatorFlowCaseUITests`

## Architecture
- App/root coordinators own auth gate, tab selection, and flow-level routing.
- Feature routers own typed route state and `NavigationPath` mutation.
- Routes carry stable value payloads only; routes do not carry SwiftUI views, DTOs, persistence models, or presentation owners.
- ViewModels remain screen-state owners; coordinators/routers do not perform API, persistence, or business work.

## Verification
```zsh
./scripts/verify.sh static
./scripts/verify.sh build
./scripts/verify.sh test-build
```
