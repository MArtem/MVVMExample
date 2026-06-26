# Hexagonal / Ports & Adapters Architecture Case

## Project
`HexagonalPortsAdaptersCase`

## Goal
Full functional clone using Hexagonal / Ports & Adapters ownership while preserving the app behavior, design, accessibility identifiers, localization, persistence behavior, pending mutation sync, and test-build coverage.

## Current Status
- [x] Full app functionality/design baseline copied into a standalone project name.
- [x] Source app project name removed from paths and identifiers.
- [x] Source layout converted to feature-owned `Ports`, `Adapters/Driving`, and `Adapters/Driven` boundaries.
- [x] Hexagonal / Ports & Adapters boundary review completed.
- [x] Static/build/test-build verification completed.
- [x] Central vault mirror synchronized.

## Target State
- **Ports**: feature/domain-owned entities and contracts that describe what the app needs from external edges without importing transport, storage, SwiftUI, URLSession, SwiftData, or Keychain details.
- **Driven adapters**: concrete external-edge implementations such as API requests, DTOs, mappers, repositories, persistence stores, session storage, pending mutation queue, image loading, configuration, networking, localization, logging, and platform support.
- **Driving adapters**: SwiftUI screens, navigation stacks, and presentation state owners that translate user/system intents into calls through ports.
- **AppShell**: composition root that wires ports to concrete adapters and owns app-level flow only.
- **Shared**: narrow UI helpers and accessibility identifiers that are not product/data policy owners.

## Allowed Reuse
- Preserve source app UI layout, design system tokens, localization resources, accessibility identifiers, networking behavior, persistence behavior, pending mutation queue, and tests.
- Reuse existing repository contracts where they represent real ports.
- Reuse ViewModel presentation ownership as a driving adapter; Hexagonal does not require a reducer/action architecture.

## Stop Rules
- Do not add local `./Packages` or SwiftPM package extraction for this case.
- Do not introduce protocol explosions for single in-process helpers without external variability.
- Do not allow driven adapters to leak DTO, URLSession, SwiftData, Keychain, or platform types into ports or presentation state.
- Do not move API/persistence implementation into `AppShell`.
- Do not use generic `send(_:)`, `dispatch(_:)`, or UI action enums as MVVM boilerplate.
- Do not remove functionality/design to simplify the architecture case.

## Architecture Review
- **Detected style**: Hexagonal / Ports & Adapters with feature-owned ports, SwiftUI driving adapters, API/persistence driven adapters, and app-shell composition.
- **Evidence**: each feature contains `Ports`, `Adapters/Driving`, and `Adapters/Driven`; core external mechanics are under `Adapters/Driven/CoreInfrastructure`; UI/design driving mechanics are under `Adapters/Driving/DesignSystem`; `AppShell` performs composition and flow ownership only.
- **Applicable gate**: ports represent real external variability and do not leak transport/storage/framework types; adapters do not bypass ports for app-facing behavior; composition remains at app-shell boundaries.
- **Rejected for this case**: decorative ports for every helper, pass-through use cases, extra factories, local packages, and global stores.

## Verification Checklist
- Source-identity grep for stale project/product names.
- Architecture grep/review for DTO/API/persistence leakage into `Ports` and app-shell ownership of adapter internals.
- `git diff --check`.
- `./scripts/verify.sh static`.
- `./scripts/verify.sh build`.
- `./scripts/verify.sh test-build`.
- Vault sync and post-sync identity/generated-file greps.


## Port serialization boundary
Port/domain models in this case should not carry persistence or transport serialization requirements by default. Driven adapters own their storage/JSON payloads and map to port models at the boundary; presentation adapters receive user-safe errors and localized strings only after adapter/domain mapping.
