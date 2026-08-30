# AllArchitectureCases Progress

## Current Status
- [x] `./AllArchitectureCases` root workspace created.
- [x] 14 self-contained baseline project clones created.
- [x] Each clone has its own `ARCHITECTURE_CASE.md`.
- [x] Each clone has a patched `./scripts/verify.sh` that writes Xcode artifacts inside that clone folder.
- [x] `xcodebuild -list` succeeded for all 14 clones through `./scripts/verify.sh list`.
- [x] Baseline smoke build succeeded for `./AllArchitectureCases/01-swiftui-native-state-mv`.
- [ ] Architecture-specific conversion completed for all cases.
- [ ] Post-conversion build completed for all cases.

## Case Status
| Case | Clone | List | Baseline Build | Architecture Conversion | Post-conversion Build |
|---|---:|---:|---:|---:|---:|
| SwiftUI Native State / MV | yes | pass | pass | pending | pending |
| MVVM Explicit Intents | yes | pass | not run | pending | pending |
| Coordinator / Flow | yes | pass | not run | pending | pending |
| Clean / Layered | yes | pass | not run | pending | pending |
| Modular / Feature-Sliced | yes | pass | not run | pending | pending |
| Hexagonal / Ports & Adapters | yes | pass | not run | pending | pending |
| Redux / Elm / UDF | yes | pass | not run | pending | pending |
| TCA | yes | pass | not run | pending | pending |
| ReactorKit / Reactor-style | yes | pass | not run | pending | pending |
| MVC / Massive ViewController Migration | yes | pass | not run | pending | pending |
| MVP Passive View | yes | pass | not run | pending | pending |
| VIP / Clean Swift | yes | pass | not run | pending | pending |
| VIPER | yes | pass | not run | pending | pending |
| RIBs | yes | pass | not run | pending | pending |

## Next Work Order
1. Convert `./AllArchitectureCases/01-swiftui-native-state-mv` to the smallest valid SwiftUI Native State / MV version where possible, documenting where full conversion would violate API/persistence ownership.
2. Convert `./AllArchitectureCases/02-mvvm-explicit-intents` by preserving and tightening the existing explicit-intent MVVM baseline.
3. Continue one architecture case at a time, avoiding empty pass-through layers.

## Important Constraint
A clone is currently self-contained and build-readable, but it is not considered architecture-complete until its `ARCHITECTURE_CASE.md` marks architecture conversion and post-conversion build as complete.
