# Package Usage In MVVMExample

## Authority

This is a worktree-local operational summary. The current app decision is maintained in the canonical [MVVMExample project boundary](/Users/Artem/.zenflow/worktrees/documentation-vault/apps/MVVMExample/project-rules.md); reusable package rules remain in the canonical documentation vault.

## Current Decision

`MVVMExample` intentionally does not keep local Swift Package folders. The app uses the minimal infrastructure code it needs directly under:

```text
./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport/
```

Do not recreate `./Packages/AppInfrastructure` or generic `./Packages/<AppPackage>` folders unless the user explicitly approves SwiftPM package-mode adoption again.

## Local Support Areas

- `AppConfiguration`: runtime configuration, retry policy, demo credential gate, and in-memory session store.
- `AppErrors`: app/API error taxonomy.
- `AppLocalization`: localization facade and user-safe error-mapping support.
- `AppLogging`: no-op and redacting logger primitives.
- `AppNetworking`: request primitives, JSON body encoding, URLSession client, retry, and redacted logging hooks.
- `AppImageLoading`: controlled remote image loading, downsampling, and bounded memory cache.
- `AppGlassUI`: Liquid Glass availability and fallback mechanics.

## Ownership Rules

- `LocalSupport` owns entity-agnostic mechanics needed by this app.
- App feature folders own DTOs, endpoint semantics, routing, ViewModels, UI composition, and product behavior.
- Reusable and cross-project documentation live in `/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/`.
- MVVMExample-specific durable decisions live in `/Users/Artem/.zenflow/worktrees/documentation-vault/apps/MVVMExample/`.
- Read another app's context through its canonical `apps/<AppName>/` boundary; do not copy another app's rules into MVVMExample.

## Future Package Adoption

If SwiftPM package mode is needed later:

1. Get explicit user approval.
2. Use the canonical reusable vault as source material.
3. Wire only the required package(s).
4. Update the local operational summary and canonical app boundary together.
5. Run documentation checks and `git diff --check`; perform build/test verification only when explicitly authorized.

## Stop Rules

- Do not add local package folders to mirror the reusable baseline.
- Do not reintroduce `./Packages/AppInfrastructure` or generic `./Packages/<AppPackage>` folders.
- Do not create package wrappers around local support code.
- Keep product-specific DTOs, routes, ViewModels, and UI composition in the app layer.
