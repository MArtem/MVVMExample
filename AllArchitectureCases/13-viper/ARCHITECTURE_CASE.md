# VIPER Architecture Case

## Project
`VIPERArchitectureCase`

## Goal
Full functional clone of the source app using VIPER architecture.

## Current Status
- [x] Full app functionality/design baseline copied into a standalone project name.
- [x] Source app project name removed from paths and identifiers.
- [x] Feature modules converted from presentation ownership to VIPER roles.
- [x] Build verified after full VIPER conversion.
- [x] Test-build verified after full VIPER conversion.

## VIPER Target State
Each feature should use:
- View: render-only UI and user intent forwarding.
- Interactor: business/data loading, mutation, persistence/sync calls.
- Presenter: presentation state, formatting coordination, user intent orchestration.
- Entity: domain/presentation entities that do not leak DTO/database models into UI.
- Router: navigation state and destination assembly only.
- Builder: module assembly and dependency wiring.

## Rule
Do not remove functionality or design to make conversion easier. Preserve auth, news list/detail, profile/profile-edit, persistence/sync, local support behavior, localization, accessibility identifiers, and design system behavior unless a deliberate documented architecture decision says otherwise.


## Implemented VIPER Mapping
- **Views**: SwiftUI screens/components render presenter state and forward explicit user intents.
- **Interactors**: Login, news list, detail, profile, and profile-edit modules own repository/local-store calls.
- **Presenters**: Observable presentation owners expose explicit methods; no generic dispatch/action enum was introduced.
- **Entities**: Existing domain entities and route payloads remain the module data contracts.
- **Routers**: News/profile routers own navigation paths and route payloads.
- **Builders**: Module builders assemble presenters/screens at app and navigation boundaries.
- **Dependency boundary**: Builders create Interactors; Presenters receive Interactors and no longer accept Repository dependencies directly.
