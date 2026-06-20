# Clean / Layered Architecture Case

## Project
`CleanLayeredCase`

## Goal
Full functional clone using explicit Presentation, Domain, Data, and Infrastructure boundaries with standalone project identity.

## Current Status
- [x] Full app functionality/design baseline copied into a standalone project name.
- [x] Source app project name removed from paths and identifiers.
- [x] Clean / Layered boundaries verified.
- [x] Build verified after identity conversion.
- [x] Test-build verified after identity conversion.

## Target State
- **Presentation**: SwiftUI views, view state builders, and ViewModels; no DTO/database/API request construction.
- **Domain**: feature entities and repository contracts; no SwiftUI, URLSession, SwiftData, or DTO dependencies.
- **Data**: DTOs, API request definitions, mappers, and repository implementations.
- **Infrastructure**: reusable app-local mechanics such as network client, persistence, configuration, localization, logging, image cache/loading.

## Architecture Review
- **Detected style**: Clean / Layered feature slices with MVVM presentation.
- **Evidence**: each feature keeps `Presentation`, `Domain`, and `Data`; DTO mapping is isolated under data mapping files; SwiftUI screens consume view state/domain values, not transport DTOs.
- **Applicable gate**: dependency direction stays inward from data/infrastructure to domain contracts and outward composition happens at the app boundary.
- **Rejected for this case**: no pass-through use-case layer, no decorative repository protocols beyond existing real seams, no DTO or SwiftData leakage into views.

## Verification
- `./scripts/verify.sh static`
- `./scripts/verify.sh build`
- `./scripts/verify.sh test-build`
- Source-identity grep for stale project/product names
- Layer grep/review for DTO/API/persistence leakage into presentation/domain
