# Testing Instructions

## Purpose
Active verification policy for `MVVMExample`.

## Default Rule
- Do not write or modify tests unless the user explicitly opens a test-writing phase or asks to fix a specific failing test.
- Do not run builds/tests/simulator UI/Instruments by default unless explicitly requested or already approved for the current implementation block.
- Use the cheapest verification path that proves the requested behavior.

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
# static
git diff --check

# project structure
xcodebuild -list -project MVVMExample.xcodeproj

# build, when approved/needed
xcodebuild -project MVVMExample.xcodeproj -scheme MVVMExample -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO build
```
