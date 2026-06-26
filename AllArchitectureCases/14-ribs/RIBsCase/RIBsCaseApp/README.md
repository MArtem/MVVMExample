# RIBsCase App Source

This folder contains the app source for the RIBs architecture case.

## Role Direction
- Screens render state and forward intent.
- Interactors own feature lifecycle/state and business/data orchestration.
- Builders assemble screens/interactors from scoped components.
- Components hold scoped dependencies only.
- Routers own navigation-only attach/detach boundaries.
