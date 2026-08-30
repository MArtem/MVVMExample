# ReactorStyleCaseApp Source Map

## Boundaries
- `AppShell/`: composition root, auth gate, app-level dependency wiring, tab coordinator, and root navigation.
- `Features/`: feature slices. Presentation state owners are Reactors with explicit `State`, `Action`, `Mutation`, `mutate(_:)`, and `reduce(_:)`.
- `Core/`: reusable mechanics shared across features, including design system, local support primitives, networking, persistence, logging, localization, and image loading.
- `Shared/`: narrow reusable presentation helpers and accessibility identifiers.

## Reactor-Style Flow
```mermaid
flowchart LR
    View[SwiftUI View] --> Intent[Explicit Reactor Intent]
    Intent --> Action[Typed Action]
    Action --> Mutate[mutate action]
    Mutate --> SideEffect[Async Side Effect]
    Mutate --> Mutation[Typed Mutation]
    SideEffect --> Mutation
    Mutation --> Reduce[reduce mutation]
    Reduce --> State[Observable State]
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
