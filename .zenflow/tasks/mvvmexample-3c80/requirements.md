# Product Requirements Document: MVVMExample

## Overview

**MVVMExample** is an educational iOS sample application intended to demonstrate a clear Model-View-ViewModel user experience through a small, understandable app flow. The product should help developers quickly understand how user-facing state, user actions, and displayed data relate to each other in an MVVM-style application.

## Context

The current repository does not contain application source code yet. The only existing project artifact is the Zenflow workflow plan at `./.zenflow/tasks/mvvmexample-3c80/plan.md`. Because the feature description is limited to “MVVMExample”, this PRD records product-level assumptions for the next specification stage.

## User Clarification

The user clarified that the target platform is **iOS SwiftUI**. The expected result type was not explicitly selected, so this PRD assumes the goal is an **educational demo application**, not a reusable starter template or production app.

## Goals

1. **Demonstrate MVVM clearly**
   - Users should be able to see a simple app experience where displayed data, actions, and screen state are easy to reason about.
   - The example should make the role of the view model understandable from the user-facing behavior.

2. **Provide a small but complete app flow**
   - The app should include at least one primary screen with visible state and user interaction.
   - The app should include a simple data-driven experience, such as a list of sample items, item details, or a small interactive counter/task flow.

3. **Support learning and onboarding**
   - A developer opening the project should quickly understand what the example demonstrates.
   - The app should avoid unnecessary product complexity that distracts from the MVVM concept.

4. **Be suitable for local demonstration**
   - The app should run without requiring accounts, remote services, paid APIs, or manual backend setup.
   - Demo data should be available immediately so the first launch is useful.

## Target Users

- **Primary users**: Developers learning MVVM in an iOS app context.
- **Secondary users**: Reviewers or educators who need a concise MVVM example to explain app structure and state-driven UI behavior.

## User Experience Requirements

1. **First launch experience**
   - The user should immediately see meaningful sample content or an obvious interactive example.
   - The app should not start with a blank screen or require configuration.

2. **Primary interaction**
   - The user should be able to perform at least one simple action that changes visible app state.
   - The result of the action should be immediate and understandable.

3. **Data presentation**
   - The app should present sample data in a readable format.
   - If a list/detail flow is used, selecting an item should show more information about that item.

4. **State feedback**
   - The app should show user-facing state transitions where appropriate, such as loading, empty, populated, or error-like sample states.
   - Any error or empty state should be understandable and recoverable in the demo context.

5. **Clarity over breadth**
   - The app should prioritize a small, polished example over many loosely connected features.
   - Copy and labels should make the demo purpose clear.

## Functional Requirements

1. **Sample content**
   - The app must include built-in sample data or deterministic demo state.
   - The sample content must be available offline.

2. **Interactive state change**
   - The app must include at least one user action that updates displayed state.
   - The state change must be visible without navigating away or restarting the app.

3. **MVVM demonstration value**
   - The selected app flow must make it possible to explain how user actions affect state and how state affects the UI.
   - The example must avoid hidden behavior that would make the flow difficult to follow.

4. **No required external dependencies for use**
   - The app must not require login, network connectivity, or a remote service to demonstrate its core behavior.

5. **Project discoverability**
   - The project should include enough user-facing or repository-facing explanation for a developer to understand the demo goal.

## Non-Goals

- Building a production-ready application.
- Adding authentication, user accounts, payments, analytics, or remote backend integration.
- Demonstrating every MVVM variation or advanced architecture pattern.
- Creating a generic project generator or template unless later requested.
- Supporting non-iOS platforms in the initial scope.

## Assumptions

- The feature should be delivered as a small educational iOS sample app.
- The app should focus on one coherent demo flow, likely a simple list/detail or stateful sample feature.
- Offline demo data is sufficient for the initial version.
- Accessibility and readability should be considered at the product level, even though detailed implementation decisions belong in the technical specification.

## Success Criteria

1. A developer can launch the app and understand the purpose of the MVVM example within the first minute.
2. The app shows meaningful content on first launch without external setup.
3. At least one visible user interaction changes app state in a way that supports explaining MVVM.
4. The example remains intentionally small and avoids unrelated product features.
5. The repository contains this PRD and is ready for a follow-up technical specification.
