# ModularFeatureSlicedCaseApp Source Map

## Boundaries
- `AppShell/`: composition root, auth gate, app-level dependency wiring, tab coordinator, and root navigation.
- `Features/`: vertical feature slices. Each slice owns its own presentation, navigation, domain contracts, data adapters, DTOs, mappers, repositories, and feature-local stores.
- `Core/`: reusable mechanics shared across features, including design system, local support primitives, networking, persistence, logging, localization, and image loading.
- `Shared/`: narrow reusable presentation helpers and accessibility identifiers.

## Dependency Direction
```mermaid
flowchart TD
    AppShell --> Features
    AppShell --> Core
    AppShell --> Shared
    Features --> Core
    Features --> Shared
    Shared --> Core
```

`Core` must not depend on `Features`, `Shared`, or `AppShell`. `Shared` must not depend on feature slices or app-shell composition.


## App-scoped Core clarification
`Core/` in this case is **app-scoped shared infrastructure**, not a reusable cross-app package or a feature-neutral platform core. It may contain cross-feature persistence/session/sync mechanics required by this standalone clone, but feature-owned presentation and navigation stay inside their slices. If this case is later evolved into stricter feature-sliced modules, feature-specific pending-mutation/profile adapters should move from `Core/Infrastructure` into the owning feature slices behind narrow shared contracts.
