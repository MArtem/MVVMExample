# iOS Code Documentation Standard

## Purpose
Define a unified, low-noise standard for documenting Swift/iOS code contracts directly in code.

## Core Principle
Document contracts, not obvious code.

A comment is required when a future developer or AI agent could misuse the type, method, property, or flow without understanding ownership, usage context, side effects, concurrency, errors, invariants, or rationale.

## What To Document
Document these by default:
- public/internal protocols and APIs
- ViewModels and state owners
- repositories, stores, caches, sync services, clients, managers
- mappers and boundary translators
- actors and thread-safe components
- navigation/router/coordinator entry points
- async methods and task owners
- methods with side effects
- computed properties read in UI/render hot paths
- persistence records or migration-sensitive models
- platform capability wrappers: Bluetooth, Camera, Photos, Files, Location, Push, App Groups, StoreKit
- non-obvious SwiftUI views or reusable UI components
- temporary workarounds and compatibility bridges

Do not document obvious private helpers, trivial properties, or code where a better name would remove the need for a comment.

## Required Comment Dimensions
Use only the dimensions that are relevant. Do not force every block into every comment.

### Purpose
Why the entity exists.

### Responsibilities
What it owns and what it explicitly does not own.

### Ownership / Created By
Who owns or creates the entity in runtime terms.

Use stable ownership descriptions:
- screen composition layer
- dependency container
- repository
- sync scheduler
- platform delegate
- app lifecycle owner
- feature coordinator

Do not use personal authorship or fragile implementation facts.

Good:
```swift
/// Ownership:
/// Created by the feed composition layer. One instance is owned by one feed screen flow.
```

Avoid:
```swift
/// Created by Artem.
/// Created by `SomeView`.
```

A concrete caller/type may be named only when it is part of the actual API contract and expected to remain stable.

### External Usage / Call Context
For methods/properties used outside their declaring type, document who may call them and when.

Prefer scenario-based call context over brittle exhaustive caller lists.

Good:
```swift
/// External usage:
/// Called by user-triggered refresh flows such as pull-to-refresh and retry.
```

Good when the caller is contractual:
```swift
/// External usage:
/// Called by `UIApplicationDelegate` during remote notification registration callbacks.
```

Avoid:
```swift
/// Called by FeedView, HomeView, SearchView.
```

### Behavior
Important state transitions, loading/refresh/error/offline/retry behavior.

### Side Effects
State, cache, database, file, network, navigation, analytics, sync, device connection, or permission effects.

### Concurrency
Actor isolation, main-thread expectations, task ownership, cancellation, stale-response handling, thread safety.

### Errors / Failure Behavior
Thrown errors, non-throwing failure presentation, retry behavior, rollback behavior.

### Invariants
Rules that must always remain true.

### Rationale
Why the implementation uses this shape when it is not obvious.

### Temporary Workaround / Expiry
Temporary comments must include reason and revisit condition.

Good:
```swift
/// Temporary workaround:
/// SwiftData `#Predicate` currently produces Swift 6 warnings for this model.
/// Revisit after upgrading the Xcode toolchain.
```

## Templates

### Type / ViewModel / Service
```swift
/// Owns presentation state and user actions for the feed screen.
///
/// Responsibilities:
/// - prepares visible content;
/// - handles user-triggered actions;
/// - keeps UI state isolated on the main actor.
///
/// Ownership:
/// Created by the screen composition layer. One instance is owned by one screen flow.
///
/// Important:
/// DTO and persistence models must not be exposed from this type.
@MainActor
final class FeedViewModel {
}
```

### Method With External Usage
```swift
/// Refreshes current content without replacing it with a full-screen loader.
///
/// External usage:
/// Called by user-triggered refresh flows: pull-to-refresh and non-blocking retry.
///
/// Behavior:
/// - preserves current content while refresh is running;
/// - replaces content on success;
/// - keeps old content and reports failure on error;
/// - ignores `CancellationError`.
func refresh() async {
}
```

### Computed Property In UI Hot Path
```swift
/// Precomputed cards visible in the current feed state.
///
/// This value must stay cheap to read because SwiftUI may access it during
/// body evaluation. Expensive filtering/sorting must happen when inputs change.
var visibleContent: FeedVisibleContent {
    currentVisibleContent
}
```

## Review Checklist
Before adding a comment, ask:
- Does this explain a contract rather than repeat code?
- Is ownership/lifecycle unclear without it?
- Is this API used outside its declaring type?
- Are side effects or failure behavior non-obvious?
- Are concurrency/cancellation/thread-safety rules important?
- Is there an invariant or rationale that future edits could break?
- Will this comment stay true if a concrete caller changes?

## Stop Rules
- Do not document every method mechanically.
- Do not duplicate the method name in prose.
- Do not list fragile callers unless the caller is contractual.
- Do not claim thread safety, performance, or failure behavior that code does not guarantee.
- Do not leave temporary workaround comments without reason and revisit condition.
