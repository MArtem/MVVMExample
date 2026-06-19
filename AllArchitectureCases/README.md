# AllArchitectureCases

This folder contains isolated, self-contained MVVMExample architecture-case clones.

## Purpose
Each child folder is intended to become a working clone of the same app shaped around one architecture style from the reusable iOS Architecture Style Router.

## Ground Rules
- Keep the root `MVVMExample` baseline unchanged while architecture cases are explored.
- Reuse existing app code, assets, tests, docs, scripts, and app-local `LocalSupport` infrastructure when it reduces mechanical work.
- Each case must remain self-contained enough to build from inside its own folder: project file, app source, tests, scripts, docs, and local support code live inside that case folder.
- Build outputs, DerivedData, logs, caches, and result bundles must stay under `/Users/Artem/.zenflow`.
- Do not use root-level `./Packages`; if an architecture case needs packages, keep them inside that case and document why.
- UI tests/manual simulator/Instruments lanes remain explicit-only.

## Architecture Case Order
1. SwiftUI Native State / MV
2. MVVM Explicit Intents
3. Coordinator / Flow
4. Clean / Layered
5. Modular / Feature-Sliced
6. Hexagonal / Ports & Adapters
7. Redux / Elm / UDF
8. TCA
9. ReactorKit / Reactor-style
10. MVC / Massive ViewController Migration
11. MVP Passive View
12. VIP / Clean Swift
13. VIPER
14. RIBs

## Verification Policy
For each converted case:

```zsh
git diff --check
./scripts/verify.sh build
```

Run unit/UI lanes only when explicitly approved for that case.
