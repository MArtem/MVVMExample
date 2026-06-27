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
#### Expected depth of explanation
#### Signals that the reader has mastered this level
#### Typical mistakes at this level
#### Exercises and assessment prompts
- How to use the concept correctly.
- Common API usage.
- Simple examples.
- Basic mistakes.

### Level 2 — Senior
#### Expected depth of explanation
#### Signals that the reader has mastered this level
#### Typical mistakes at this level
#### Exercises and assessment prompts
- Ownership rules.
- Failure behavior.
- Performance implications.
- Testability.
- Production constraints.

### Level 3 — Lead
#### Expected depth of explanation
#### Signals that the reader has mastered this level
#### Typical mistakes at this level
#### Exercises and assessment prompts
- Migration strategy.
- Team boundaries.
- Review process.
- Delivery risks.
- Cross-feature consistency.

### Level 4 — Staff / Architect
#### Expected depth of explanation
#### Signals that the reader has mastered this level
#### Typical mistakes at this level
#### Exercises and assessment prompts
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


## Discrete Expansion Policy
Use this outline as a granular content backlog, not only as a table of contents. When expanding chapters, preserve every existing part, chapter, and section, then fill the most specific subsection that matches the material. Prefer adding a new lower-level subsection over mixing unrelated theory, runtime behavior, production rules, examples, exercises, and review questions in one block.

---

# Part I. The iOS Platform As An Engineering Environment

## 1. Apple ecosystem and platform constraints
### 1.1. iOS as a constrained runtime
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 1.2. Memory, battery, thermal, and network constraints
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 1.3. App sandbox and file-system boundaries
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 1.4. Privacy gates and permission model
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 1.5. Entitlements and system capabilities
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 1.6. Platform release cycle and WWDC-driven evolution
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add
### 1.7. Deployment target strategy
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add
### 1.8. Backward compatibility and deprecation handling
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 1.9. Hidden cost of supporting old iOS versions
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 1.10. Staff-level platform adoption strategy
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add

## 2. App lifecycle and process behavior
### 2.1. Cold launch
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 2.2. Warm launch
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 2.3. Foreground activation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 2.4. Background transition
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 2.5. Suspension and termination
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 2.6. Scene lifecycle
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 2.7. Multi-window behavior
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 2.8. State restoration
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 2.9. Launch-time dependency graph cost
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 2.10. Under the hood: dyld, Swift metadata loading, static initializers
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 2.11. Under the hood: main run loop and app startup path
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 2.12. Production launch-readiness checklist
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions

## 3. System integrations
### 3.1. Push notifications
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 3.2. Silent push limits
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 3.3. Deep links
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 3.4. Universal links
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 3.5. Widgets
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 3.6. App Intents
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 3.7. Live Activities
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 3.8. Background tasks
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 3.9. Share extensions
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 3.10. Siri / Shortcuts
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 3.11. App Groups
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 3.12. Staff-level integration governance
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add

---

# Part II. Swift Language Deep Dive

## 4. Swift fundamentals at Senior+ level
### 4.1. Value semantics
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 4.2. Reference semantics
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 4.3. Identity vs equality
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 4.4. Mutability control
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 4.5. Access control and API surface design
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 4.6. Error handling with `throws`
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 4.7. Optionals beyond basics
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 4.8. Pattern matching
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 4.9. Initialization rules
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 4.10. Deinitialization and lifetime
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 4.11. Language features that look simple but shape architecture
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 5. Swift memory model
### 5.1. Stack vs heap in practical Swift
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 5.2. Value witness tables
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 5.3. Copy / destroy / move operations
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 5.4. Copy-on-write internals
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 5.5. `isKnownUniquelyReferenced`
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 5.6. Hidden copies in hot paths
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 5.7. Large value pitfalls
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 5.8. Structs that should not be too large
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 5.9. ARC retain/release traffic
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add
### 5.10. Weak reference tables
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 5.11. `unowned` crash semantics
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add
### 5.12. Autorelease pools in mixed Swift/UIKit code
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 5.13. Memory ownership review checklist
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 6. Protocols, existentials, and generics
### 6.1. Protocols as behavior contracts
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 6.2. Protocols as architecture boundaries
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 6.3. Protocol overuse and decorative abstractions
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 6.4. Associated types
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 6.5. Existentials: `any Protocol`
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 6.6. Existential containers under the hood
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 6.7. Inline existential buffer
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 6.8. Witness tables
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 6.9. Opaque types: `some Protocol`
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 6.10. Generic constraints
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 6.11. Generic specialization
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 6.12. Conditional conformances
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 6.13. Type erasure
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 6.14. Phantom types
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 6.15. Compile-time vs runtime polymorphism
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 6.16. Staff-level API design with generics
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 7. Dispatch, metadata, and dynamic behavior
### 7.1. Static dispatch
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 7.2. Dynamic dispatch
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 7.3. Witness table dispatch
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 7.4. Objective-C message dispatch
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 7.5. `final` and devirtualization
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 7.6. `@objc`, `dynamic`, KVO, and bridging cost
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 7.7. Runtime metadata
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 7.8. Reflection limits
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 7.9. ABI stability
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 7.10. Module stability
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 7.11. Library evolution mode
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 8. Advanced Swift language tools
### 8.1. Property wrappers
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 8.2. Result builders
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 8.3. Macros
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 8.4. Key paths
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 8.5. Dynamic member lookup
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 8.6. Custom operators and why to avoid most of them
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 8.7. Codable internals and customization
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 8.8. Sendability annotations at language level
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 8.9. Debug vs Release language behavior
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 8.10. When language cleverness harms maintainability
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

---

# Part III. Swift Concurrency And Runtime Correctness

## 9. Async/await fundamentals
### 9.1. Structured concurrency
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 9.2. Parent-child task relationships
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 9.3. Task groups
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 9.4. Async let
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 9.5. Task priority
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 9.6. Priority inheritance
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 9.7. Suspension points
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 9.8. Why `await` does not mean background thread
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist

## 10. Task runtime under the hood
### 10.1. Task tree
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 10.2. Cooperative scheduling
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 10.3. Cancellation propagation
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 10.4. Task locals
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 10.5. Unstructured `Task {}`
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 10.6. `Task.detached`
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 10.7. Lifecycle-owned tasks
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 10.8. Fire-and-forget risks
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 10.9. Production task ownership checklist
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 11. Actors and executors
### 11.1. Actor isolation
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 11.2. Actor reentrancy
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 11.3. Actor invariants
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 11.4. Nonisolated APIs
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 11.5. MainActor
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 11.6. Actor hopping
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 11.7. Default executor
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 11.8. Custom executors conceptually
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 11.9. Actor vs lock
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 11.10. Actor anti-patterns
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 12. Sendable and Swift 6 readiness
### 12.1. `Sendable`
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 12.2. `@unchecked Sendable`
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 12.3. Data race prevention
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 12.4. Closure sendability
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 12.5. Shared mutable state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 12.6. Migration to strict concurrency
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 12.7. Compiler limitations
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 12.8. Staff-level concurrency migration plan
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist

## 13. Cancellation and stale response safety
### 13.1. Cancellation is not interruption
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 13.2. `Task.isCancelled`
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 13.3. `Task.checkCancellation()`
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 13.4. Cancellation-safe repositories
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 13.5. Network cancellation
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 13.6. UI cancellation
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 13.7. Stale response protection
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 13.8. Generation counters
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 13.9. Cancellation testing
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist

## 14. AsyncSequence and streams
### 14.1. AsyncSequence mental model
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 14.2. Buffering
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 14.3. Backpressure
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 14.4. Bridging delegate APIs
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 14.5. Notification streams
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 14.6. Stream cancellation
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 14.7. Memory leaks in streams
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 14.8. Testing streams
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add

---

# Part IV. SwiftUI, UIKit, And UI Runtime

## 15. SwiftUI mental model
### 15.1. Declarative rendering
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 15.2. View values vs render tree
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 15.3. Body invalidation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 15.4. Structural identity
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 15.5. Explicit identity
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 15.6. `.id()` pitfalls
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 15.7. Diffing mental model
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 15.8. Why view structs are cheap but body work is not
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 15.9. SwiftUI debugging mindset
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 16. SwiftUI state ownership
### 16.1. `@State`
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 16.2. `@Binding`
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 16.3. `@Observable`
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 16.4. `@Bindable`
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 16.5. `@Environment`
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 16.6. `@EnvironmentObject`
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 16.7. Legacy `ObservableObject`
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 16.8. State at wrong level
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 16.9. Source of truth vs derived state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 16.10. Broad invalidation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 16.11. Staff-level state ownership review
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 17. SwiftUI layout and rendering internals
### 17.1. Layout proposal / size / placement
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 17.2. Custom Layout
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 17.3. GeometryReader myths
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 17.4. Preference keys
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 17.5. ScrollView measurement traps
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 17.6. Transactions
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 17.7. Animation transactions
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 17.8. Environment propagation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 17.9. Core Animation bridge
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 17.10. Render server basics
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 18. SwiftUI performance
### 18.1. Formatting in `body`
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 18.2. Creating formatters repeatedly
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 18.3. Image decoding in rows
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 18.4. `AnyView` and type erasure cost
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 18.5. Overusing `.id()`
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 18.6. Large observable objects
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 18.7. Lazy containers
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 18.8. Navigation transition hitches
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 18.9. Row hot-path checklist
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 19. UIKit and legacy interoperability
### 19.1. View controller lifecycle
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 19.2. Responder chain
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 19.3. Hit testing
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 19.4. Gesture recognizers
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 19.5. Run loop modes
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 19.6. Layout pass
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 19.7. Display pass
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 19.8. Core Animation transactions
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 19.9. `UIHostingController`
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 19.10. `UIViewRepresentable`
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 19.11. Coordinator pattern in representables
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 19.12. Legacy migration from UIKit to SwiftUI
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

---

# Part V. Architecture Fundamentals

## 20. Architecture thinking
### 20.1. What architecture is and is not
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 20.2. Architecture decisions
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 20.3. Reversibility
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 20.4. Cost of change
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 20.5. Local optimum vs global optimum
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 20.6. Architecture as risk management
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 20.7. Architecture as communication
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises

## 21. Boundaries and coupling
### 21.1. UI boundary
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 21.2. Domain boundary
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 21.3. Data boundary
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 21.4. Infrastructure boundary
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 21.5. Feature boundary
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 21.6. Module boundary
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 21.7. Compile-time coupling
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 21.8. Runtime coupling
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 21.9. Data coupling
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 21.10. Temporal coupling
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 21.11. Semantic coupling
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 21.12. Organizational coupling
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 22. State and side-effect ownership
### 22.1. Source of truth
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 22.2. Derived state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 22.3. Render state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 22.4. Cache state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 22.5. Persistent state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 22.6. Server state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 22.7. Optimistic state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 22.8. UI side effects
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 22.9. Navigation side effects
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 22.10. Network side effects
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 22.11. Persistence side effects
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 22.12. Analytics/logging side effects
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add

## 23. Architecture decay and governance
### 23.1. Boundary decay
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 23.2. Shortcut normalization
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 23.3. Architecture fitness functions
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 23.4. Exception process
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 23.5. Migration path
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 23.6. Sunset rules
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 23.7. Governance without bureaucracy
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add

---

# Part VI. iOS Architecture Styles

## 24. MVVM with explicit intents
### 24.1. ViewModel responsibilities
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 24.2. Explicit intent API
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 24.3. ViewState builders
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 24.4. Async task lifecycle
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 24.5. User-safe error mapping
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 24.6. Navigation ownership
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 24.7. Testing ViewModels
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 24.8. Generic `send(_:)` anti-pattern
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 25. SwiftUI Native State / MV
### 25.1. When ViewModels are unnecessary
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 25.2. View-owned state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 25.3. Lifecycle models
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 25.4. Local state vs domain state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 25.5. When MV becomes renamed MVVM
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises

## 26. Coordinator / Flow
### 26.1. Coordinator responsibilities
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 26.2. Router vs Coordinator
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 26.3. Flow state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 26.4. Deep links
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 26.5. App/session lifecycle separation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 26.6. Coordinator side-effect anti-pattern
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises

## 27. Clean / Layered architecture
### 27.1. Presentation layer
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 27.2. Domain layer
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 27.3. Data layer
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 27.4. Infrastructure layer
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 27.5. Boundary contracts
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 27.6. Clean without use-case ceremony
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises

## 28. Modular / Feature-Sliced architecture
### 28.1. Feature slices
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 28.2. App shell
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 28.3. Shared/Core rules
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 28.4. Dependency direction
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 28.5. Cross-feature communication
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add
### 28.6. Module extraction strategy
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add
### 28.7. Build time implications
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 29. Hexagonal / Ports & Adapters
### 29.1. Ports
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 29.2. Driving adapters
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 29.3. Driven adapters
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 29.4. Domain purity
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 29.5. DTO/error mapping at boundaries
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 29.6. Avoiding protocol explosion
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 30. Redux / Elm / UDF
### 30.1. State
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 30.2. Actions
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 30.3. Mutations
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 30.4. Reducers
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 30.5. Effects
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 30.6. Store scope
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 30.7. Traceable feature state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add

## 31. TCA-style architecture
### 31.1. TCA mental model
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 31.2. Full state-machine state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 31.3. Reducer composition
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 31.4. Effects and cancellation
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 31.5. Dependencies
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 31.6. Navigation in TCA
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 31.7. Third-party TCA vs lightweight TCA style
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises

## 32. Reactor-style architecture
### 32.1. Reactor responsibilities
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 32.2. Action / Mutation / State
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 32.3. `mutate`
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 32.4. `reduce`
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 32.5. Rx vs async/await variants
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 32.6. SwiftUI integration
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 33. MVC migration architecture
### 33.1. Legacy MVC reality
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 33.2. Bounded controllers
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 33.3. Massive ViewController risks
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 33.4. Migration seams
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 33.5. When MVC is acceptable
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises

## 34. MVP Passive View
### 34.1. Passive view principle
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 34.2. Presenter ownership
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 34.3. SwiftUI passive view adaptation
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 34.4. Avoiding decorative view protocols
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 35. VIP / Clean Swift
### 35.1. View
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 35.2. Interactor
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 35.3. Presenter
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 35.4. Router
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 35.5. Worker
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 35.6. Request / Response / ViewModel roles
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 35.7. Scene builders
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 36. VIPER
### 36.1. View
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 36.2. Interactor
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 36.3. Presenter
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 36.4. Entity
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 36.5. Router
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 36.6. Builder
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 36.7. VIPER in SwiftUI
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 36.8. Presenter-heavy anti-pattern
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add

## 37. RIBs
### 37.1. Router
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 37.2. Interactor
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 37.3. Builder
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 37.4. Component
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 37.5. Attach/detach lifecycle
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 37.6. Dependency propagation
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 37.7. RIBs-inspired SwiftUI
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

---

# Part VII. Modularization, Packages, And Scaling

## 38. Codebase scaling
### 38.1. Monolith vs modular app
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 38.2. Package boundaries
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 38.3. Xcode project structure
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 38.4. Build-time management
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 38.5. Team ownership
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 38.6. Public API control
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 38.7. Internal platform modules
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add

## 39. Dependency management
### 39.1. SwiftPM
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 39.2. Binary dependencies
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 39.3. Third-party risk
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 39.4. Update policy
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 39.5. Security review
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 39.6. Dependency isolation
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises

## 40. Design systems
### 40.1. Tokens
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 40.2. Components
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 40.3. Theming
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 40.4. Accessibility by default
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 40.5. Localization support
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 40.6. Design system governance
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add

---

# Part VIII. Networking And API Contracts

## 41. Networking foundations
### 41.1. URLSession
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 41.2. Request modeling
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 41.3. Response validation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 41.4. Decoding
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 41.5. Cancellation
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 41.6. Timeouts
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 41.7. Retries
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 42. URLSession under the hood
### 42.1. DNS
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 42.2. TCP/TLS
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 42.3. HTTP/2 multiplexing
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 42.4. Connection reuse
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 42.5. URL cache
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 42.6. Default / ephemeral / background sessions
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 42.7. Timeout semantics
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 42.8. Expensive and constrained networks
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics

## 43. API contract design
### 43.1. DTOs
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 43.2. Domain mapping
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 43.3. Pagination
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 43.4. Sorting and filtering
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 43.5. Idempotency
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 43.6. Partial success
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 43.7. Versioning
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 43.8. Backward-compatible mobile APIs
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics

## 44. Auth and sessions
### 44.1. Login flows
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 44.2. Token storage
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 44.3. Refresh tokens
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 44.4. Expiration
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 44.5. Logout
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 44.6. Session restoration
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 44.7. Multi-account support
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 45. Network resilience
### 45.1. Offline behavior
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 45.2. Retryable vs non-retryable failures
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 45.3. Backoff and jitter
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 45.4. Circuit breakers
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 45.5. Herd effects
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 45.6. User feedback
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

---

# Part IX. Persistence, Local Data, And Sync

## 46. Persistence options
### 46.1. UserDefaults
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 46.2. Keychain
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 46.3. Files
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 46.4. SQLite
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 46.5. Core Data
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 46.6. SwiftData
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 46.7. App Groups
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 47. SwiftData / Core Data deep dive
### 47.1. Object graph
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 47.2. Identity
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 47.3. Faulting
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 47.4. Context ownership
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 47.5. Change tracking
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 47.6. Context concurrency
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 47.7. Merge policies
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 47.8. Migrations
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 47.9. Query performance
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 47.10. Indexing and fetch limits
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 48. Offline-first and sync
### 48.1. Local source of truth
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 48.2. Pending mutations
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 48.3. Idempotency keys
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 48.4. Conflict resolution
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 48.5. Tombstones
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 48.6. Local IDs vs server IDs
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 48.7. Last-write-wins risks
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 48.8. CRDT overview
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 48.9. Replay policy
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 48.10. Sync observability
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 49. Data safety
### 49.1. Secrets vs non-secrets
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 49.2. File protection
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 49.3. Destructive migrations
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 49.4. Backup behavior
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 49.5. Data deletion
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 49.6. GDPR/CCPA-style requirements
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add

---

# Part X. Security And Privacy

## 50. iOS security model
### 50.1. Sandbox
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 50.2. Keychain
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 50.3. Entitlements
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 50.4. App Groups
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 50.5. Secure Enclave
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 50.6. Biometrics
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add

## 51. Threat modeling for iOS
### 51.1. Casual attacker
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 51.2. Jailbroken device
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 51.3. Network attacker
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 51.4. Malicious dependency
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 51.5. Insider/log access
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 51.6. Server trust boundaries
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 52. Secure coding
### 52.1. Secret lifecycle
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 52.2. Token storage
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 52.3. Log redaction
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 52.4. TLS and ATS
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 52.5. Certificate pinning tradeoffs
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 52.6. Input validation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 52.7. Reverse engineering limits
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 53. Privacy engineering
### 53.1. Data minimization
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 53.2. Permission prompts
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 53.3. Privacy manifests
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 53.4. App Store privacy labels
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 53.5. Analytics privacy
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 53.6. Crash report privacy
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add

---

# Part XI. Performance And Profiling

## 54. Performance mindset
### 54.1. What users feel
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 54.2. Frame budgets
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 54.3. Main-thread budget
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 54.4. Measurement vs statically obvious fixes
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 54.5. Regression prevention
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 55. Launch performance
### 55.1. Cold launch
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 55.2. Main-thread startup work
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 55.3. Dependency graph startup
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 55.4. Lazy loading
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 55.5. Launch metrics
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 55.6. dyld and library loading
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 56. CPU profiling
### 56.1. Time Profiler
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 56.2. Self weight vs total weight
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 56.3. Stack interpretation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 56.4. Symbolication
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 56.5. Algorithmic complexity in UI
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 56.6. Sorting/filtering in hot paths
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 57. Memory performance
### 57.1. Heap growth
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 57.2. Retain cycles
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 57.3. Cache design
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 57.4. Image memory
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 57.5. Data blobs
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 57.6. Memory pressure
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 57.7. Jetsam
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 58. Image pipeline performance
### 58.1. Compressed vs decoded image
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 58.2. Downsampling
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 58.3. Decompression
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 58.4. Cache cost
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 58.5. Scroll cancellation
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 58.6. Memory pressure handling
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions

## 59. Rendering and scrolling performance
### 59.1. Core Animation layer tree
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 59.2. Render server
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 59.3. Offscreen rendering
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 59.4. Blending
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 59.5. Shadows and masks
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 59.6. Scroll hitches
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 59.7. Pagination backpressure
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics

## 60. Profiling tools
### 60.1. Instruments overview
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 60.2. Time Profiler
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 60.3. Allocations
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 60.4. Leaks
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 60.5. Hangs
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 60.6. Network instruments
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 60.7. Points of Interest
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 60.8. MetricKit
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

---

# Part XII. Accessibility, Localization, And Inclusive UX

## 61. Accessibility
### 61.1. VoiceOver
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 61.2. Labels, hints, traits
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 61.3. Dynamic Type
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 61.4. Focus order
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 61.5. Tap targets
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 61.6. Reduce Motion
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 61.7. Contrast
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 61.8. Accessibility testing
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 61.9. Accessibility as architecture constraint
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add

## 62. Localization
### 62.1. `.xcstrings`
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 62.2. Plurals
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 62.3. Dates and numbers
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 62.4. RTL
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 62.5. String interpolation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 62.6. Pseudolocalization
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 62.7. Localization QA
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 62.8. Localization performance pitfalls
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions

---

# Part XIII. Testing And Quality Strategy

## 63. Testing pyramid for iOS
### 63.1. Unit tests
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 63.2. Integration-style tests
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 63.3. Snapshot tests
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 63.4. UI tests
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 63.5. Manual QA
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 63.6. Exploratory testing
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add

## 64. XCTest and Swift Testing
### 64.1. XCTest basics
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 64.2. Swift Testing basics
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 64.3. Async tests
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 64.4. Test traits/tags
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 64.5. Test data builders
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 64.6. Determinism
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 64.7. Flakiness diagnosis
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 65. Architecture testing
### 65.1. ViewModel tests
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 65.2. Store/reducer tests
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 65.3. Interactor tests
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 65.4. Presenter tests
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 65.5. Coordinator/router tests
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 65.6. Repository tests
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 65.7. Persistence tests
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 65.8. Boundary contract tests
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises

## 66. UI and accessibility testing
### 66.1. XCUITest
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 66.2. Accessibility identifiers
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 66.3. Smoke tests
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 66.4. UI test architecture
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 66.5. Simulator matrix
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 66.6. Result bundles
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

---

# Part XIV. CI/CD And Release Engineering

## 67. Build system
### 67.1. Xcode build pipeline
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 67.2. Schemes
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 67.3. Configurations
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 67.4. DerivedData
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 67.5. Module cache
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 67.6. Incremental compilation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 67.7. Build log analysis
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 68. Swift compiler and binary behavior
### 68.1. Type-checker performance
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 68.2. Result-builder compile-time explosions
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 68.3. Generic constraints and compile time
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 68.4. Dead stripping
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 68.5. Symbol visibility
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 68.6. Binary size
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 68.7. Debug vs Release performance
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions

## 69. CI pipelines
### 69.1. GitHub Actions / Bitrise / Xcode Cloud
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 69.2. Static gates
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 69.3. Unit test lanes
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 69.4. UI test lanes
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 69.5. Artifacts
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 69.6. Failure triage
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 69.7. Cache strategy
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics

## 70. Signing and provisioning
### 70.1. Certificates
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 70.2. Provisioning profiles
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 70.3. Entitlements
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 70.4. App groups
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 70.5. CI signing
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 70.6. Signing incident response
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add

## 71. App Store release
### 71.1. Archives
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 71.2. TestFlight
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 71.3. Phased rollout
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add
### 71.4. App Review
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 71.5. Rollback strategy
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add
### 71.6. Release notes
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add
### 71.7. Production readiness checklist
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

---

# Part XV. Observability And Operations

## 72. Logging
### 72.1. OSLog
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 72.2. Redaction
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 72.3. Log levels
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 72.4. Structured logs
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 72.5. Correlation IDs
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 72.6. Supportability
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 73. Analytics
### 73.1. Event taxonomy
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 73.2. Privacy-safe analytics
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 73.3. Product metrics
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add
### 73.4. Funnel analysis
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 73.5. Experimentation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 74. Crash reporting
### 74.1. Crash symbolication
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add
### 74.2. dSYM upload
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 74.3. Crash triage
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add
### 74.4. Non-fatal errors
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 74.5. Regression detection
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 75. Runtime monitoring and incidents
### 75.1. MetricKit
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 75.2. Performance dashboards
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 75.3. Network metrics
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 75.4. Mobile incident constraints
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 75.5. Kill switches
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 75.6. Postmortems
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

---

# Part XVI. Engineering Leadership

## 76. Senior engineer execution
### 76.1. Ownership
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 76.2. Risk identification
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 76.3. Technical planning
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 76.4. Communication
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add
### 76.5. Estimation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 76.6. Scope control
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 77. Tech Lead skills
### 77.1. Breaking down work
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 77.2. Delegation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 77.3. Review quality
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 77.4. Mentorship
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 77.5. Cross-functional work
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 77.6. Delivery without heroics
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 78. Staff engineer skills
### 78.1. Influence without authority
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 78.2. Technical strategy
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add
### 78.3. Engineering leverage
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 78.4. Standards and governance
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add
### 78.5. RFCs and ADRs
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add
### 78.6. Long-term maintainability
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 78.7. When to say no
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 79. Technical debt and strategy
### 79.1. Deliberate debt
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 79.2. Accidental debt
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 79.3. Bit rot
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 79.4. Architecture erosion
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 79.5. Knowledge debt
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 79.6. Debt repayment strategy
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add

---

# Part XVII. Code Review, Documentation, And Knowledge Sharing

## 80. Code review
### 80.1. Correctness
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 80.2. Architecture
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 80.3. Security
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 80.4. Performance
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 80.5. Accessibility
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 80.6. Testing
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 80.7. Review comments style
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add

## 81. Code documentation
### 81.1. What to document
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 81.2. What not to document
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 81.3. Ownership comments
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 81.4. Side-effect comments
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 81.5. API contracts
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 81.6. Temporary workaround comments
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 81.7. Documentation decay
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 82. Project documentation
### 82.1. README
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 82.2. Architecture docs
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 82.3. Testing instructions
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 82.4. Release docs
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add
### 82.5. Runbooks
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 82.6. Onboarding docs
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

---

# Part XVIII. Product Engineering And Requirements

## 83. Product requirements
### 83.1. Acceptance criteria
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 83.2. Non-goals
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 83.3. Edge cases
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 83.4. Ambiguity resolution
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 83.5. Product tradeoffs
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 84. Feature planning
### 84.1. Scope slicing
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 84.2. Vertical slices
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 84.3. Technical milestones
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 84.4. Rollout flags
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add
### 84.5. Telemetry plan
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 85. Experimentation
### 85.1. Feature flags
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 85.2. A/B tests
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 85.3. Remote config
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 85.4. Kill switches
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 85.5. Ethical experimentation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

---

# Part XIX. Debugging Mastery

## 86. Debugging mental models
### 86.1. Reproduction
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 86.2. Minimal repro
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 86.3. Determinism
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 86.4. State capture
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 86.5. Timeline reconstruction
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 87. LLDB
### 87.1. Breakpoints
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 87.2. Conditional breakpoints
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 87.3. Watchpoints
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 87.4. Expression evaluation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 87.5. Thread inspection
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 87.6. Swift concurrency debugging
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

## 88. Log-driven debugging
### 88.1. Correlation IDs
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 88.2. Redacted context
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 88.3. Breadcrumbs
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 88.4. Support logs
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 88.5. Debugging without user data leakage
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

---

# Part XX. Practical Case Studies

## 89. News/feed app case study
### 89.1. Requirements
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 89.2. MVVM implementation
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 89.3. UDF implementation
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 89.4. Clean implementation
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 89.5. VIPER implementation
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 89.6. Tradeoff comparison
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 90. Auth/session case study
### 90.1. Login
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 90.2. Token storage
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 90.3. Refresh
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 90.4. Logout
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 90.5. Session restoration
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 90.6. Security review
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add

## 91. Offline sync case study
### 91.1. Local-first state
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 91.2. Pending mutations
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 91.3. Conflict resolution
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 91.4. Retry/backoff
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 91.5. UI feedback
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 92. Large app modularization case study
### 92.1. Starting monolith
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 92.2. Boundary discovery
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 92.3. Package extraction
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 92.4. Build performance
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 92.5. Team ownership
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add

---

# Part XXI. Interview And Calibration Materials

## 93. Senior iOS interview topics
### 93.1. Swift
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 93.2. Concurrency
#### Execution model and isolation boundary
#### Task lifecycle and cancellation semantics
#### Actor, Sendable, and data-race constraints
#### Priority, executor, and main-thread implications
#### Debugging and instrumentation workflow
#### Migration and code-review checklist
### 93.3. SwiftUI
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 93.4. Architecture
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 93.5. Networking
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 93.6. Persistence
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 93.7. Testing
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 93.8. Performance
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions

## 94. Lead / Staff interview topics
### 94.1. System design
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 94.2. Architecture review
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 94.3. Technical strategy
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add
### 94.4. Incident handling
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 94.5. Mentorship
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 94.6. Cross-team influence
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add

## 95. Question bank
### 95.1. Theory questions
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 95.2. Practical coding questions
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 95.3. Debugging scenarios
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 95.4. Architecture scenarios
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 95.5. Behavioral questions
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

## 96. Answer rubrics
### 96.1. Junior answer
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 96.2. Middle answer
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 96.3. Senior answer
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 96.4. Staff answer
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add
### 96.5. Red flags
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts

---

# Part XXII. Appendices

## 97. Checklists
### 97.1. Feature readiness checklist
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 97.2. PR checklist
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 97.3. Release checklist
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add
### 97.4. Architecture review checklist
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add
### 97.5. Security checklist
#### Threat model and protected assets
#### Platform mechanism and entitlement surface
#### Data lifecycle, retention, and deletion behavior
#### Logging, analytics, and crash-reporting constraints
#### Review checklist and incident response
#### Examples and adversarial questions to add
### 97.6. Performance checklist
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 97.7. Accessibility checklist
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add

## 98. Templates
### 98.1. ADR template
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add
### 98.2. RFC template
#### Scope and prerequisites
#### Core theory and mental model
#### Under-the-hood details
#### Production rules and pitfalls
#### Examples, exercises, and Q&A prompts
### 98.3. Incident report template
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 98.4. Release plan template
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add
### 98.5. Test plan template
#### Scope and test target boundary
#### Deterministic setup and fixture strategy
#### Failure modes, flakiness, and timing risks
#### Coverage expectations and missing-case checklist
#### CI, artifacts, and triage workflow
#### Example tests and exercises to add
### 98.6. Architecture review template
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add

## 99. Glossary
### 99.1. Swift terms
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 99.2. iOS platform terms
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add
### 99.3. Architecture terms
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 99.4. Networking terms
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 99.5. Release terms
#### Operational goal and ownership
#### Build, signing, and environment constraints
#### Telemetry, logging, and alerting signals
#### Rollout, rollback, and incident workflow
#### Compliance and support handoff checklist
#### Runbook examples to add

## 100. Exercises
### 100.1. Refactor a ViewModel
#### Definition and mental model
#### Syntax and API surface
#### Compiler and runtime mechanics
#### Edge cases and non-obvious behavior
#### Production pitfalls and review questions
#### Examples and exercises to add
### 100.2. Design offline sync
#### Contract and data ownership
#### Request/response and mapping rules
#### Failure, retry, cancellation, and idempotency behavior
#### Offline, cache, and persistence implications
#### Security, privacy, and logging constraints
#### Test matrix and production diagnostics
### 100.3. Profile a scrolling list
#### Performance budget and measurement target
#### Instrumentation setup and trace interpretation
#### Hot-path risks and static red flags
#### Optimization tradeoffs and regression guardrails
#### Before/after validation examples
#### Interview and incident-review questions
### 100.4. Build a modular feature
#### Role responsibilities
#### Dependency direction and ownership boundaries
#### State, side effects, and navigation placement
#### Tradeoffs, failure modes, and migration cost
#### Review checklist and anti-patterns
#### Reference implementation exercises
### 100.5. Write an ADR
#### Decision context and stakeholders
#### Technical tradeoff and organizational impact
#### Governance artifact or process to produce
#### Escalation, alignment, and communication risks
#### Review questions and calibration rubric
#### Case studies and exercises to add
### 100.6. Review a production incident
#### Rendering and lifecycle model
#### State ownership boundary
#### Layout, invalidation, and performance risks
#### Accessibility and localization considerations
#### Failure cases and debugging workflow
#### Examples, previews, and exercises to add

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
