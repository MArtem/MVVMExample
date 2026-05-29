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
