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
#### Content plan for this topic
This topic establishes the platform mental model that should influence every later chapter. It is not a generic introduction to iOS. It is the baseline for senior-level engineering judgment: an iOS app runs in an environment where the system, not the app, owns final authority over memory, scheduling, background time, energy, thermal pressure, privacy boundaries, process lifetime, and user attention.

Cover this topic in the following order:
1. define what "constrained runtime" means on iOS;
2. map the constraints to concrete engineering decisions;
3. explain the lifecycle and process model that makes those constraints real;
4. describe under-the-hood memory, scheduling, energy, and termination behavior;
5. turn the model into production rules, examples, and review questions.

#### Definition and mental model
An iOS application is a **guest process** in a user-first, battery-powered, privacy-controlled operating system. The app can request resources; the system decides whether and when those resources remain available. The correct mental model is not "my app runs until it exits". The correct model is: **the system continuously arbitrates foreground priority, background eligibility, memory pressure, CPU scheduling, I/O, network access, thermal pressure, and privacy permission surfaces across all apps and system services**.

The practical consequence is simple: production iOS code must be designed as if interruption is normal. A senior iOS engineer assumes that:
- launch can happen cold, warm, after jetsam, after a crash, after an update, after permission changes, or after restored scene state;
- foreground execution is privileged and user-visible, but still constrained by frame deadlines, memory, energy, and thermal pressure;
- background execution is exceptional, limited, and policy-driven;
- suspension can happen when the user leaves the app and the app has no approved reason to continue running;
- termination may happen without a final callback;
- memory warnings and diagnostics are signals to reduce footprint, not optional notifications;
- CPU, disk, network, location, Bluetooth, camera, audio, and GPU work all have energy and thermal cost;
- privacy prompts, entitlements, background modes, and sandboxing are part of runtime design, not release paperwork.

A useful senior-level shorthand is: **iOS rewards apps that are interruptible, resumable, lazy, incremental, cancellable, observable, and honest about background work**. It penalizes apps that assume continuous execution, own global mutable state casually, block launch, decode large assets eagerly, write repeatedly to disk, poll in the background, keep sensors active without clear value, or hide side effects behind innocent-looking UI code.

#### Constraint categories
The runtime constraints are easier to reason about when grouped by the owner of the decision.

| Constraint | System owner | What the app controls | Common senior failure |
| --- | --- | --- | --- |
| Process lifetime | iOS scheduler and memory manager | state restoration, persistence, cancellation, idempotency | assuming `applicationWillTerminate` or `scenePhase` transitions will always arrive before death |
| Foreground responsiveness | main run loop, display pipeline, UIKit/SwiftUI rendering | main-thread work, view invalidation, task priorities, layout complexity | treating "works on simulator" as proof that UI work is cheap |
| Memory footprint | kernel, jetsam, memory compressor | allocations, image decoding, caches, data lifetimes, object graphs | measuring object count instead of dirty/resident memory and decoded buffers |
| Background time | UIKit lifecycle, BackgroundTasks, declared modes | background eligibility, task expiration handling, batching, persistence checkpoints | building product behavior around unreliable or user-hostile background assumptions |
| Energy and thermal behavior | power management, thermal management | CPU/GPU/network/I/O/sensor intensity, QoS, batching, Low Power Mode adaptation | optimizing latency by increasing wakeups, polling, and write frequency |
| Privacy and sandboxing | TCC, entitlements, App Sandbox, App Review policy | permission timing, data minimization, local storage, logging, explainability | treating permission grants as permanent or treating logs as harmless |
| Distribution/runtime policy | App Store, provisioning, OS version, device class | feature gating, availability checks, rollout, observability | testing only one device/iOS version and assuming platform behavior is uniform |

#### Lifecycle states and process states
Do not collapse app lifecycle, scene lifecycle, and process lifetime into one concept.

At a high level:
- **Process lifetime** answers whether the app process exists in memory.
- **Application lifecycle** answers whether the app is launching, active, inactive, backgrounded, suspended, or terminated.
- **Scene lifecycle** answers whether a particular UI scene is connected, foreground, background, or discarded.
- **Task lifecycle** answers whether async work is active, suspended, cancelled, expired, or orphaned.
- **Data lifecycle** answers whether user-visible state is durable enough to survive process loss.

Senior-level mistake: storing critical product state only in memory because a SwiftUI `@State`, `@Observable`, singleton, actor, cache, coordinator, or store "currently has it". In-memory state is a rendering and coordination convenience; it is not durability. If the user would reasonably expect the state to survive relaunch, interruptions, or background eviction, it needs an explicit persistence or restoration policy.

Practical lifecycle rules:
- Treat foreground activation as an opportunity to reconcile state, not as proof that previous in-memory work completed.
- Treat background transition as a checkpoint opportunity, not as a long-running work window.
- Treat suspension as invisible: no code runs while suspended.
- Treat termination as non-cooperative: final cleanup callbacks are not a durable persistence mechanism.
- Treat scene disconnection as normal on iPadOS and multi-window-capable apps.
- Treat force quit as a user intent signal that can affect background behavior.
- Treat background task expiration handlers as mandatory correctness paths, not best-effort logging hooks.

#### Foreground execution constraints
Foreground apps get the most opportunity to run, but they are still constrained by user perception and rendering deadlines. A 60 Hz display gives roughly 16.67 ms per frame; 120 Hz devices cut that to roughly 8.33 ms. SwiftUI diffing, layout, image decoding, JSON mapping, persistence fetches, logging, analytics, and network callbacks can all compete with rendering if they land on the main actor at the wrong time.

Important distinction:
- **MainActor correctness** prevents UI data races.
- **MainActor performance** requires keeping expensive work off the main actor.

Correct code can still be a bad app if it monopolizes the main actor. Senior review should ask:
- Does this view compute derived collections during `body` evaluation?
- Does this screen decode images, parse JSON, format many dates, or perform persistence fetches on the main actor?
- Does this observation boundary invalidate a large view tree for a small state change?
- Does this async task resume on the main actor with too much post-processing work?
- Does the UI show partial progress and cancellation, or does it block on an all-or-nothing operation?

SwiftUI-specific implication: a view body is a description, not a work queue. Any operation that would be suspicious inside `tableView(_:cellForRowAt:)` is also suspicious inside SwiftUI `body`, computed view properties, formatters allocated per row, or broad observable state that causes full-list invalidation.

#### Background execution constraints
Background execution on iOS is permissioned and purpose-based. The system may move an app to the background when the user leaves it and may later suspend it unless the app is finishing a limited task or using an allowed background capability. The BackgroundTasks framework can schedule refresh or processing work, but it does not grant arbitrary daemon-like execution. Timing is system-controlled, affected by power, usage patterns, device conditions, user settings, and policy.

Design implications:
- Background refresh is suitable for opportunistic freshness, not contractual deadlines.
- Long-running background work must have a declared platform reason and an expiration path.
- Background tasks must be idempotent because they can be retried, skipped, interrupted, or run after partial previous work.
- Any background task that mutates local state should checkpoint progress in small, recoverable units.
- UI should communicate freshness and last-success state instead of pretending background refresh always happened.
- Network sync should be conflict-aware; "last write wins" is often a data-loss bug disguised as simplicity.

Bad product requirement: "sync every 5 minutes in the background". Good requirement: "when the system grants background time, attempt an idempotent sync; preserve local mutations durably; surface stale state; retry with backoff; never block foreground usage on background success".

#### Memory model at app level
At the app level, memory is not just "how many objects exist". iOS memory pressure is influenced by resident pages, dirty pages, compressed memory, decoded image buffers, mapped files, frameworks, caches, autorelease pools, and retained object graphs. Apple’s memory material distinguishes clean memory that the system can discard or reload from dirty memory that was written by the process and is more expensive to reclaim. WWDC memory guidance also highlights that images often have a much larger decoded footprint than their compressed file size.

Senior-level memory rules:
- Measure memory footprint with Instruments/Xcode tools, not intuition.
- Treat decoded images, video frames, large JSON payloads, ML models, PDF pages, and attributed text layouts as first-class memory risks.
- Use downsampling before creating UI images when the display size is much smaller than the source asset.
- Prefer bounded caches with eviction and memory-pressure handling over global dictionaries.
- Avoid retaining whole DTO payloads if the screen only needs mapped domain/view state.
- Avoid retaining task closures that capture view models, controllers, coordinators, or large graphs longer than intended.
- Be suspicious of "temporary" arrays in hot paths; temporary peak memory can trigger jetsam even if steady-state memory looks acceptable.

A senior engineer distinguishes:
- **leak**: memory that should be released but remains strongly referenced;
- **growth**: memory increases because product state grows without bounds;
- **peak**: temporary memory spike during decoding/parsing/rendering;
- **fragmentation/allocator overhead**: memory shape is inefficient even if object lifetimes are correct;
- **cache pressure**: memory is intentionally retained but not bounded by user value;
- **dirty memory inflation**: pages become expensive because app code writes to them unnecessarily.

#### CPU, QoS, scheduling, and energy
CPU work is not free even when it is off the main actor. CPU time consumes battery and can increase thermal pressure. QoS is a scheduling hint, not a magic performance switch. Overusing high-priority queues can starve lower-priority work, increase contention, and waste energy. Underusing priority can delay user-visible work. The senior-level decision is to align QoS with user value.

Practical mapping:
- user input and immediate visual response: high priority, short work, cancellable;
- screen data preparation: user-initiated or utility depending on visibility and latency expectations;
- prefetching: utility, cancellable, bounded;
- analytics upload: utility/background, batched;
- cleanup, indexing, compaction: background, deferrable, expiration-aware;
- speculative work: only if measured value exceeds battery, memory, and complexity cost.

Energy cost often comes from **wakeups and repeated small work**, not only from one expensive algorithm. Timers, polling loops, frequent disk writes, chatty networking, small location updates, repeated Bluetooth scans, and excessive logging can prevent the system from staying idle. Apple’s energy guidance emphasizes reducing and prioritizing work, minimizing background activity, batching I/O, and deferring networking when possible.

#### Thermal constraints
Thermal pressure is a runtime input. `ProcessInfo.thermalState` exposes states such as nominal, fair, serious, and critical. At elevated thermal states, the app should reduce resource usage: pause nonessential prefetching, lower rendering intensity, reduce camera/video processing quality where product-acceptable, stop speculative indexing, decrease polling, and avoid starting heavy background processing.

Senior-level thermal design is not "show an alert when hot". It is adaptive work shedding:
- define which work is essential for correctness;
- define which work is user-visible but degradable;
- define which work is speculative and should stop first;
- make work cancellable so thermal adaptation can take effect quickly;
- record telemetry that correlates thermal state with hangs, dropped frames, battery, and session abandonment.

#### I/O and file-system constraints
Disk I/O can hurt latency, energy, and data integrity. Small repeated writes are especially costly because they wake storage and can interact badly with app lifecycle transitions. File writes should be batched where safe, atomic where correctness matters, and moved off the main actor. Structured mutable data that grows beyond trivial size usually belongs in SQLite/Core Data/SwiftData or another database layer rather than repeated whole-file rewrites.

Rules:
- Never do avoidable file I/O on the main actor during launch or scrolling.
- Use atomic writes for user-critical documents/configuration where partial writes would corrupt state.
- Persist checkpoints before relying on background work continuation.
- Avoid writing analytics/log files at high frequency; batch and bound them.
- Do not invent a cache that fights the OS file cache unless the product has a measured reuse pattern.
- Keep app group/shared container writes coordinated when extensions/widgets are involved.

#### Network constraints
Network access is variable, energy-expensive, privacy-sensitive, and often unavailable at the moment product code wants it. Mobile networking has radio wakeup costs, captive portals, Low Data Mode, constrained networks, metered plans, packet loss, server throttling, authentication expiry, and app suspension boundaries.

Senior network behavior:
- model request cancellation explicitly when screens disappear or tasks become obsolete;
- make mutations idempotent with client-generated keys where duplicate delivery is possible;
- avoid tying UI correctness to immediate server acknowledgement when offline support or optimistic UI is required;
- separate transport errors, decoding errors, domain conflicts, auth failures, and user-safe display messages;
- retry only when retrying is safe and useful; never blindly retry non-idempotent mutations;
- batch low-priority network work and respect system/user constraints;
- preserve local user intent before attempting background sync.

#### Privacy, permission, and sandbox constraints
The iOS sandbox is a product feature, not an obstacle. Permissions are user-mediated access grants to sensitive capabilities. A production app must assume permissions can be denied, revoked, restricted, unavailable on some devices, or changed while the app is not running.

Senior-level rules:
- Ask for permission at the point of user-understandable value, not at cold launch by habit.
- Design denied/restricted states as first-class UI states.
- Do not log raw PII, tokens, precise location, contacts, health data, clipboard contents, or sensitive file names.
- Store secrets in Keychain with an explicit accessibility class; do not put token-like values in plain user defaults, logs, crash metadata, or analytics properties.
- Treat pasteboard, URL schemes, universal links, document imports, push payloads, and app groups as external input boundaries.
- Minimize data retention because data that is never stored cannot leak, go stale, or require migration.

#### Runtime interruptions and failure modes
A constrained runtime produces failure modes that do not appear in happy-path simulator testing:
- app killed between writing local state and acknowledging remote sync;
- background task expires while a database transaction is open;
- scene disconnected while a navigation transition is pending;
- async task resumes after the view disappeared;
- memory pressure kills the app during image-heavy scrolling;
- network retry duplicates a mutation;
- permission is revoked after onboarding;
- thermal pressure slows processing enough to expose timing assumptions;
- Low Power Mode makes polling or prefetching unacceptable;
- process restarts with stale in-memory cache assumptions;
- crash report shows memory termination rather than Swift exception.

A senior engineer designs state machines around these failures. A junior implementation often adds `if isLoading { return }` and assumes the problem is solved. The senior version defines ownership, cancellation, durability, idempotency, and recovery.

#### Under-the-hood details that change engineering decisions
Important internal mechanics that should influence design:
- **Run loop and main actor are bottlenecks**: UI event handling, layout, drawing coordination, and many framework callbacks converge on the main thread/main actor. Moving work off-main is necessary but not sufficient; post-processing on return can still hitch.
- **Suspension freezes execution**: timers do not keep running just because a Swift object exists. Any design depending on in-process timers during suspension is wrong unless backed by an approved background mechanism.
- **Jetsam is not a Swift crash**: memory termination may not produce a normal exception path. Investigate memory reports, organizer metrics, and device logs rather than only crash stack traces.
- **Decoded media dominates memory**: a compressed image file can expand into a large pixel buffer. Display size, scale, color format, and intermediate processing buffers matter.
- **Clean vs dirty memory matters**: memory-mapped read-only resources are easier for the system to reclaim than app-written heap pages. Runtime modification of framework data, unnecessary mutation, and large writable buffers increase pressure.
- **QoS propagates imperfectly through abstraction layers**: async/await, operation queues, dispatch queues, URLSession callbacks, actors, and third-party SDKs can obscure priority. Review the end-to-end path.
- **Background execution is expiration-driven**: every meaningful background operation needs a plan for the expiration handler and partial progress.
- **OS policy evolves**: behavior can change across iOS versions. Production code should rely on documented guarantees and observable fallback behavior, not folklore from one release.

#### Senior/staff design heuristics
Use these heuristics when reviewing features:
1. **Can the app be killed at every `await`?** If not literally, assume the user-visible operation can be interrupted between steps and design persistence/recovery around that.
2. **What is the smallest durable fact?** Persist user intent and irreversible decisions before large derived state.
3. **What is the bounded resource?** For every feature, identify whether the real limit is memory, CPU, network, disk, battery, privacy, user attention, server quota, or team comprehension.
4. **What work can be cancelled?** Work that is no longer user-visible should usually be cancellable unless it is preserving data integrity.
5. **What work can be deferred?** Anything not needed for the next user-visible state should be lazy, incremental, or scheduled.
6. **What is the degraded behavior?** Define behavior under offline, denied permission, Low Power Mode, thermal pressure, memory pressure, and stale server state.
7. **What proves this works in production?** Decide which metrics, logs, diagnostics, and support signals demonstrate health after release.

#### Production checklist
A feature is not production-ready in a constrained runtime unless these questions have defensible answers:
- What survives process death?
- What happens if the app is suspended mid-operation?
- What is cancelled when the screen disappears?
- What is persisted before network acknowledgement?
- What is retried, with what idempotency key, and what backoff?
- What is the maximum memory footprint for the largest realistic input?
- What is the main-actor work during launch, navigation, and scrolling?
- What happens in Low Power Mode or serious/critical thermal state?
- What happens when permissions are denied, revoked, or restricted?
- What happens when disk is full or file protection delays access?
- What is logged, and can any log line leak sensitive data?
- How will hangs, launch regressions, memory terminations, disk writes, and high energy usage be detected after release?

#### Practical Swift examples
Example: make screen-owned work cancellable and avoid assuming the task outlives the view.

```swift
@MainActor
@Observable
final class ArticleListModel {
    private let repository: ArticleRepository
    private var loadTask: Task<Void, Never>?

    private(set) var articles: [ArticleSummary] = []
    private(set) var isLoading = false
    private(set) var userMessage: String?

    init(repository: ArticleRepository) {
        self.repository = repository
    }

    func appeared() {
        loadTask?.cancel()
        loadTask = Task { [repository] in
            isLoading = true
            defer { isLoading = false }

            do {
                // Fetching is off-main inside the repository; only final UI state is assigned here.
                let loadedArticles = try await repository.fetchVisibleArticles()
                try Task.checkCancellation()
                articles = loadedArticles
            } catch is CancellationError {
                // Cancellation is expected when the view disappears or a newer load replaces this one.
            } catch {
                userMessage = "Unable to load articles. Check your connection and try again."
            }
        }
    }

    func disappeared() {
        loadTask?.cancel()
        loadTask = nil
    }
}
```

Example: persist user intent before attempting a network mutation.

```swift
struct FavoriteMutation: Codable, Equatable {
    let idempotencyKey: UUID
    let articleID: Article.ID
    let isFavorite: Bool
    let createdAt: Date
}

actor FavoriteMutationQueue {
    private var pending: [FavoriteMutation] = []

    func enqueueFavoriteChange(articleID: Article.ID, isFavorite: Bool) async throws {
        let mutation = FavoriteMutation(
            idempotencyKey: UUID(),
            articleID: articleID,
            isFavorite: isFavorite,
            createdAt: Date()
        )

        // In production this write must be durable before the UI/server path depends on it.
        pending.removeAll { $0.articleID == articleID }
        pending.append(mutation)
        try await persistPendingMutations(pending)
    }

    private func persistPendingMutations(_ mutations: [FavoriteMutation]) async throws {
        // Use SwiftData/Core Data/SQLite/file storage appropriate to the product.
        // The important rule is durability before best-effort server delivery.
    }
}
```

Example: adapt optional work to thermal state.

```swift
import Foundation

struct OptionalWorkPolicy {
    func allowsImagePrefetch(thermalState: ProcessInfo.ThermalState, isLowPowerModeEnabled: Bool) -> Bool {
        guard !isLowPowerModeEnabled else { return false }

        switch thermalState {
        case .nominal, .fair:
            return true
        case .serious, .critical:
            return false
        @unknown default:
            return false
        }
    }
}
```

Example: avoid repeated expensive work in a SwiftUI hot path.

```swift
struct ArticleRowViewState: Equatable, Identifiable {
    let id: Article.ID
    let title: String
    let subtitle: String
    let formattedDate: String
}

struct ArticleRowView: View {
    let state: ArticleRowViewState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(state.title)
                .font(.headline)
            Text(state.subtitle)
                .font(.subheadline)
            Text(state.formattedDate)
                .font(.caption)
        }
    }
}
```

The senior point is not the small struct itself. The point is that date formatting, localization decisions, and DTO mapping should be done once at the state-building boundary, not repeatedly during body evaluation for every invalidation.

#### Debugging and verification workflow
Use a layered workflow:
1. **Static review**: identify main-actor heavy work, unbounded caches, eager decoding, polling, missing cancellation, non-idempotent retries, and persistence gaps.
2. **Local measurement**: use Instruments/Xcode memory, time profiler, hangs, energy, and network tools on real devices where possible.
3. **Lifecycle testing**: test cold launch, background/foreground transitions, task cancellation, permission changes, offline mode, Low Power Mode, and relaunch after termination.
4. **Stress inputs**: use large images, long lists, slow network, server errors, disk pressure, denied permissions, and interrupted sync.
5. **Release telemetry**: use MetricKit/Xcode Organizer/App Store diagnostics for launch time, hangs, memory, disk writes, energy, and crashes.
6. **Regression gates**: add unit or performance tests for deterministic hot paths; keep real-device profiling for behavior that cannot be proven in unit tests.

#### Common anti-patterns
- Treating the simulator as representative for memory, thermal, radio, camera, and background behavior.
- Starting network requests in view bodies or broad lifecycle hooks without cancellation ownership.
- Using global singletons as hidden durability or hidden lifecycle owners.
- Updating UI only after full success when partial progress would preserve user trust.
- Assuming background refresh is a scheduler with deadlines.
- Retrying every error with the same policy.
- Decoding full-size images for thumbnail UI.
- Writing a full JSON file on every small state change.
- Logging raw request/response bodies in production diagnostics.
- Ignoring Low Power Mode because "the feature is important".
- Adding a cache without a cost limit, eviction policy, or memory-pressure response.
- Confusing `@MainActor` safety with performance safety.
- Building architecture diagrams that omit cancellation, persistence, and background expiration paths.

#### Senior interview and review questions
Use these questions to separate surface familiarity from production judgment:
1. Explain why an iOS app cannot assume it will receive a final termination callback.
2. What is the difference between scene lifecycle, process lifetime, and task lifetime?
3. How can a feature remain correct if the app is killed between local mutation and server acknowledgement?
4. Why can a compressed 200 KB image cause multi-megabyte memory pressure?
5. What should happen to image prefetching in Low Power Mode or serious thermal state?
6. How do you decide whether retry is safe for a failed network request?
7. What makes a background task idempotent?
8. What does a memory termination report tell you that a Swift stack trace may not?
9. Why is a broad `@Observable` model risky for large SwiftUI lists?
10. How would you prove that a launch optimization improved real user experience after release?
11. What should be persisted before starting a long-running sync?
12. Which constraints are product constraints rather than purely technical constraints?

#### Source anchors for later chapter expansion
Use these official Apple references when expanding this topic into a full chapter:
- [Managing your app's life cycle](https://developer.apple.com/documentation/uikit/managing-your-app-s-life-cycle)
- [Background Tasks](https://developer.apple.com/documentation/backgroundtasks)
- [Reducing your app's memory use](https://developer.apple.com/documentation/xcode/reducing-your-app-s-memory-use)
- [Making changes to reduce memory use](https://developer.apple.com/documentation/xcode/making-changes-to-reduce-memory-use)
- [iOS Memory Deep Dive — WWDC18](https://developer.apple.com/videos/play/wwdc2018/416/)
- [Improving Battery Life and Performance — WWDC19](https://developer.apple.com/videos/play/wwdc2019/417/)
- [Energy Efficiency Guide for iOS Apps: Work Less in the Background](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/WorkLessInTheBackground.html)
- [Energy Efficiency Guide for iOS Apps: Minimize I/O](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/MinimizeIO.html)
- [ProcessInfo.ThermalState](https://developer.apple.com/documentation/foundation/processinfo/thermalstate-swift.enum)
- [MetricKit](https://developer.apple.com/documentation/metrickit)

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
