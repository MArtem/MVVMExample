# RIBsCase App Source

This folder contains the app source for the RIBs architecture case.

## Role Direction
- Screens render state and forward intent.
- Interactors own feature lifecycle/state and business/data orchestration.
- Builders assemble screens/interactors from scoped components.
- Components hold scoped dependencies only.
- Routers own navigation-only attach/detach boundaries.


## Bounded SwiftUI RIBs clarification
This case is a **bounded RIBs-inspired SwiftUI clone**, not a UIKit/Rx RIBs framework port. SwiftUI `NavigationStack` owns physical view attachment, while Builders and Components define route-time construction boundaries and dependency scopes. Do not add a deep attach/detach tree unless a child actually needs independent lifecycle, retention, or dependency propagation beyond SwiftUI navigation.
