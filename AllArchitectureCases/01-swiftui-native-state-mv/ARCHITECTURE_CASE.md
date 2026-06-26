# SwiftUI Native State / MV Architecture Case

## Project
`SwiftUINativeStateCase`

## Goal
Full functional clone of the source app using SwiftUI Native State / MV ownership.

## Current Status
- [x] Full app functionality/design baseline copied into a standalone project name.
- [x] Source app project name removed from paths and identifiers.
- [x] Feature presentation ownership converted from model-owner classes to SwiftUI-native state/MV roles.
- [x] Build verified after full architecture conversion.
- [x] Test-build verified after full architecture conversion.

## Target State
- **View**: SwiftUI views own local state and forward explicit UI events to local methods.
- **Model**: domain/data models and lightweight screen models hold durable state where async work cannot live directly in value-type views without unsafe lifecycle behavior.
- **Services/Repositories**: existing infrastructure remains behind injected dependencies; views must not create raw URLSession/persistence clients.
- **Coordinator/Router**: app/navigation state remains explicit and does not perform business/data work.

## Rule
Do not remove functionality or design to make conversion easier. Preserve auth, news list/detail, profile/profile-edit, persistence/sync, local support behavior, localization, accessibility identifiers, and design system behavior unless a deliberate documented architecture decision says otherwise.

## Architecture Review
- **Detected style**: SwiftUI Native State / MV with explicit app/navigation state.
- **Evidence**: SwiftUI screens own their observable screen models with `@State`; UI events call explicit methods such as `loginTapped()`, `refreshRequested()`, and `favoriteTapped()`; repositories and persistence remain injected instead of being created by views.
- **Boundary decision**: async loading, cancellation, optimistic sync, and durable local state are kept in lightweight screen models because value-type SwiftUI views are not safe owners for those lifecycles.
- **Navigation**: routers/coordinators own route state only; they do not perform API, persistence, or business work.
- **Rejected for this case**: no source-app identity, no previous presentation-role naming, no generic `send(_:)`, no action-enum reducer loop, no local package reintroduction.

## Verification
- `./scripts/verify.sh static`
- `./scripts/verify.sh build`
- `./scripts/verify.sh test-build`
- Source-identity grep for stale project/product names
- Role/API grep for stale presentation-role names, generic `send(_:)`, `dispatch(_:)`, and action-enum reducer boilerplate


## Semantic Ownership Clarification
This case intentionally demonstrates **SwiftUI Native State / MV with screen lifecycle models**, not a pure no-owner toy MV variant. SwiftUI views still own rendering and local UI composition, while lightweight `*Model` objects own async lifecycle, cancellation, pagination, persistence reconciliation, and navigation callbacks needed to preserve the full app behavior. These models must not be treated as generic MVVM `ViewModel` boilerplate or as permission to add `send(_:)`/action-enum APIs; they are bounded lifecycle owners for screens whose behavior would otherwise be duplicated in SwiftUI `body` code.
