# TCACaseApp Source Map

## Boundaries
- `AppShell/`: composition root, auth gate, app-level dependency wiring, tab coordinator, and root navigation.
- `Features/`: feature slices. Presentation state owners are Stores with explicit `State`, `Action`, `Effect`, `StateMutation`, and reducer-style mutation application.
- `Core/`: reusable mechanics shared across features, including design system, local support primitives, networking, persistence, logging, localization, and image loading.
- `Shared/`: narrow reusable presentation helpers and accessibility identifiers.

## TCA-Style Flow
```mermaid
flowchart LR
    View[SwiftUI View] --> Intent[Explicit Store Intent]
    Intent --> Action[Typed Action]
    Action --> Reducer[Reducer-style state transition]
    Action --> Effect[Typed Effect]
    Effect --> Repository[Repository / Persistence / Router]
    Effect --> Reducer
    Reducer --> State[Observable State]
    State --> View
```

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

Reducers must not perform network or persistence work. `Core` must not depend on `Features`, `Shared`, or `AppShell`. `Shared` must not depend on feature slices or app-shell composition.
