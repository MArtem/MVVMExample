# MVCMigrationCase

`MVCMigrationCase` is a standalone full-functional architecture case that preserves the source app behavior/design while demonstrating an incremental **MVC / Massive ViewController Migration** boundary.

This case intentionally uses screen-scoped `*Controller` types as the SwiftUI-facing equivalent of legacy view controllers. Each controller owns UI state, user callbacks, navigation handoff, async tasks, and repository coordination for one screen. The scope is deliberate: it demonstrates migration from legacy MVC without moving the whole app into one app-wide massive object.

## Architecture Intent

- **Screen controller ownership**: `LoginController`, `NewsListController`, `NewsDetailController`, `ProfileController`, and `ProfileEditController` own presentation state and screen events.
- **Incremental migration boundary**: controllers keep several responsibilities together because the case models a legacy MVC migration stage.
- **Safety rule**: controller scope stays per-screen; shared infrastructure, repositories, persistence stores, routers, and view-state builders remain separate.
- **No action/reducer scaffold**: this is not TCA/UDF/Reactor-style. SwiftUI calls explicit controller methods and controllers mutate their owned state directly.

## Verification

Use the case-local script so DerivedData, package caches, and result bundles remain inside this folder:

```zsh
./scripts/verify.sh static
./scripts/verify.sh build
./scripts/verify.sh test-build
```

Manual simulator, UI automation, and Instruments runs require separate approval.
