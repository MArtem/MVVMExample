# iOS Reusable Infrastructure Package Standard

## Purpose
Define how reusable package/manager behavior should be promoted across iOS projects without carrying source-app branding or product assumptions.

## Default Package Shape For New Projects
For a new unrelated iOS project, start with a neutral infrastructure package only when the project has current implementation pressure for shared mechanics.

Recommended initial structure:

```text
Packages/AppInfrastructure/
  Sources/
    AppNetworking/
    AppErrors/
    AppLocalization/
    AppConfiguration/
    AppLogging/
```

Optional modules can be added only when requirements exist:

```text
AppAnalytics
AppCache
AppSession
AppDatabase
AppSync
AppMedia
AppPermissions
AppPushNotifications
AppWidgets
AppPayments
```

## Naming Rule
Reusable infrastructure copied into a new generic project must use neutral names such as `AppInfrastructure`, `AppNetworking`, `AppLocalization`, or `AppConfiguration`.

Do not copy source-app branded names such as `Tchop*` into unrelated projects unless the user explicitly accepts that branding.

## Promotion Rule
When promoting behavior from an existing app package into the reusable baseline:

1. Copy the mechanic, not the product policy.
2. Remove app names, paths, endpoints, copy, product entities, feature assumptions, and task history.
3. Keep APIs minimal and composable.
4. Keep dependency direction acyclic.
5. Add only modules needed by the current target project.
6. Document remaining app-specific policies in the app, not the package.

## Initial Module Responsibilities

### `AppNetworking`
Owns:
- HTTP method and request models;
- API configuration and base URL injection;
- URLSession execution;
- timeout/cancellation/error mapping;
- JSON body encoding/decoding;
- redacted request diagnostics hooks.

Does not own:
- app DTOs;
- endpoint semantics;
- auth/session product behavior;
- UI messages.

### `AppErrors`
Owns:
- app-facing error categories;
- retry/session-recovery hints;
- stable error mapping interfaces;
- supportable debug descriptions without sensitive data.

Does not own:
- feature copy;
- final localized strings unless injected through a catalog.

### `AppLocalization`
Owns:
- localization facade;
- bundle-backed lookup;
- fallback behavior;
- locale override support;
- formatting entry points.

Does not own:
- product copy decisions.

### `AppConfiguration`
Owns:
- environment selection;
- base URL selection;
- debug/demo/prod gating;
- feature flag defaults;
- diagnostics/logging mode.

Does not own:
- hardcoded production secrets;
- silent fallback from production to demo/stub behavior.

### `AppLogging`
Owns:
- logging facade;
- redaction rules;
- log levels;
- sink abstraction.

Does not own:
- sensitive payload logging by default.

## Demo/Test API Policy
Demo/test APIs and test credentials are allowed in demo/pre-production projects only when explicitly configured:

- test base URL comes from `AppConfiguration`;
- test credentials are gated by debug/demo mode;
- release/production cannot silently use demo credentials, stubs, fake sessions, or preview tokens;
- token-like fixture strings are either removed, generated, or allowlisted as safe fixtures with clear naming.

## Stop Rules
- Do not add a package only for architecture symmetry.
- Do not create decorative wrappers around a package API that already fits.
- Do not introduce database/sync/media/widgets/push/share/AI/payments modules before the project has current requirements.
- Do not put app-specific endpoint semantics, DTOs, copy, routing, schemas, or session product policy into generic packages.
- Do not let source-app naming leak into reusable packages for unrelated projects.
