# CI/CD Quality Gates

## Purpose
Rules for automated quality gates in iOS development.

## Recommended CI Gates
- Clean build for supported simulator/device matrix.
- Unit tests where test phase is enabled.
- UI smoke tests for release-critical flows where stable.
- Static formatting/linting if configured.
- Secret scan.
- Dependency/license review for new packages.
- Archive/signing check for release branches.
- dSYM/upload check for release builds.
- Privacy manifest and Info.plist permission review.

## PR Gate Output
Each PR/review should state:
1. CI checks required.
2. CI checks run/passed/failed.
3. Local checks run.
4. Manual checks needed before merge/release.
