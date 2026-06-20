# Coordinator / Flow Architecture Case

## Project
`CoordinatorFlowCase`

## Goal
Full functional clone using explicit coordinator/router navigation ownership with standalone project identity.

## Current Status
- [x] Full app functionality/design baseline copied into a standalone project name.
- [x] Source app project name removed from paths and identifiers.
- [x] Navigation ownership verified as Coordinator / Flow.
- [x] Build verified after identity conversion.
- [x] Test-build verified after identity conversion.

## Target State
- **AppRootCoordinator**: owns startup/session restoration and auth-vs-main flow switching.
- **MainCoordinator**: owns tab selection and top-level tab routing state.
- **Feature Routers**: own typed route state and navigation stack mutation.
- **Screens/ViewModels**: own screen state and business/data orchestration; navigation calls go through routers/coordinators.

## Architecture Review
- **Detected style**: Coordinator / Flow with feature MVVM screens underneath.
- **Evidence**: `AppRootCoordinator`, `MainCoordinator`, `NewsRouter`, and `ProfileRouter` hold navigation state; routes carry IDs/value payloads; screen code calls router/coordinator intents instead of creating destinations ad hoc.
- **Applicable gate**: navigation layer does not call repositories, persistence stores, keychain, or network clients.
- **Rejected for this case**: no DTO/database objects in routes, no SwiftUI views in route payloads, no business work in routers, no speculative coordinator per tiny child view.

## Verification
- `./scripts/verify.sh static`
- `./scripts/verify.sh build`
- `./scripts/verify.sh test-build`
- Source-identity grep for stale project/product names
- Route payload grep/review for DTO/persistence/view leakage
