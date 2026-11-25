# iOS Agent Prompt Router

## Purpose
Route work to the correct prompt/skill so reviews are not accidentally narrow.

## Working Procedures

Select the applicable row before implementation or review; combine only materially overlapping
concerns. Reuse current decisions and evidence. These are decision aids, not mandatory templates,
fixed counts of alternatives/tests, or authorization to execute the listed verification.
The reusable governance boundary maintains this router when a real task exposes a routing gap.

| Requested outcome | Useful procedure and compact output | Existing owner to consult |
|---|---|---|
| New feature or unclear behavior | Recover goal/current facts; resolve material unknowns; define observable success and relevant failure/recovery; choose the smallest useful slice before editing. | `PRODUCT_REQUIREMENTS_STANDARD.md`; product-requirements-review prompt |
| Bug, crash or hang | Record symptom, affected version and impact; distinguish observations from hypotheses; seek evidence that can falsify the leading explanation. State causal confidence, mitigation versus fix, and the gap if reproduction is unavailable. Missing reproduction limits the claim; it does not block useful authorized static investigation. | `IOS_TESTING_STRATEGY.md`; testing/debugging route for actual diagnosis |
| Legacy migration or dependency change | Inventory affected consumers; preserve agreed outward behavior and data compatibility; identify an incremental boundary, stop point and feasible recovery. Do not infer that code rollback also restores migrated data. | `ENGINEERING_CHANGE_QUALITY_STANDARD.md`; relevant migration/package/build route |
| Concurrency or inconsistent state | Trace operation/task owner, shared state, each suspension point and what may change there; describe one credible interleaving, cancellation and stale-result policy before selecting a fix. Compiler acceptance or an actor annotation alone is insufficient proof. | `IOS_CONCURRENCY_RUNTIME_STANDARD.md`; concurrency prompt |
| UI/design implementation | Recover layout intent, existing tokens and relevant screen states; include long/localized content, loading/error/recovery and accessible interaction where affected. A single image does not establish adaptive correctness. | UI/design route and relevant accessibility/localization prompt |
| Architecture or cross-team choice | State decision and owner; compare meaningful alternatives including the simplest viable option, operational/migration costs and strongest objection. Record why now and a concrete revisit trigger when the decision is durable. No compulsory new abstraction or ADR for mechanical changes. | `ARCHITECTURE_DECISION_GOVERNANCE.md`; architecture style route |
| Privacy/security or imported content | Trace actual assets, inputs, trust boundaries, side effects and controls; separate policy text from observed enforcement and name unverified boundaries. Do not export source or activate a local/cloud profile from a reference document. | security/privacy and input-validation routes |
| AI-powered product behavior | Start with user value and deterministic alternatives; follow the AI router for capability, data, validation, bounded execution, fallback and evaluation. Do not impose a provider, layer or model benchmark. | `agent-prompts/AI_iOS_TASK_ROUTER.md` |
| Review or readiness claim | Trace evidence-backed findings, try to disprove each, distinguish checked scope from unknowns, and match every completion claim to evidence. | `ENGINEERING_CHANGE_QUALITY_STANDARD.md`; evidence-based-completion-review prompt |
| Incident, release or rollout | Separate containment from permanent correction; identify impact, responsible owner, decision criteria and feasible recovery with data caveats. Proposed telemetry, flags, alerts or release actions remain proposals until in scope. | incident/release/observability route |

Choose specialists by the risk mechanism, not incidental words. For example: DTO decoding selects
API contracts; retry selects network resilience; durable replay selects offline sync. Identify
platform and capability applicability before using a platform-specific technique; never expand
supported platforms or restore excluded verification from a source example.

Only create an artifact when its decision will be consumed: a brief for unknown behavior, an ADR
for a durable trade-off, a hypothesis note for uncertain causality, a risk/evidence table for a
material gate, or a handoff for continuation. Reuse the existing owner and omit irrelevant fields.
Suggestions outside approved scope stay separate with value, cost and the smallest alternative.

## Routing Rules

Paths below identify the relevant skills, not a guarantee that a skill is installed or discoverable.
For canonical instruction lookup, resolve `./.codex/skills/<name>/` to
`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/local-ios-skills/<name>/` when
that canonical source exists. A session skill must still be available through its actual skill
catalog and accessed under current tool and filesystem permissions. If the canonical vault is
unavailable, use only the governed fallback and report missing skill availability.

- Feature request → `./docs/agent-prompts/product-requirements-review.md` then relevant domain prompts.
- UI/scroll/performance → `./docs/agent-prompts/ios-ui-state-rendering-review.md` and `./docs/agent-prompts/ios-performance-audit.md`.
- Async/tasks/main-thread → `./docs/agent-prompts/ios-concurrency-review.md`.
- Swift language/runtime/public API/ABI → `./.codex/skills/ios-swift-runtime/SKILL.md`.
- Reusable package ownership/adoption/integration → `./.codex/skills/ios-reusable-packages/SKILL.md` and the current project boundary.
- Media/files/cache → `./docs/agent-prompts/ios-memory-cache-media-review.md`.
- API/network → `./docs/agent-prompts/ios-network-resilience-review.md` and `./docs/agent-prompts/ios-api-contract-review.md`.
- Offline/sync/extensions/widgets → `./docs/agent-prompts/ios-offline-sync-review.md` and `./docs/agent-prompts/ios-lifecycle-background-review.md`.
- Security/privacy/permissions → `./docs/agent-prompts/ios-security-privacy-review.md` and, when external input is in scope, `./docs/agent-prompts/ios-input-validation-content-safety-review.md`. For a whole-project security audit, use the same prompt with whole-project scope; do not preload unrelated domain prompts.
- Identity/OAuth/passkeys/sessions/local authorization → `./.codex/skills/ios-identity-authentication/SKILL.md`.
- Xcode build/linking/binaries/dependency supply chain → `./.codex/skills/ios-build-system/SKILL.md`.
- Capabilities/entitlements/extensions/widgets/Live Activities/App Intents → `./.codex/skills/ios-platform-capabilities/SKILL.md`.
- Swift Testing/XCTest/debugging/LLDB/crash or hang diagnosis → `./.codex/skills/ios-testing-debugging/SKILL.md`.
- Accessibility → `./docs/agent-prompts/ios-accessibility-review.md`.
- Localization → `./docs/agent-prompts/localization-review.md`.
- Release/rollout → `./docs/agent-prompts/ios-release-readiness.md` and `./docs/agent-prompts/feature-flag-rollout-review.md`.
- App Review/privacy manifests/required reasons/compliance → `./.codex/skills/ios-app-store-compliance/SKILL.md`.
- Done/verified/production-ready claim → `./docs/agent-prompts/evidence-based-completion-review.md`.

### Xcode-specific skill routing
- SwiftUI code structure/data flow/performance → `./.codex/skills/swiftui-specialist/SKILL.md`; consult `swiftui-whats-new-27` only when the active SDK/deployment scope matches.
- App Intents implementation/review → `./.codex/skills/app-intents-specialist/SKILL.md`; version-specific changes → `app-intents-whats-new-27` after SDK verification.
- Device or Simulator UI interaction → `./.codex/skills/device-interaction/SKILL.md`. Runtime interaction, install, build, launch, and artifact access still require current-task authorization and the current registered tool schema.
- Xcode security settings/hardening → `./.codex/skills/audit-xcode-security-settings/SKILL.md`; it is a review route and does not authorize settings or entitlement changes.
- C bounds-safety adoption → `./.codex/skills/adopt-c-bounds-safety/SKILL.md`; UIKit API modernization → `./.codex/skills/uikit-app-modernization/SKILL.md`.
- Swift test-framework migration → `./.codex/skills/modernize-tests/SKILL.md`; document-based SwiftUI app work → `./.codex/skills/building-document-based-swiftui-applications/SKILL.md`.

Imported Xcode skills are domain references. Their presence does not grant permission to run tools or change project files, and their source claims must be checked against the active SDK and current rules.

## Stop Rule
If no route clearly fits, state the uncertainty and select the smallest relevant owner or clarify a material scope ambiguity. Use `./docs/agent-prompts/ios-production-readiness-review.md` for a requested broad readiness review; do not expand a bounded task into one merely because routing is unclear.

## Architecture Style Routing
- Use `./docs/agent-prompts/ios-architecture-style-review.md` with `./docs/IOS_ARCHITECTURE_STYLE_ROUTER.md` when code or requirements mention MVVM, SwiftUI native state, Clean/Layered, Coordinator, Modular, Hexagonal, TCA, Redux/Elm/UDF, ReactorKit, VIP/Clean Swift, VIPER, MVP, RIBs, or MVC migration.
- Do not apply architecture-specific rules that conflict with active project rules; report conflicts and ask for explicit user decision.
