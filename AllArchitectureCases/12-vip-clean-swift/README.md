# VIPCleanSwiftCase

`VIPCleanSwiftCase` is a standalone iOS 17+ SwiftUI architecture case that preserves the full source app behavior/design while demonstrating pragmatic VIP / Clean Swift scene ownership.

## Architecture Summary
- SwiftUI **Views** render immutable view state and forward user intent.
- Scene **Interactors** own lifecycle, async work, business/data orchestration, and state transitions.
- **Presenters** are format-only mappers into `*ViewState`.
- **Routers** own navigation only.
- **Workers** own repository, persistence, and local interaction I/O for interactors.

See `./ARCHITECTURE_CASE.md` for the role mapping and stop rules.

## Verification
Use the case-local script so DerivedData, package cache, and result bundles stay inside this folder:

```zsh
./scripts/verify.sh static
./scripts/verify.sh build
./scripts/verify.sh test-build
```
