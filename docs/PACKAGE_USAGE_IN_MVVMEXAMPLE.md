# Package Usage In MVVMExample

## Current Decision

`MVVMExample` no longer keeps local Swift Package folders. The app uses the minimal infrastructure code it needs directly under:

```text
./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport/
```

This avoids duplicating the reusable package source already maintained by the TchopApp `./PackagesForReuse` vault.

## Local Support Areas

- `AppConfiguration`: runtime configuration, retry policy, demo credential gate, in-memory session store.
- `AppErrors`: app/API error taxonomy.
- `AppLocalization`: small localization facade.
- `AppLogging`: no-op/redacting logger primitives.
- `AppNetworking`: request primitives and URLSession network client.
- `AppImageLoading`: remote image loading, downsampling, and memory cache.
- `AppGlassUI`: Liquid Glass availability/fallback mechanics.

## Future Package Adoption

If this project later needs true SwiftPM package mode, copy the relevant package from TchopApp `./PackagesForReuse` into this worktree and wire only that package into Xcode. Until then, do not recreate `./Packages` here.

## Stop Rules

- Do not add local package folders just to mirror the reusable baseline.
- Do not reintroduce `./Packages/AppInfrastructure`.
- Do not create package wrappers around local support code.
- Keep product-specific DTOs, routes, ViewModels, and UI composition in the app layer.
