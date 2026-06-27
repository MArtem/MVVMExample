# Senior / Lead / Architect / Staff iOS Handbook — Master Outline

## Purpose
This document is the master plan for a deep textbook/reference about modern iOS development at Senior, Lead, Architect, and Staff levels.

It intentionally combines:
- practical iOS engineering;
- Swift language theory;
- under-the-hood runtime behavior;
- production architecture;
- debugging and performance expertise;
- security, privacy, release, observability, and operations;
- leadership, technical strategy, and staff-level decision making.

## Target Audience
- Middle iOS engineers growing into Senior roles.
- Senior iOS engineers growing into Lead / Staff roles.
- Tech Leads responsible for iOS delivery and architecture.
- Mobile architects defining standards across teams.
- Staff engineers building platform-level leverage.
- Interview candidates preparing for Senior+ iOS roles.
- Engineering managers with strong iOS technical context.

## Learning Levels Used In Every Chapter
Each chapter should be expanded later using four levels:

### Level 1 — Practical
- How to use the concept correctly.
- Common API usage.
- Simple examples.
- Basic mistakes.

### Level 2 — Senior
- Ownership rules.
- Failure behavior.
- Performance implications.
- Testability.
- Production constraints.

### Level 3 — Lead
- Migration strategy.
- Team boundaries.
- Review process.
- Delivery risks.
- Cross-feature consistency.

### Level 4 — Staff / Architect
- Tradeoff matrix.
- Long-term evolution.
- Platform strategy.
- Governance.
- Organizational impact.
- Cost of change.

## Standard Chapter Template
Every future chapter should follow this structure where applicable:

1. **Purpose**
2. **Mental model**
3. **Core theory**
4. **Under the hood**
5. **Production rules**
6. **Ownership and boundaries**
7. **Performance implications**
8. **Security/privacy implications**
9. **Testing strategy**
10. **Debugging scenarios**
11. **Common mistakes**
12. **Anti-patterns**
13. **Senior-level questions**
14. **Staff-level tradeoffs**
15. **Code examples to add later**
16. **Checklists**
17. **Exercises**
18. **Further reading / references to add later**

---

# Part I. The iOS Platform As An Engineering Environment

## 1. Apple ecosystem and platform constraints
### 1.1. iOS as a constrained runtime
### 1.2. Memory, battery, thermal, and network constraints
### 1.3. App sandbox and file-system boundaries
### 1.4. Privacy gates and permission model
### 1.5. Entitlements and system capabilities
### 1.6. Platform release cycle and WWDC-driven evolution
### 1.7. Deployment target strategy
### 1.8. Backward compatibility and deprecation handling
### 1.9. Hidden cost of supporting old iOS versions
### 1.10. Staff-level platform adoption strategy

## 2. App lifecycle and process behavior
### 2.1. Cold launch
### 2.2. Warm launch
### 2.3. Foreground activation
### 2.4. Background transition
### 2.5. Suspension and termination
### 2.6. Scene lifecycle
### 2.7. Multi-window behavior
### 2.8. State restoration
### 2.9. Launch-time dependency graph cost
### 2.10. Under the hood: dyld, Swift metadata loading, static initializers
### 2.11. Under the hood: main run loop and app startup path
### 2.12. Production launch-readiness checklist

## 3. System integrations
### 3.1. Push notifications
### 3.2. Silent push limits
### 3.3. Deep links
### 3.4. Universal links
### 3.5. Widgets
### 3.6. App Intents
### 3.7. Live Activities
### 3.8. Background tasks
### 3.9. Share extensions
### 3.10. Siri / Shortcuts
### 3.11. App Groups
### 3.12. Staff-level integration governance

---

# Part II. Swift Language Deep Dive

## 4. Swift fundamentals at Senior+ level
### 4.1. Value semantics
### 4.2. Reference semantics
### 4.3. Identity vs equality
### 4.4. Mutability control
### 4.5. Access control and API surface design
### 4.6. Error handling with `throws`
### 4.7. Optionals beyond basics
### 4.8. Pattern matching
### 4.9. Initialization rules
### 4.10. Deinitialization and lifetime
### 4.11. Language features that look simple but shape architecture

## 5. Swift memory model
### 5.1. Stack vs heap in practical Swift
### 5.2. Value witness tables
### 5.3. Copy / destroy / move operations
### 5.4. Copy-on-write internals
### 5.5. `isKnownUniquelyReferenced`
### 5.6. Hidden copies in hot paths
### 5.7. Large value pitfalls
### 5.8. Structs that should not be too large
### 5.9. ARC retain/release traffic
### 5.10. Weak reference tables
### 5.11. `unowned` crash semantics
### 5.12. Autorelease pools in mixed Swift/UIKit code
### 5.13. Memory ownership review checklist

## 6. Protocols, existentials, and generics
### 6.1. Protocols as behavior contracts
### 6.2. Protocols as architecture boundaries
### 6.3. Protocol overuse and decorative abstractions
### 6.4. Associated types
### 6.5. Existentials: `any Protocol`
### 6.6. Existential containers under the hood
### 6.7. Inline existential buffer
### 6.8. Witness tables
### 6.9. Opaque types: `some Protocol`
### 6.10. Generic constraints
### 6.11. Generic specialization
### 6.12. Conditional conformances
### 6.13. Type erasure
### 6.14. Phantom types
### 6.15. Compile-time vs runtime polymorphism
### 6.16. Staff-level API design with generics

## 7. Dispatch, metadata, and dynamic behavior
### 7.1. Static dispatch
### 7.2. Dynamic dispatch
### 7.3. Witness table dispatch
### 7.4. Objective-C message dispatch
### 7.5. `final` and devirtualization
### 7.6. `@objc`, `dynamic`, KVO, and bridging cost
### 7.7. Runtime metadata
### 7.8. Reflection limits
### 7.9. ABI stability
### 7.10. Module stability
### 7.11. Library evolution mode

## 8. Advanced Swift language tools
### 8.1. Property wrappers
### 8.2. Result builders
### 8.3. Macros
### 8.4. Key paths
### 8.5. Dynamic member lookup
### 8.6. Custom operators and why to avoid most of them
### 8.7. Codable internals and customization
### 8.8. Sendability annotations at language level
### 8.9. Debug vs Release language behavior
### 8.10. When language cleverness harms maintainability

---

# Part III. Swift Concurrency And Runtime Correctness

## 9. Async/await fundamentals
### 9.1. Structured concurrency
### 9.2. Parent-child task relationships
### 9.3. Task groups
### 9.4. Async let
### 9.5. Task priority
### 9.6. Priority inheritance
### 9.7. Suspension points
### 9.8. Why `await` does not mean background thread

## 10. Task runtime under the hood
### 10.1. Task tree
### 10.2. Cooperative scheduling
### 10.3. Cancellation propagation
### 10.4. Task locals
### 10.5. Unstructured `Task {}`
### 10.6. `Task.detached`
### 10.7. Lifecycle-owned tasks
### 10.8. Fire-and-forget risks
### 10.9. Production task ownership checklist

## 11. Actors and executors
### 11.1. Actor isolation
### 11.2. Actor reentrancy
### 11.3. Actor invariants
### 11.4. Nonisolated APIs
### 11.5. MainActor
### 11.6. Actor hopping
### 11.7. Default executor
### 11.8. Custom executors conceptually
### 11.9. Actor vs lock
### 11.10. Actor anti-patterns

## 12. Sendable and Swift 6 readiness
### 12.1. `Sendable`
### 12.2. `@unchecked Sendable`
### 12.3. Data race prevention
### 12.4. Closure sendability
### 12.5. Shared mutable state
### 12.6. Migration to strict concurrency
### 12.7. Compiler limitations
### 12.8. Staff-level concurrency migration plan

## 13. Cancellation and stale response safety
### 13.1. Cancellation is not interruption
### 13.2. `Task.isCancelled`
### 13.3. `Task.checkCancellation()`
### 13.4. Cancellation-safe repositories
### 13.5. Network cancellation
### 13.6. UI cancellation
### 13.7. Stale response protection
### 13.8. Generation counters
### 13.9. Cancellation testing

## 14. AsyncSequence and streams
### 14.1. AsyncSequence mental model
### 14.2. Buffering
### 14.3. Backpressure
### 14.4. Bridging delegate APIs
### 14.5. Notification streams
### 14.6. Stream cancellation
### 14.7. Memory leaks in streams
### 14.8. Testing streams

---

# Part IV. SwiftUI, UIKit, And UI Runtime

## 15. SwiftUI mental model
### 15.1. Declarative rendering
### 15.2. View values vs render tree
### 15.3. Body invalidation
### 15.4. Structural identity
### 15.5. Explicit identity
### 15.6. `.id()` pitfalls
### 15.7. Diffing mental model
### 15.8. Why view structs are cheap but body work is not
### 15.9. SwiftUI debugging mindset

## 16. SwiftUI state ownership
### 16.1. `@State`
### 16.2. `@Binding`
### 16.3. `@Observable`
### 16.4. `@Bindable`
### 16.5. `@Environment`
### 16.6. `@EnvironmentObject`
### 16.7. Legacy `ObservableObject`
### 16.8. State at wrong level
### 16.9. Source of truth vs derived state
### 16.10. Broad invalidation
### 16.11. Staff-level state ownership review

## 17. SwiftUI layout and rendering internals
### 17.1. Layout proposal / size / placement
### 17.2. Custom Layout
### 17.3. GeometryReader myths
### 17.4. Preference keys
### 17.5. ScrollView measurement traps
### 17.6. Transactions
### 17.7. Animation transactions
### 17.8. Environment propagation
### 17.9. Core Animation bridge
### 17.10. Render server basics

## 18. SwiftUI performance
### 18.1. Formatting in `body`
### 18.2. Creating formatters repeatedly
### 18.3. Image decoding in rows
### 18.4. `AnyView` and type erasure cost
### 18.5. Overusing `.id()`
### 18.6. Large observable objects
### 18.7. Lazy containers
### 18.8. Navigation transition hitches
### 18.9. Row hot-path checklist

## 19. UIKit and legacy interoperability
### 19.1. View controller lifecycle
### 19.2. Responder chain
### 19.3. Hit testing
### 19.4. Gesture recognizers
### 19.5. Run loop modes
### 19.6. Layout pass
### 19.7. Display pass
### 19.8. Core Animation transactions
### 19.9. `UIHostingController`
### 19.10. `UIViewRepresentable`
### 19.11. Coordinator pattern in representables
### 19.12. Legacy migration from UIKit to SwiftUI

---

# Part V. Architecture Fundamentals

## 20. Architecture thinking
### 20.1. What architecture is and is not
### 20.2. Architecture decisions
### 20.3. Reversibility
### 20.4. Cost of change
### 20.5. Local optimum vs global optimum
### 20.6. Architecture as risk management
### 20.7. Architecture as communication

## 21. Boundaries and coupling
### 21.1. UI boundary
### 21.2. Domain boundary
### 21.3. Data boundary
### 21.4. Infrastructure boundary
### 21.5. Feature boundary
### 21.6. Module boundary
### 21.7. Compile-time coupling
### 21.8. Runtime coupling
### 21.9. Data coupling
### 21.10. Temporal coupling
### 21.11. Semantic coupling
### 21.12. Organizational coupling

## 22. State and side-effect ownership
### 22.1. Source of truth
### 22.2. Derived state
### 22.3. Render state
### 22.4. Cache state
### 22.5. Persistent state
### 22.6. Server state
### 22.7. Optimistic state
### 22.8. UI side effects
### 22.9. Navigation side effects
### 22.10. Network side effects
### 22.11. Persistence side effects
### 22.12. Analytics/logging side effects

## 23. Architecture decay and governance
### 23.1. Boundary decay
### 23.2. Shortcut normalization
### 23.3. Architecture fitness functions
### 23.4. Exception process
### 23.5. Migration path
### 23.6. Sunset rules
### 23.7. Governance without bureaucracy

---

# Part VI. iOS Architecture Styles

## 24. MVVM with explicit intents
### 24.1. ViewModel responsibilities
### 24.2. Explicit intent API
### 24.3. ViewState builders
### 24.4. Async task lifecycle
### 24.5. User-safe error mapping
### 24.6. Navigation ownership
### 24.7. Testing ViewModels
### 24.8. Generic `send(_:)` anti-pattern

## 25. SwiftUI Native State / MV
### 25.1. When ViewModels are unnecessary
### 25.2. View-owned state
### 25.3. Lifecycle models
### 25.4. Local state vs domain state
### 25.5. When MV becomes renamed MVVM

## 26. Coordinator / Flow
### 26.1. Coordinator responsibilities
### 26.2. Router vs Coordinator
### 26.3. Flow state
### 26.4. Deep links
### 26.5. App/session lifecycle separation
### 26.6. Coordinator side-effect anti-pattern

## 27. Clean / Layered architecture
### 27.1. Presentation layer
### 27.2. Domain layer
### 27.3. Data layer
### 27.4. Infrastructure layer
### 27.5. Boundary contracts
### 27.6. Clean without use-case ceremony

## 28. Modular / Feature-Sliced architecture
### 28.1. Feature slices
### 28.2. App shell
### 28.3. Shared/Core rules
### 28.4. Dependency direction
### 28.5. Cross-feature communication
### 28.6. Module extraction strategy
### 28.7. Build time implications

## 29. Hexagonal / Ports & Adapters
### 29.1. Ports
### 29.2. Driving adapters
### 29.3. Driven adapters
### 29.4. Domain purity
### 29.5. DTO/error mapping at boundaries
### 29.6. Avoiding protocol explosion

## 30. Redux / Elm / UDF
### 30.1. State
### 30.2. Actions
### 30.3. Mutations
### 30.4. Reducers
### 30.5. Effects
### 30.6. Store scope
### 30.7. Traceable feature state

## 31. TCA-style architecture
### 31.1. TCA mental model
### 31.2. Full state-machine state
### 31.3. Reducer composition
### 31.4. Effects and cancellation
### 31.5. Dependencies
### 31.6. Navigation in TCA
### 31.7. Third-party TCA vs lightweight TCA style

## 32. Reactor-style architecture
### 32.1. Reactor responsibilities
### 32.2. Action / Mutation / State
### 32.3. `mutate`
### 32.4. `reduce`
### 32.5. Rx vs async/await variants
### 32.6. SwiftUI integration

## 33. MVC migration architecture
### 33.1. Legacy MVC reality
### 33.2. Bounded controllers
### 33.3. Massive ViewController risks
### 33.4. Migration seams
### 33.5. When MVC is acceptable

## 34. MVP Passive View
### 34.1. Passive view principle
### 34.2. Presenter ownership
### 34.3. SwiftUI passive view adaptation
### 34.4. Avoiding decorative view protocols

## 35. VIP / Clean Swift
### 35.1. View
### 35.2. Interactor
### 35.3. Presenter
### 35.4. Router
### 35.5. Worker
### 35.6. Request / Response / ViewModel roles
### 35.7. Scene builders

## 36. VIPER
### 36.1. View
### 36.2. Interactor
### 36.3. Presenter
### 36.4. Entity
### 36.5. Router
### 36.6. Builder
### 36.7. VIPER in SwiftUI
### 36.8. Presenter-heavy anti-pattern

## 37. RIBs
### 37.1. Router
### 37.2. Interactor
### 37.3. Builder
### 37.4. Component
### 37.5. Attach/detach lifecycle
### 37.6. Dependency propagation
### 37.7. RIBs-inspired SwiftUI

---

# Part VII. Modularization, Packages, And Scaling

## 38. Codebase scaling
### 38.1. Monolith vs modular app
### 38.2. Package boundaries
### 38.3. Xcode project structure
### 38.4. Build-time management
### 38.5. Team ownership
### 38.6. Public API control
### 38.7. Internal platform modules

## 39. Dependency management
### 39.1. SwiftPM
### 39.2. Binary dependencies
### 39.3. Third-party risk
### 39.4. Update policy
### 39.5. Security review
### 39.6. Dependency isolation

## 40. Design systems
### 40.1. Tokens
### 40.2. Components
### 40.3. Theming
### 40.4. Accessibility by default
### 40.5. Localization support
### 40.6. Design system governance

---

# Part VIII. Networking And API Contracts

## 41. Networking foundations
### 41.1. URLSession
### 41.2. Request modeling
### 41.3. Response validation
### 41.4. Decoding
### 41.5. Cancellation
### 41.6. Timeouts
### 41.7. Retries

## 42. URLSession under the hood
### 42.1. DNS
### 42.2. TCP/TLS
### 42.3. HTTP/2 multiplexing
### 42.4. Connection reuse
### 42.5. URL cache
### 42.6. Default / ephemeral / background sessions
### 42.7. Timeout semantics
### 42.8. Expensive and constrained networks

## 43. API contract design
### 43.1. DTOs
### 43.2. Domain mapping
### 43.3. Pagination
### 43.4. Sorting and filtering
### 43.5. Idempotency
### 43.6. Partial success
### 43.7. Versioning
### 43.8. Backward-compatible mobile APIs

## 44. Auth and sessions
### 44.1. Login flows
### 44.2. Token storage
### 44.3. Refresh tokens
### 44.4. Expiration
### 44.5. Logout
### 44.6. Session restoration
### 44.7. Multi-account support

## 45. Network resilience
### 45.1. Offline behavior
### 45.2. Retryable vs non-retryable failures
### 45.3. Backoff and jitter
### 45.4. Circuit breakers
### 45.5. Herd effects
### 45.6. User feedback

---

# Part IX. Persistence, Local Data, And Sync

## 46. Persistence options
### 46.1. UserDefaults
### 46.2. Keychain
### 46.3. Files
### 46.4. SQLite
### 46.5. Core Data
### 46.6. SwiftData
### 46.7. App Groups

## 47. SwiftData / Core Data deep dive
### 47.1. Object graph
### 47.2. Identity
### 47.3. Faulting
### 47.4. Context ownership
### 47.5. Change tracking
### 47.6. Context concurrency
### 47.7. Merge policies
### 47.8. Migrations
### 47.9. Query performance
### 47.10. Indexing and fetch limits

## 48. Offline-first and sync
### 48.1. Local source of truth
### 48.2. Pending mutations
### 48.3. Idempotency keys
### 48.4. Conflict resolution
### 48.5. Tombstones
### 48.6. Local IDs vs server IDs
### 48.7. Last-write-wins risks
### 48.8. CRDT overview
### 48.9. Replay policy
### 48.10. Sync observability

## 49. Data safety
### 49.1. Secrets vs non-secrets
### 49.2. File protection
### 49.3. Destructive migrations
### 49.4. Backup behavior
### 49.5. Data deletion
### 49.6. GDPR/CCPA-style requirements

---

# Part X. Security And Privacy

## 50. iOS security model
### 50.1. Sandbox
### 50.2. Keychain
### 50.3. Entitlements
### 50.4. App Groups
### 50.5. Secure Enclave
### 50.6. Biometrics

## 51. Threat modeling for iOS
### 51.1. Casual attacker
### 51.2. Jailbroken device
### 51.3. Network attacker
### 51.4. Malicious dependency
### 51.5. Insider/log access
### 51.6. Server trust boundaries

## 52. Secure coding
### 52.1. Secret lifecycle
### 52.2. Token storage
### 52.3. Log redaction
### 52.4. TLS and ATS
### 52.5. Certificate pinning tradeoffs
### 52.6. Input validation
### 52.7. Reverse engineering limits

## 53. Privacy engineering
### 53.1. Data minimization
### 53.2. Permission prompts
### 53.3. Privacy manifests
### 53.4. App Store privacy labels
### 53.5. Analytics privacy
### 53.6. Crash report privacy

---

# Part XI. Performance And Profiling

## 54. Performance mindset
### 54.1. What users feel
### 54.2. Frame budgets
### 54.3. Main-thread budget
### 54.4. Measurement vs statically obvious fixes
### 54.5. Regression prevention

## 55. Launch performance
### 55.1. Cold launch
### 55.2. Main-thread startup work
### 55.3. Dependency graph startup
### 55.4. Lazy loading
### 55.5. Launch metrics
### 55.6. dyld and library loading

## 56. CPU profiling
### 56.1. Time Profiler
### 56.2. Self weight vs total weight
### 56.3. Stack interpretation
### 56.4. Symbolication
### 56.5. Algorithmic complexity in UI
### 56.6. Sorting/filtering in hot paths

## 57. Memory performance
### 57.1. Heap growth
### 57.2. Retain cycles
### 57.3. Cache design
### 57.4. Image memory
### 57.5. Data blobs
### 57.6. Memory pressure
### 57.7. Jetsam

## 58. Image pipeline performance
### 58.1. Compressed vs decoded image
### 58.2. Downsampling
### 58.3. Decompression
### 58.4. Cache cost
### 58.5. Scroll cancellation
### 58.6. Memory pressure handling

## 59. Rendering and scrolling performance
### 59.1. Core Animation layer tree
### 59.2. Render server
### 59.3. Offscreen rendering
### 59.4. Blending
### 59.5. Shadows and masks
### 59.6. Scroll hitches
### 59.7. Pagination backpressure

## 60. Profiling tools
### 60.1. Instruments overview
### 60.2. Time Profiler
### 60.3. Allocations
### 60.4. Leaks
### 60.5. Hangs
### 60.6. Network instruments
### 60.7. Points of Interest
### 60.8. MetricKit

---

# Part XII. Accessibility, Localization, And Inclusive UX

## 61. Accessibility
### 61.1. VoiceOver
### 61.2. Labels, hints, traits
### 61.3. Dynamic Type
### 61.4. Focus order
### 61.5. Tap targets
### 61.6. Reduce Motion
### 61.7. Contrast
### 61.8. Accessibility testing
### 61.9. Accessibility as architecture constraint

## 62. Localization
### 62.1. `.xcstrings`
### 62.2. Plurals
### 62.3. Dates and numbers
### 62.4. RTL
### 62.5. String interpolation
### 62.6. Pseudolocalization
### 62.7. Localization QA
### 62.8. Localization performance pitfalls

---

# Part XIII. Testing And Quality Strategy

## 63. Testing pyramid for iOS
### 63.1. Unit tests
### 63.2. Integration-style tests
### 63.3. Snapshot tests
### 63.4. UI tests
### 63.5. Manual QA
### 63.6. Exploratory testing

## 64. XCTest and Swift Testing
### 64.1. XCTest basics
### 64.2. Swift Testing basics
### 64.3. Async tests
### 64.4. Test traits/tags
### 64.5. Test data builders
### 64.6. Determinism
### 64.7. Flakiness diagnosis

## 65. Architecture testing
### 65.1. ViewModel tests
### 65.2. Store/reducer tests
### 65.3. Interactor tests
### 65.4. Presenter tests
### 65.5. Coordinator/router tests
### 65.6. Repository tests
### 65.7. Persistence tests
### 65.8. Boundary contract tests

## 66. UI and accessibility testing
### 66.1. XCUITest
### 66.2. Accessibility identifiers
### 66.3. Smoke tests
### 66.4. UI test architecture
### 66.5. Simulator matrix
### 66.6. Result bundles

---

# Part XIV. CI/CD And Release Engineering

## 67. Build system
### 67.1. Xcode build pipeline
### 67.2. Schemes
### 67.3. Configurations
### 67.4. DerivedData
### 67.5. Module cache
### 67.6. Incremental compilation
### 67.7. Build log analysis

## 68. Swift compiler and binary behavior
### 68.1. Type-checker performance
### 68.2. Result-builder compile-time explosions
### 68.3. Generic constraints and compile time
### 68.4. Dead stripping
### 68.5. Symbol visibility
### 68.6. Binary size
### 68.7. Debug vs Release performance

## 69. CI pipelines
### 69.1. GitHub Actions / Bitrise / Xcode Cloud
### 69.2. Static gates
### 69.3. Unit test lanes
### 69.4. UI test lanes
### 69.5. Artifacts
### 69.6. Failure triage
### 69.7. Cache strategy

## 70. Signing and provisioning
### 70.1. Certificates
### 70.2. Provisioning profiles
### 70.3. Entitlements
### 70.4. App groups
### 70.5. CI signing
### 70.6. Signing incident response

## 71. App Store release
### 71.1. Archives
### 71.2. TestFlight
### 71.3. Phased rollout
### 71.4. App Review
### 71.5. Rollback strategy
### 71.6. Release notes
### 71.7. Production readiness checklist

---

# Part XV. Observability And Operations

## 72. Logging
### 72.1. OSLog
### 72.2. Redaction
### 72.3. Log levels
### 72.4. Structured logs
### 72.5. Correlation IDs
### 72.6. Supportability

## 73. Analytics
### 73.1. Event taxonomy
### 73.2. Privacy-safe analytics
### 73.3. Product metrics
### 73.4. Funnel analysis
### 73.5. Experimentation

## 74. Crash reporting
### 74.1. Crash symbolication
### 74.2. dSYM upload
### 74.3. Crash triage
### 74.4. Non-fatal errors
### 74.5. Regression detection

## 75. Runtime monitoring and incidents
### 75.1. MetricKit
### 75.2. Performance dashboards
### 75.3. Network metrics
### 75.4. Mobile incident constraints
### 75.5. Kill switches
### 75.6. Postmortems

---

# Part XVI. Engineering Leadership

## 76. Senior engineer execution
### 76.1. Ownership
### 76.2. Risk identification
### 76.3. Technical planning
### 76.4. Communication
### 76.5. Estimation
### 76.6. Scope control

## 77. Tech Lead skills
### 77.1. Breaking down work
### 77.2. Delegation
### 77.3. Review quality
### 77.4. Mentorship
### 77.5. Cross-functional work
### 77.6. Delivery without heroics

## 78. Staff engineer skills
### 78.1. Influence without authority
### 78.2. Technical strategy
### 78.3. Engineering leverage
### 78.4. Standards and governance
### 78.5. RFCs and ADRs
### 78.6. Long-term maintainability
### 78.7. When to say no

## 79. Technical debt and strategy
### 79.1. Deliberate debt
### 79.2. Accidental debt
### 79.3. Bit rot
### 79.4. Architecture erosion
### 79.5. Knowledge debt
### 79.6. Debt repayment strategy

---

# Part XVII. Code Review, Documentation, And Knowledge Sharing

## 80. Code review
### 80.1. Correctness
### 80.2. Architecture
### 80.3. Security
### 80.4. Performance
### 80.5. Accessibility
### 80.6. Testing
### 80.7. Review comments style

## 81. Code documentation
### 81.1. What to document
### 81.2. What not to document
### 81.3. Ownership comments
### 81.4. Side-effect comments
### 81.5. API contracts
### 81.6. Temporary workaround comments
### 81.7. Documentation decay

## 82. Project documentation
### 82.1. README
### 82.2. Architecture docs
### 82.3. Testing instructions
### 82.4. Release docs
### 82.5. Runbooks
### 82.6. Onboarding docs

---

# Part XVIII. Product Engineering And Requirements

## 83. Product requirements
### 83.1. Acceptance criteria
### 83.2. Non-goals
### 83.3. Edge cases
### 83.4. Ambiguity resolution
### 83.5. Product tradeoffs

## 84. Feature planning
### 84.1. Scope slicing
### 84.2. Vertical slices
### 84.3. Technical milestones
### 84.4. Rollout flags
### 84.5. Telemetry plan

## 85. Experimentation
### 85.1. Feature flags
### 85.2. A/B tests
### 85.3. Remote config
### 85.4. Kill switches
### 85.5. Ethical experimentation

---

# Part XIX. Debugging Mastery

## 86. Debugging mental models
### 86.1. Reproduction
### 86.2. Minimal repro
### 86.3. Determinism
### 86.4. State capture
### 86.5. Timeline reconstruction

## 87. LLDB
### 87.1. Breakpoints
### 87.2. Conditional breakpoints
### 87.3. Watchpoints
### 87.4. Expression evaluation
### 87.5. Thread inspection
### 87.6. Swift concurrency debugging

## 88. Log-driven debugging
### 88.1. Correlation IDs
### 88.2. Redacted context
### 88.3. Breadcrumbs
### 88.4. Support logs
### 88.5. Debugging without user data leakage

---

# Part XX. Practical Case Studies

## 89. News/feed app case study
### 89.1. Requirements
### 89.2. MVVM implementation
### 89.3. UDF implementation
### 89.4. Clean implementation
### 89.5. VIPER implementation
### 89.6. Tradeoff comparison

## 90. Auth/session case study
### 90.1. Login
### 90.2. Token storage
### 90.3. Refresh
### 90.4. Logout
### 90.5. Session restoration
### 90.6. Security review

## 91. Offline sync case study
### 91.1. Local-first state
### 91.2. Pending mutations
### 91.3. Conflict resolution
### 91.4. Retry/backoff
### 91.5. UI feedback

## 92. Large app modularization case study
### 92.1. Starting monolith
### 92.2. Boundary discovery
### 92.3. Package extraction
### 92.4. Build performance
### 92.5. Team ownership

---

# Part XXI. Interview And Calibration Materials

## 93. Senior iOS interview topics
### 93.1. Swift
### 93.2. Concurrency
### 93.3. SwiftUI
### 93.4. Architecture
### 93.5. Networking
### 93.6. Persistence
### 93.7. Testing
### 93.8. Performance

## 94. Lead / Staff interview topics
### 94.1. System design
### 94.2. Architecture review
### 94.3. Technical strategy
### 94.4. Incident handling
### 94.5. Mentorship
### 94.6. Cross-team influence

## 95. Question bank
### 95.1. Theory questions
### 95.2. Practical coding questions
### 95.3. Debugging scenarios
### 95.4. Architecture scenarios
### 95.5. Behavioral questions

## 96. Answer rubrics
### 96.1. Junior answer
### 96.2. Middle answer
### 96.3. Senior answer
### 96.4. Staff answer
### 96.5. Red flags

---

# Part XXII. Appendices

## 97. Checklists
### 97.1. Feature readiness checklist
### 97.2. PR checklist
### 97.3. Release checklist
### 97.4. Architecture review checklist
### 97.5. Security checklist
### 97.6. Performance checklist
### 97.7. Accessibility checklist

## 98. Templates
### 98.1. ADR template
### 98.2. RFC template
### 98.3. Incident report template
### 98.4. Release plan template
### 98.5. Test plan template
### 98.6. Architecture review template

## 99. Glossary
### 99.1. Swift terms
### 99.2. iOS platform terms
### 99.3. Architecture terms
### 99.4. Networking terms
### 99.5. Release terms

## 100. Exercises
### 100.1. Refactor a ViewModel
### 100.2. Design offline sync
### 100.3. Profile a scrolling list
### 100.4. Build a modular feature
### 100.5. Write an ADR
### 100.6. Review a production incident

---

# Expansion Backlog For Future Writing

## Theory blocks to add per chapter
- Mental model diagrams.
- Runtime diagrams.
- Tradeoff tables.
- Senior pitfalls.
- Staff-level decision criteria.
- Production incident examples.

## Q&A blocks to add per chapter
- Basic comprehension questions.
- Senior interview questions.
- Staff architecture questions.
- Debugging questions.
- Red-flag answers.

## Code examples to add per chapter
- Minimal example.
- Production-shaped example.
- Anti-pattern example.
- Refactoring example.
- Test example.

## Review assets to add per chapter
- PR checklist.
- Architecture review checklist.
- Performance review checklist.
- Security/privacy review checklist.
- Release-readiness checklist.
