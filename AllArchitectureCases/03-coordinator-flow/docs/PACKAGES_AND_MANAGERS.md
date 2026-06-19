# Infrastructure And Reuse Guide

## Purpose
This document explains the current infrastructure ownership model for `MVVMExample`.

## Current Decision
`MVVMExample` intentionally does not keep local Swift Package folders. The app uses minimal app-local infrastructure under:

```text
./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport/
```

Do not recreate `./Packages/AppInfrastructure` or generic `./Packages/<AppPackage>` folders unless the user explicitly approves SwiftPM package-mode adoption again.

## Local Support Inventory
- `AppConfiguration`: runtime configuration, retry policy, demo credential gate, in-memory session store.
- `AppErrors`: app/API error taxonomy.
- `AppLocalization`: localization facade and user-safe error mapping support.
- `AppLogging`: no-op/redacting logger primitives.
- `AppNetworking`: request primitives, JSON body encoding, URLSession client, retry and redacted logging hooks.
- `AppImageLoading`: controlled remote image loading, downsampling, and bounded memory cache.
- `AppGlassUI`: Liquid Glass availability/fallback mechanics.

## Ownership Rules
- `LocalSupport` owns entity-agnostic mechanics needed by this app.
- App feature folders own DTOs, endpoint semantics, routing, ViewModels, UI composition, and product behavior.
- Reusable/cross-project documentation and source context live in `/Users/Artem/.zenflow/worktrees/new-task-be0b/documentation-vault/reusable/`.
- MVVMExample-specific durable docs live in `/Users/Artem/.zenflow/worktrees/new-task-be0b/documentation-vault/apps/MVVMExample/`.
- Cross-app context must be read through `documentation-vault/apps/<AppName>/`; do not copy TchopApp-specific rules into MVVMExample docs.

## Future Package Adoption
If SwiftPM package mode is needed later:

1. Get explicit user approval.
2. Use central reusable vault context as source material.
3. Wire only the required package(s).
4. Update local docs and vault copies together.
5. Run docs checks, `git diff --check`, and the approved Xcode build/test verification.
