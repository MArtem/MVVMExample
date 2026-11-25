---
name: ios-performance-profiler
description: Profile, benchmark, audit, monitor, diagnose, or improve runtime performance of any iOS app, target, feature, screen, module, or bounded data set. Map real journeys, choose authorized measurements, attribute signals to code, fix within scope, and re-profile comparably. Trigger on “profile”; not an ordinary review without a performance or runtime-evidence question.
---

# iOS Performance Profiler

## Goal

Find code defects behind CPU/energy cost, memory growth/leaks, unnecessary view work, hitches/hangs,
concurrency stalls, launch delay, or I/O/network latency. A metric is a signal: connect it to an
owning code path before claiming a runtime cause or changing code. Static analysis, functional tests,
and runtime profiles answer different questions.

This is app-neutral: assume no game, architecture, UI framework, data source, backend, or feature.
“Full” means considering every applicable scenario and metric domain within user bounds and reporting
gaps; it does not promise exhaustive combinations or that every issue was found.

## Scope And Authority

- Resolve project/target, feature and data bounds, environment, time window, deliverable, and
  exclusions from the request and task docs. Ask only when missing facts change safety, ownership,
  coverage, or conclusions.
- Load the active bootstrap/router, task plan/handoff, project route, evidence rules, and relevant
  specialist skills. Apply current model routing before material work.
- Distinguish planning, authorized review of existing artifacts, and new capture; existing evidence
  does not grant permission for new execution. If capture is unauthorized, return the plan/evidence gaps,
  not a claim that runtime profiling occurred.
- Check authority separately for source edits, test changes/execution, builds, app launch, UI/Simulator,
  Instruments, fixture/reset, service effects, devices, and tool installs. A plan grants none. A
  diagnose-and-fix request may authorize only its named block; active rules still govern, and grants
  never carry across projects. An authorized manual driver can provide evidence without UI tests;
  do not create a harness unless permitted.
- Apply current user exclusions: omit iPad, physical-device, and actual VoiceOver checks from plans
  and gates; preserve historical evidence and mark excluded coverage `OMITTED_BY_USER`, never PASS.
  Preserve privacy, platform, and severity rules. Never use secrets or production accounts as
  fixtures; do not install/download tools without authorization.

## Workflow

### Phase Gates And Readiness

Before capture, record whether target/build, OS/runtime/tool versions, selected metrics/export path,
driver/PID attachment, fixture/reset, backend, and private artifact storage are available. Availability
is not permission. Keep this inventory non-invasive until each build, launch, UI, Instruments, fixture,
or service action is authorized; Simulator GUI and `simctl` availability are separate facts.

Keep three reviewable gates even when the user authorizes an end-to-end run:

1. **Discovery:** use authorized existing evidence or permitted captures to produce the prioritized
   coverage matrix, actual outcomes when observed, valid measurements or explicit gaps, and ranked
   candidate signals.
2. **Cause localization:** correlate reviewed evidence with source; report confirmed causes vs
   hypotheses and a minimal fix plan.
3. **Repair/re-profile:** make only authorized changes and compare the same scoped workload.

Carry a privacy-safe evidence bundle between stages: revision/configuration, environment/toolchain,
permissions/readiness, scenario/fixture/branch, metric/unit/process/interval, sample population,
artifact references, limitations, and unresolved questions. Follow the detailed stage contract in
`PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md`; do not invent a new status taxonomy.

For this `.zenflow` workspace, store full profiling reports, scenario matrices, metric exports, and
retained raw profiling outputs under `/Users/Artem/.zenflow/profiling-results/<ProjectSlug>/<TaskId>/`;
use `artifacts/` for traces, result bundles, logs, and attachments, and `metrics/` for structured
metric exports. Keep the active `plan.md` and compact `handoff.md` in the project task directory as
task state; they must link to the central report and manifest instead of duplicating full reports.
Create the per-task `manifest.md` in the central directory and update the root `README.md` and
`INDEX.md`. Keep the shared evidence root local and outside Git/the documentation vault. In another
environment, use only a task-approved private artifact path; do not assume this host path is available.

### Required Finding Disposition

Every signal that may indicate a code defect—including a confirmed defect, a plausible static
candidate, or an unexplained runtime symptom—must receive an individual, durable disposition.
Do not end profiling with a findings-only list or silently defer a candidate. For each item record:

- confirmed defect vs hypothesis, evidence, confidence, severity/impact, affected user path, and
  owning code location (or the exact missing attribution);
- a finding-specific sequence to resolve uncertainty, identify the responsible mechanism, and
  correct it if confirmed, including the smallest relevant source/test changes and permitted
  verification;
- whether the current task authorizes that work, what was actually changed, and any precise blocker
  if it cannot be completed now.

Continue each item through diagnosis and the authorized correction within the agreed project/task
scope. A hypothesis is not a license for speculative optimization: first gather enough evidence to
establish a code defect or materially reduce the uncertainty, then fix the smallest proven cause.
When source changes are authorized, do not stop at a plan if the required correction is established
and can be safely completed. If the work is blocked by evidence, scope, permission, or an unresolved
contract, preserve the executable next steps and name the blocker rather than claiming closure.

For every corrected finding, report correctness/guardrail verification and explicitly decide whether
comparable re-profiling is needed. Re-profile when needed to verify a runtime/performance claim or
when the change's risk warrants it; otherwise explain why existing permitted evidence or a static
contract check is sufficient and leave performance improvement unclaimed. Every finding must finish as
fixed and verified, fixed with comparable runtime re-profile outstanding, unresolved with a concrete
plan and blocker, or explicitly rejected with evidence; none may disappear from the final report. Use
the project's existing finding/task status vocabulary; these reporting outcomes do not define a new
status enum.

Coverage accounting is complete only when every identified journey has an observed outcome or an
explicit not-run status/reason, every applicable metric domain has a result or stated gap, and no
priority path is silently dropped. This accounts for scope; it does not mean everything was measured
or that no other defects exist. Unresolved gaps are not PASS.

### 1. Map And Prioritize Real Journeys

- Confirm project identity, targets, architecture, ownership, and relevant data flow. Source describes
  implementation, not unrecorded product requirements.
- Map actual entry/action/state/navigation/loading/success/failure/recovery/retry/cancel/lifecycle paths
  as applicable.
- For each scenario record goal, initial state/fixture, data envelope, ordered actions, terminal
  invariant, driver, metric question, reset authority, and evidence gap. Preserve actual randomized
  outcomes or use an authorized deterministic fixture.
- Rank by user impact, known frequency, harm, symptoms/changes, uncertainty, and evidence value/cost.
  Keep the in-scope inventory visible; priority is not finding severity. Untested branches remain gaps.

### 2. Select Applicable Measurements

Consider applicable launch/readiness, CPU/latency/hangs, rendering, memory/lifetime, concurrency,
I/O/network/storage/media, and energy/thermal domains. Use the metric/tool matrix in
`PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md`; avoid running every instrument on every feature or
silently dropping a relevant domain when a tool is unavailable. Record each chosen tool/version,
process, unit, action interval, expected data, and limitation. Unsupported tools, empty tables, failed
attachments, or invalid process identity are gaps, never zero cost or PASS. Simulator energy, thermal,
and graphics results are diagnostic proxies, not physical-device claims.

Choose project control, scenario driving, and measurement collection independently. Inspect the live
Xcode MCP and XcodeBuildMCP registry/schema rather than assuming tools from a server name or an older
session. Xcode MCP project discovery/build/run/device operations and XcodeBuildMCP automation can
prepare or exercise a workload; neither is itself an Instruments trace unless the actual returned
artifact is a valid trace with the requested populated data. Use Instruments/`xctrace` or an applicable
authorized XCTest metric/signpost for the measurement. Select one primary UI driver per capture and
account for AX queries, screenshots, logs and other automation inside the timed interval. Validate
each requested track against the exact destination/runtime: unsupported Hitches or an empty track is
an evidence gap, not proof of smoothness. For tool-role details, field-diagnostic distinctions and
artifact checks, follow the matrix in `PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md`.

### 3. Make Capture Trustworthy

- Use safe, representative, bounded fixtures. Record seed/actual outcome, data size, cache/network
  state, app revision, build/runtime/device/host, toolchain, diagnostics, warmup, repetitions, and reset.
- Prefer app-owned `OSSignposter` intervals/events and `XCTOSSignpostMetric` at action/subsystem
  boundaries when appropriate. Use stable low-cardinality labels and non-sensitive metadata; never
  trace user content, credentials, precise locations, or identifiers. Gate costly diagnostics.
- Minimize automation inside the timed interval. Defer assertions, attachments, and expensive
  accessibility queries when valid; account for screenshots, logging, queries, and profiler attachment
  as possible measurement overhead.
- Verify app PID/build/session and exported samples, units, and interval coverage. A passing test or
  trace file alone does not prove collection. Keep artifacts inside the authorized boundary; retain
  failed/partial captures as such and protect private data.

### 4. Attribute Signals To Code

Connect action/interval to app stacks or signposts, thread/actor, view-update or retention evidence,
then to the responsible source path and data/state/ownership flow. Inspect relevant call sites and
consumers. Consider growth/copying, blocking, repeated invalidation/layout, allocation/retention,
caches, synchronization/priority, synchronous I/O, or resource lifetime only when evidence points
there. Static evidence can prove a code-contract defect or narrow candidates; runtime evidence shows
cost and reproduction. Correlation, a source-pattern match, negative/noisy trace, empty profile, or
missing sample alone proves neither runtime defect nor absence. State causal evidence and confidence;
use existing P0–P3 rules, keeping scenario priority separate from finding impact.

### 5. Fix And Re-Profile

- Separate triage, cause localization/fix planning, implementation, and verification. Follow the
  requested stage, permissions, and change contract; diagnosis does not authorize an out-of-scope fix.
- Choose the smallest correct fix preserving behavior, ownership, concurrency, data, and accessibility.
  Change regression tests only when allowed.
- Repeat the same scoped journey, fixture, data envelope, build/runtime, and metric interval. Compare
  values, samples, variance, branch coverage, and capture quality. Claim improvement only for
  comparable conditions/units; do not invent budgets, repetitions, confidence, or gains.
- If measurement or attribution is blocked, try a useful permitted alternative or report the exact
  blocker and smallest next action. Incomplete evidence cannot support “no issues”.

## Report

Return scope/authority/exclusions; prioritized journeys and actual outcomes; each applicable domain’s
measured, invalid/unsupported, omitted, or unmeasured status using project vocabulary; metric/unit,
process/interval, revision/configuration, repetitions/variance, artifact, result, and limits; findings
with existing severity, confirmed-vs-hypothesis status, impact, reproduction, code location, causal
evidence, and confidence; authorized changes/tests and before/after results; residual risk and the
smallest next permitted step.

## Filesystem And Artifact Containment

- Treat the user's explicitly allowed root (for this workspace, `/Users/Artem/.zenflow`) as a
  hard policy boundary for every agent-owned read, write, delete, move, command output, cache,
  trace, screenshot, test result, and report. Check the active sandbox separately: it may grant
  less access or expose writable paths outside this user boundary. Never widen or bypass either.
- Use one retained evidence root across projects: `/Users/Artem/.zenflow/profiling-results/<ProjectSlug>/<TaskId>/`.
  Put all reports, traces, screenshots, `.xcresult` bundles, logs and metrics there in task-owned
  subdirectories; do not create alternate retained-result roots under `tmp/ActionArtifacts`, app
  worktrees, or the documentation vault. Create a unique run subdirectory and use private
  permissions where supported. If the active sandbox cannot write the root, stop; do not substitute
  an outside temp directory.
- The current user explicitly keeps Xcode `DerivedData` at Xcode's normal system location outside
  `.zenflow`. Do not pass a custom `.zenflow` DerivedData path, copy DerivedData into the evidence
  root, or clean/read it manually. This narrow build-cache exception is not a profiling-result
  location and does not authorize a build by itself.
- Set `TMPDIR` to a run-local directory where the tool honors it. For `xcodebuild`, explicitly set
  supported result-bundle and other retained-output paths inside the central evidence root, and
  redirect stdout/stderr there; let DerivedData use the normal Xcode location. For `xctrace`, pass
  an explicit trace output path inside the evidence root. These options do not prove that every
  tool cache, Simulator/CoreSimulator file, service log or temporary file is confined there;
  record what remains uncontrolled.
- Read-only exception: the user authorizes opening MCP-generated report/artifact files inside an
  `ActionArtifacts` directory when the MCP response directly returns their paths, solely to
  interpret that operation's result. Read only the referenced files needed for interpretation;
  do not enumerate unrelated directory contents or inspect sibling/system files. Do not modify,
  copy, move, delete, or treat those temporary files as retained profiling results. Keep retained
  evidence under the shared `profiling-results` root. If the active sandbox blocks the authorized
  read, stop and report the technical limit; never bypass or expand sandbox access. Structured
  fields already present in an MCP response may still be analyzed in memory. Report
  service-created external paths and any limits on containment.
- If an MCP service cannot accept an approved output root, do not claim its artifacts are isolated
  or try symlink, privilege, configuration or sandbox workarounds. Use only safe structured
  response data, or stop before the dependent action if it needs a write outside the approved root.
  Service-generated files outside the root are not retained profiling results and must not be
  moved into the evidence root.
- Do not claim technical isolation from these instructions alone. State separately which process
  created each artifact and whether the host sandbox actually enforced the boundary.

## References

Resolve `DOC:` identifiers through the active task router; references grant no permissions.

- `DOC:IOS_PERFORMANCE_BUDGETS.md`
- `DOC:PRODUCTION_CODE_REVIEW_CHECKLIST.md`
- `DOC:knowledge/global/ios/PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md` — metric selection,
  capture, analysis, and observability detail.
