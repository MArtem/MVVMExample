# ReduxElmUDFCaseApp Source Map

## Boundaries
- `AppShell/`: composition root, auth gate, app-level dependency wiring, tab coordinator, and root navigation.
- `Features/`: feature slices. Presentation state owners are Stores that map explicit SwiftUI intents to typed Actions, apply typed Mutations through reducer-style methods, and run async Effects outside reducers.
- `Core/`: reusable mechanics shared across features, including design system, local support primitives, networking, persistence, logging, localization, and image loading.
- `Shared/`: narrow reusable presentation helpers and accessibility identifiers.

## UDF Flow
```mermaid
flowchart LR
    View[SwiftUI View] --> Intent[Explicit Store Intent]
    Intent --> Action[Typed Action]
    Action --> Effect[Async Effect when needed]
    Action --> Mutation[Typed Mutation]
    Effect --> Mutation
    Mutation --> Reducer[Reducer-style reduce]
    Reducer --> State[Immutable View State]
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

`Core` must not depend on `Features`, `Shared`, or `AppShell`. `Shared` must not depend on feature slices or app-shell composition. Reducers must not perform network or persistence work.
