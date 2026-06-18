# Testing Instructions

## Purpose
Active verification policy for `MVVMExample`.

## Default Rule
- Do not write or modify tests unless the user explicitly opens a test-writing phase or asks to fix a specific failing test.
- Do not run builds/tests/simulator UI/Instruments by default unless explicitly requested or already approved for the current implementation block.
- Use the cheapest verification path that proves the requested behavior.

## Current Approved Test Layout
- `./MVVMExample.xctestplan` is the fast unit-test lane and contains `MVVMExampleTests` only.
- `./MVVMExampleUI.xctestplan` is the explicit UI accessibility smoke lane and contains `MVVMExampleUITests` only.
- UI tests are intentionally separate from the default unit lane because they require simulator execution and are slower/flakier than deterministic unit tests.

## Verification Levels
### Absent
- no build
- no tests
- no simulator/manual verification

### Low
- project structure/static verification only

### Medium
- targeted build/tests relevant to the change

### Full
- full build/test matrix/manual or profiler validation when required

## Project Commands
```zsh
# static gates
./scripts/verify.sh static

# project structure
./scripts/verify.sh list

# build, when approved/needed
./scripts/verify.sh build

# deterministic unit tests, when approved/needed
./scripts/verify.sh test-unit

# UI accessibility smoke tests, only when explicitly approved/needed
./scripts/verify.sh test-ui

# static + list + build + unit tests; UI remains explicit
./scripts/verify.sh all
```

## Sandbox Requirement
All build/test artifacts, DerivedData, cloned package state, logs, and temporary outputs must stay under `/Users/Artem/.zenflow`. Do not use `/Users/Artem/Library`, `/tmp`, or global SwiftPM/Xcode caches.
