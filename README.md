# MVVMExample

`MVVMExample` is a small SwiftUI iOS sample project for demonstrating a clear Model-View-ViewModel flow.

## Current State

This repository currently contains:

- a minimal SwiftUI iOS app target;
- reusable iOS production documentation and rules;
- project-local reusable skills under `./.codex/skills`;
- external skill snapshots under `./docs/reusable-baseline/external-environment`;
- Zenflow task artifacts under `./.zenflow/tasks/mvvmexample-3c80`.

## Goal

The app should stay intentionally small and educational. It should demonstrate how:

1. user actions enter a view model;
2. the view model updates presentation state;
3. SwiftUI renders from that state.

## Documentation Entry Point

Start with:

1. `./docs/README.md`
2. `./PROJECT_DOCUMENTATION.md`
3. `./PROJECT_HEALTH.md`
4. `./docs/CURRENT_USER_OVERRIDES.md`
5. `./docs/AGENT_RULES.md`
6. `./docs/WORK_CONTINUITY.md`

## Build

Open `./MVVMExample.xcodeproj` in Xcode and run the `MVVMExample` scheme.

Command-line build command will be finalized after the first verified build destination is selected.
