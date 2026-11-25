# Packages And Managers Guide

## Purpose
This document describes the reusable package and manager layer. Apply an integration profile only when the selected project has adopted it; project-specific integration decisions remain with that project.

Use it for:
- package integration work
- package-vs-app ownership decisions
- reuse guidance for other projects

Do not use it for:
- current task history
- global assistant behavior
- temporary debugging notes


## Source-only integration mode

When a project selects source-only local integration, use this layout:

- `./PackagesInUse` contains the active package subset compiled directly into app/share/widget targets.
- `./PackagesForReuse` contains the full reviewed reusable package vault.
- `./Packages` contains SDK/package creation documentation, templates, reports, and optional copy-file helpers only.

This mode is a disk-usage control decision while building a large package library. It does not lower the package quality bar: each package must still keep SwiftPM metadata, docs, tests, DocC, contracts, and verify scripts so it can later be used as a real Swift Package.

When the selected project has adopted this source-only layout, copy new package functionality into `./PackagesForReuse` first, then into `./PackagesInUse` only if the app can use it now. Add only the required source/resources to Xcode targets and keep generated artifacts out of package folders.

## Core Rule
- Reuse an adopted package or manager when its existing contract fits a real project need.
- Put generic, entity-agnostic mechanics in a reusable package only when a real reuse or ownership
  boundary justifies that extraction; generic behavior alone does not require a new package.
- Keep project-specific mapping, endpoint semantics, schema application, routing, and UI policy
  in the app or feature that owns them.
- Do not add decorative adapters or protocols when an adopted package surface already fits the need.

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
- SwiftData-backed database management when selected by the app

App keeps:
- schema registration
- app seeding/bootstrap
- persistence policy

### `AppCoreDataDatabase`
Use for:
- Core Data-backed database management when selected by the app

The status of a package and whether a particular app uses it are separate decisions; verify the package catalog and selected app context. Historical rollback-only status in one app is not a cross-project rule.

### `AppDatabaseComposition`
Use for:
- resolver/factory composition
- backend wiring primitives

App keeps:
- current runtime choice and rollout policy

### `AppSyncCore`
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

### `AppShareExtensionSupport`
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

### `AppGlassUI`
Use for:
- SwiftUI Liquid Glass availability checks
- glass chrome fallback mechanics
- reusable shape-based glass styling helpers

App keeps:
- semantic color tokens
- product-specific visual roles
- screen layout and interaction decisions

### `AppBranding`
Use for:
- semantic brand tokens
- target-driven branding behavior

Working rule:
- extend semantic tokens instead of inventing one-off view colors

### `AppConfiguration`
Use for:
- UI configuration snapshot model
- refresh/store behavior

### `AppWidgetSupport`
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

### `AppSecureStorage`
Use for:
- product-neutral async secure storage contracts
- Keychain-backed small-secret storage on Apple platforms
- actor-backed in-memory storage for tests, previews, and unsigned simulator fallback
- sanitized secure-storage errors and key/value validation

App keeps:
- concrete auth/session key taxonomy
- token refresh and logout policy
- migration from old app-local token stores
- user-facing auth error mapping

### `AppFeatureFlags`
Use for:
- product-neutral feature flag evaluation
- local overrides and persisted snapshot/override stores
- percentage rollout and weighted variant bucketing
- validating snapshots before app runtime activation

App keeps:
- concrete product flag names
- remote config/network fetch policy
- rollout ownership and cleanup dates
- analytics and telemetry decisions for flag exposure

### `AppLogging`
Use for:
- product-neutral structured log events
- privacy-aware metadata redaction
- no-op, memory, console, multiplex, redacting, and OSLog-backed logging
- package-safe logger surfaces for optional integration helpers

App keeps:
- product-specific log taxonomy and subsystem names
- decisions about when/where to log
- crash/analytics/observability export policy
- user/session/domain metadata classification

### `AppObservability`
Use for:
- product-neutral spans, breadcrumbs, and duration measurements
- trace IDs, span IDs, and caller-owned correlation propagation
- privacy-aware observability attributes and redaction
- structured cancellation/failure descriptors

App keeps:
- product-specific telemetry naming and sampling policy
- concrete analytics/crash/export adapters
- decisions about when to start/end spans and emit breadcrumbs
- domain-specific attribute classification beyond the generic redaction baseline

### `AppConnectivity`
Use for:
- product-neutral connectivity snapshots and transition observation
- cost/constrained network policy checks
- manual/static connectivity monitors in package tests/previews
- privacy-safe connectivity diagnostics

App keeps:
- product-specific offline UI and copy
- retry/offline queue orchestration decisions
- sync/download/upload behavior
- telemetry/logging export adapters

### `AppAnalytics`
Use for:
- reusable analytics/event primitives

App keeps:
- app event naming policy
- app feature instrumentation decisions

### `AppAppleAuthentication`
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
- start from the package contract, not from app-specific wrappers
- reimplement only the project-specific mapping and policies
- do not cargo-cult another app's repository shape if the new project does not need it

## Related Sources
- [PROJECT_HEALTH.md](../PROJECT_HEALTH.md)
- [PROJECT_DOCUMENTATION.md](../PROJECT_DOCUMENTATION.md)
- [PACKAGE_OWNERSHIP_AND_ADOPTION_STANDARD.md](PACKAGE_OWNERSHIP_AND_ADOPTION_STANDARD.md)
- [PACKAGE_DOC_MIRROR_CONTRACT.md](PACKAGE_DOC_MIRROR_CONTRACT.md)


## Neutral Reuse For New Projects
The old `SourceAppInfrastructure` compatibility bundle has been retired from the original source project. If a new project chooses source-copy integration, select only packages needed by its current requirements; the following are examples, not mandatory dependencies:

- `AppInfrastructure`
- `AppNetworking`
- `AppErrors`
- `AppLocalization`
- `AppConfiguration`
- `AppLogging`
- `AppObservability`
- `AppConnectivity`
- `AppAnalytics`
- `AppCache`

Use source package behavior as implementation reference, not as branding. Keep app-specific endpoint semantics, copy, route payloads, schemas, session policy, and product behavior in the target app.

For small demo/test projects, select only capabilities justified by current requirements; do not assume a fixed package set.

## Xcode Project Organization For Source-Only Packages

For projects using the `PackagesInUse` source-only layout, active package source files must be grouped in the active Xcode project's `project.pbxproj` under a logical `PackagesInUse` group with one subgroup per package. This is an Xcode navigation rule only; physical files remain under `./PackagesInUse/<PackageName>`. Future package additions must keep this structure and must not leave package files only in `Recovered References`.

### `AppIntentSupport`
Use for:
- reusable App Intents helper mechanics;
- generic App Intent text parameter normalization;
- stable product-neutral validation failures;
- package marker support for future App Intents composition.

App keeps:
- concrete `AppIntent` declarations;
- `AppShortcutsProvider` declarations;
- shortcut phrases/titles/descriptions;
- product-specific persistence, routing, authorization, analytics, and user-facing copy.

## Mandatory Package README And Catalog Rule

Every reusable package must be self-documenting. Before a new package is considered adopted, it must include a package-level `README.md` with:

1. summary and status in the repository;
2. the problem it solves;
3. capabilities;
4. when to use it and when not to use it;
5. package/app ownership boundary;
6. products and targets;
7. local SwiftPM usage with `.package(path:)`;
8. remote SwiftPM usage guidance, including the rule that SwiftPM Git URL mode needs `Package.swift` at repository root;
9. current app source-only integration notes;
10. basic usage example;
11. verification instructions;
12. links to `PackageContract.md`, `REUSE.md`, `USAGE.md` or DocC where present.

The canonical reusable capability selector is `reusable/package-vault-docs/PACKAGE_CATALOG.md`. For projects adopting the `PackagesForReuse` / `PackagesInUse` layout, keep the project integration catalogs current as follows:

- `./PackagesForReuse/PACKAGE_CATALOG.md` lists every reusable package and integration helper with a short purpose, products and active/inactive status.
- `./PackagesInUse/PACKAGE_CATALOG.md` lists the source-only packages currently compiled into active app targets.
- `./PackagesForReuse/README.md` and `./PackagesInUse/README.md` must state package counts, usage mode and maintenance rules.

When adding a package, update its `README.md`, the applicable canonical package documentation and the selected project’s adoption records. For projects using this layout, update `./PackagesForReuse/PACKAGE_CATALOG.md` and, when active, `./PackagesInUse/PACKAGE_CATALOG.md` and `./PackagesInUse/README.md`. Perform only documentation and static checks allowed by the current task and record omitted verification.
