# Modular Architecture Standard

## Purpose
Rules for scaling large iOS codebases with modules/packages.

## Required Checks
- Dependency direction is acyclic.
- Feature modules do not depend on app shell implementation details.
- Shared modules contain reusable mechanics, not product-specific policy.
- App layer owns composition and product routing.
- Module APIs are minimal and stable.
- Build-time impact is considered before extracting modules.

## Forbidden By Default
- Circular dependencies.
- Shared module importing feature/app-specific code.
- Decorative wrappers around already-good package APIs.
- Module extraction without current reuse/boundary pressure.


## Reusable Infrastructure Naming
For new unrelated projects, reusable infrastructure packages must use neutral names such as `AppInfrastructure`, `AppNetworking`, `AppLocalization`, or `AppConfiguration`. Do not copy source-app branded package names such as `Tchop*` into a new generic project unless the user explicitly accepts that branding.

When promoting reusable behavior from one app to the baseline:
- generalize naming first;
- keep app-specific policy out of shared modules;
- copy mechanics, contracts, and tests only when they solve a current project need;
- add database, sync, media, widgets, push, share, AI, or payments modules only when the target project has current requirements for them.
