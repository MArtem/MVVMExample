# RIBs Architecture Case

## Project
`RIBsCase`

## Goal
Full functional clone of the source app using a bounded RIBs-style architecture adapted for SwiftUI.

## Target State
Use RIBs roles only when they carry real ownership:
- **Router**: owns navigation path and child attach/detach boundary; no API, persistence, or business work.
- **Interactor**: owns lifecycle, state, async work, cancellation, business/data orchestration, and user intents.
- **Builder**: assembles the screen/RIB and injects scoped dependencies.
- **Component**: carries dependencies for an app/authenticated/feature scope without becoming a service locator.
- **View**: renders immutable state and forwards user intent.

## Implemented Mapping
- App/authenticated scope is represented by app dependencies plus session-scoped coordinators/routers.
- News/profile feature routes use builders to create screen interactors from scoped components.
- Existing routers keep navigation-only responsibilities.
- A deeper RIB tree is intentionally avoided because current app flows do not need more lifecycle boundaries.

## Stop Rules
- Do not create a deep RIB tree for ceremony.
- Every attach/detach boundary must correspond to route lifecycle or dependency propagation value.
- Do not let components become global service locators.
- Do not let routers perform business/data work.
- Do not remove functionality or design to satisfy the architecture label.
