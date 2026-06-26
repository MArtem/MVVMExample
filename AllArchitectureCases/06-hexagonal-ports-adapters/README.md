# Hexagonal Ports & Adapters Case

`HexagonalPortsAdaptersCase` is a standalone full-functional architecture case that preserves app behavior/design while expressing feature ownership through domain-owned ports plus driving and driven adapters.

## Project
- Xcode project: `./HexagonalPortsAdaptersCase.xcodeproj`
- Scheme: `HexagonalPortsAdaptersCase`
- App module folder: `./HexagonalPortsAdaptersCase/HexagonalPortsAdaptersCaseApp`
- Unit tests: `./HexagonalPortsAdaptersCaseTests`
- UI smoke target: `./HexagonalPortsAdaptersCaseUITests`

## Source Organization
- `./HexagonalPortsAdaptersCase/HexagonalPortsAdaptersCaseApp/AppShell/`: composition root, dependency wiring, root auth/session flow, and tab coordination.
- `./HexagonalPortsAdaptersCase/HexagonalPortsAdaptersCaseApp/Features/<Feature>/Ports/`: domain entities and domain-owned ports such as repository contracts.
- `./HexagonalPortsAdaptersCase/HexagonalPortsAdaptersCaseApp/Features/<Feature>/Adapters/Driving/`: SwiftUI presentation and feature navigation adapters that drive the app through user/system intents.
- `./HexagonalPortsAdaptersCase/HexagonalPortsAdaptersCaseApp/Features/<Feature>/Adapters/Driven/`: API DTOs, request definitions, mappers, concrete repositories, and feature-local stores that fulfill ports.
- `./HexagonalPortsAdaptersCase/HexagonalPortsAdaptersCaseApp/Adapters/Driven/CoreInfrastructure/`: cross-feature infrastructure adapters and local support mechanics.
- `./HexagonalPortsAdaptersCase/HexagonalPortsAdaptersCaseApp/Adapters/Driving/DesignSystem/`: reusable UI/design adapter mechanics.
- `./HexagonalPortsAdaptersCase/HexagonalPortsAdaptersCaseApp/Shared/`: narrow presentation helpers and accessibility identifiers.

## Architecture
- Ports are owned by feature/domain code and represent real external variability: auth API, news API, profile API, local persistence, session, pending sync, and image/configuration mechanics.
- Driven adapters implement external edges such as HTTP/API, DTO mapping, SwiftData/Keychain-backed local persistence, image loading, and configuration.
- Driving adapters are SwiftUI screens, navigation stacks, and ViewModels/presenters that translate UI intent into port calls.
- `AppShell` wires concrete adapters to feature entry points; it does not contain DTO mapping, API request construction, or persistence internals.
- This case intentionally stays in one standalone Xcode target and does not reintroduce local `./Packages` folders.

## Verification
```zsh
./scripts/verify.sh static
./scripts/verify.sh build
./scripts/verify.sh test-build
```


## Port serialization boundary
Port/domain models in this case should not carry persistence or transport serialization requirements by default. Driven adapters own their storage/JSON payloads and map to port models at the boundary; presentation adapters receive user-safe errors and localized strings only after adapter/domain mapping.
