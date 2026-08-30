# RIBsCase

`RIBsCase` is a standalone iOS 17+ SwiftUI architecture case that preserves the full source app behavior/design while demonstrating a pragmatic RIBs-style ownership model.

## Architecture Summary
- **Components** hold dependency scope for an app/authenticated/feature boundary.
- **Builders** assemble screens and child RIB dependencies at route boundaries.
- **Interactors** own lifecycle, async state, business/data orchestration, and user intents.
- **Routers** own navigation and attach/detach-style child routing boundaries only.
- SwiftUI **Views** render state and forward user intent.

See `./ARCHITECTURE_CASE.md` for mapping and stop rules.

## Verification
```zsh
./scripts/verify.sh static
./scripts/verify.sh build
./scripts/verify.sh test-build
```


## Bounded SwiftUI RIBs clarification
This case is a **bounded RIBs-inspired SwiftUI clone**, not a UIKit/Rx RIBs framework port. SwiftUI `NavigationStack` owns physical view attachment, while Builders and Components define route-time construction boundaries and dependency scopes. Do not add a deep attach/detach tree unless a child actually needs independent lifecycle, retention, or dependency propagation beyond SwiftUI navigation.
