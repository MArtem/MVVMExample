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
For new unrelated projects, reusable infrastructure packages must use neutral names such as
`AppInfrastructure`, `AppNetworking`, `AppLocalization`, or `AppConfiguration`. Do not copy an
existing app's branded package names into a new generic project unless the user explicitly accepts
that branding.

When promoting reusable behavior from one app to the baseline:
- generalize naming first;
- keep app-specific policy out of shared modules;
- copy mechanics, contracts, and tests only when they solve a current project need;
- add database, sync, media, widgets, push, share, AI, or payments modules only when the target project has current requirements for them.

## Boundary Model And Worked Choice
A module exports a contract and creates a dependency edge. It does not acquire product
ownership merely by being reusable. Trace imports, resources, generated code, public types
and app/extension consumers before extracting it; a compiler boundary and a business boundary
can differ. Source-only adoption remains the current app policy unless a concrete exception
is approved; package documentation does not grant SwiftPM integration.

For example, a widget and app both format a product's date. A small neutral formatter with
explicit locale/calendar inputs may be shared; the app's entitlement, database and navigation
policy must not move with it. If only one caller needs the behavior, keeping it local can be
the correct alternative. Verify an acyclic import graph, resource ownership and the affected
consumer contract, then propose permitted builds only for actual adoption. Extraction alone
proves neither reduced build time nor behavior parity.

Primary theory: [Swift package/module model](https://www.swift.org/documentation/package-manager/)
and [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
Architecture-style choices remain in `IOS_ARCHITECTURE_STYLE_ROUTER.md`; this example selects
no new architecture or runtime dependency.
