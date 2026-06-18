# Packages And Managers Guide

## Purpose
This document explains the reusable package and manager layer in `MVVMExample`.

Use it for:
- package integration work
- package-vs-app ownership decisions
- reuse guidance for other projects

Do not use it for:
- current task history
- global assistant behavior
- temporary debugging notes

## Core Rule
- Reusable packages and managers are the foundation.
- If behavior is generic, repeatable, and entity-agnostic, it should live in the package.
- App code should keep only project-specific mapping, endpoint semantics, persistence schema application, routing, and UI composition.
- Do not add decorative adapters or protocols when the package surface already fits the need.

## Package Inventory
### `AppNetworking`
Use for:
- request execution
- uploads/downloads
- retry/interceptor flow
- auth-refresh integration
- reusable network diagnostics

App keeps:
- DTOs
- endpoint semantics
- mapping to app models

### `AppDatabaseCore`
Use for:
- backend-neutral database contracts
- migration primitives
- shared database operation wrappers

App keeps:
- app schema
- app record types
- app bootstrap policy

### `AppSwiftDataDatabase`
Use for:
- active SwiftData-backed database manager

App keeps:
- schema registration
- app seeding/bootstrap
- persistence policy

### `AppCoreDataDatabase`
Use for:
- legacy rollback-only Core Data manager

Current rule:
- do not design new app runtime behavior around it
- keep it only as fallback material when explicitly needed

### `AppDatabaseComposition`
Use for:
- resolver/factory composition
- backend wiring primitives

App keeps:
- current runtime choice and rollout policy

### `SyncCore`
Use for:
- sync state machine
- push/pull orchestration
- mutation queue
- cursor handling
- sync status
- conflict contract

App keeps:
- app payload mapping
- local schema application
- endpoint semantics
- feature-specific merge policy

### `AppNavigation`
Use for:
- reusable router/tab primitives
- navigation snapshot persistence contract

App keeps:
- `AppTab`
- route payloads
- deep-link semantics

### `AppLocalization`
Use for:
- localization facade
- locale override support

App keeps:
- actual product copy

### `AppOnDeviceAI`
Use for:
- on-device Foundation Models availability checks
- reusable local AI task contracts
- local translation request/response execution
- future reusable local AI capabilities beyond translation

App keeps:
- feature-specific field extraction
- app localization target selection
- translated-state presentation policy
- local per-feature persistence of translated snapshots

### `AppShareSupport`
Use for:
- app-group-backed shared JSON item storage
- reusable cross-process handoff primitives for app extensions
- generic persistence of imported/share-originated payloads keyed by item ID
- generic `NSItemProvider` intake for text/image/video/pdf/audio/file payloads

App keeps:
- app-specific card draft models
- app-specific shared composer UI and card rules reused between app and extension
- app-specific feed card payloads
- publish/sync policy between extension storage and app runtime
- extension lifecycle and authentication gating

### `AppBranding`
Use for:
- semantic brand tokens
- target-driven branding behavior

Working rule:
- extend semantic tokens instead of inventing one-off view colors

### `AppUIConfiguration`
Use for:
- UI configuration snapshot model
- refresh/store behavior

### `AppWidgets`
Use for:
- widget snapshot primitives

App keeps:
- widget composition fed by app-specific data

### `AppPushNotifications`
Use for:
- APNs token handling
- payload parsing
- persisted push state

App keeps:
- app-specific routing after payload interpretation

### `AppAnalytics`
Use for:
- reusable analytics/event primitives

App keeps:
- app event naming policy
- app feature instrumentation decisions

### `MVVMExampleleAuthentication`
Use for:
- reusable Apple auth integration primitives

App keeps:
- app session flow
- feature wiring

## Integration Rules
When using a package or manager in app code:

1. Prefer the package's existing surface first.
2. If the package is missing reusable behavior, extend the package.
3. Add app-layer logic only when the behavior is truly project-specific.
4. Avoid app-local shim types unless there is a real seam such as testing, lifecycle bridging, or target composition.

## Reuse In Other Projects
When reusing these packages elsewhere:
- start from the package contract, not from `MVVMExample` wrappers
- reimplement only the project-specific mapping and policies
- do not cargo-cult `MVVMExample` repository shapes if the new project does not need them

## Related Sources
- [PROJECT_HEALTH.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_HEALTH.md)
- [PROJECT_DOCUMENTATION.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/PROJECT_DOCUMENTATION.md)
- [.codex/skills/tchop-packages/SKILL.md](/Users/Artem/.zenflow/worktrees/new-task-be0b/.codex/skills/tchop-packages/SKILL.md)


## Neutral Reuse For New Projects
`Standalone `App*` packages contain reusable mechanics, but unrelated new projects should not inherit `Tchop*` naming by default. When bootstrapping a generic/new project, promote only currently needed mechanics into neutral package names such as:

- standalone `App*` packages
- `AppNetworking`
- `AppErrors`
- `AppLocalization`
- `AppConfiguration`
- `AppLogging`
- `AppAnalytics`
- `AppCache`

Use source package behavior as implementation reference, not as branding. Keep app-specific endpoint semantics, copy, route payloads, schemas, session policy, and product behavior in the target app.

For small demo/test projects, start with networking, errors, localization, configuration, and logging only. Add database, sync, widgets, push, share, media, AI, or payments packages only when the project has current requirements for those areas.
