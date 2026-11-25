# CI/CD Quality Gates

<!-- Rule ID: QC.CI.MANUAL_ADVISORY v1.0 -->

## Purpose
Define safe, reproducible GitHub verification for Xcode projects under the active manual-only,
zero-additional-cost policy.

Apply `./docs/UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md` first for user authority, project
modes, test permissions, recommendations, and source-of-truth boundaries.

## Execution Authority

- GitHub verification is manually triggered by the user for every project, including production.
- The default and reusable trigger is `workflow_dispatch` only. Automatic `pull_request`, `push`,
  `schedule`, merge-queue, or release triggers require a separately approved project-local exception.
- Supported policy modes are `off` and `manual`; mandatory CI is not active.
- Not running a workflow is `NOT_RUN_BY_USER_DECISION`, not PASS or FAIL.
- A workflow must not create, modify, or run tests unless the matching permission allows it.
- UI, Simulator/device, and performance/Instruments work require their separate permissions.
- Codex Review is a separate manual service and must not be called from CI by default.
- Branch protection and required checks remain deferred until the user explicitly reopens them.

## Manual Workflow Modes

- `static`: deterministic repository/source checks.
- `build`: static checks plus the selected Xcode build.
- `build-and-tests`: build plus permitted tests.
- `full`: the approved maximum project-specific matrix within current permissions.

Initial time budgets are 5, 15, 30, and 60 minutes respectively. A project may use a smaller
budget; expanding cost or runner class requires user approval.

## Required Execution Order

Each selected mode uses the applicable prefix of one reproducible pipeline:

1. check out and record the exact requested source SHA;
2. select and record the governed Xcode/toolchain version;
3. validate the project profile and declared dependency state, resolving dependencies only when
   the profile requires it;
4. run format verification, lint, deterministic static/architecture checks, secret scanning, and
   generated/resource validation applicable to the repository;
5. build the selected shared scheme and destination for `build` or higher;
6. run the permitted unit/integration tests for `build-and-tests` or higher;
7. run separately permitted snapshot/UI checks only when applicable to `full`;
8. run archive/signing/release checks only when the selected profile and current release purpose
   make them applicable; and
9. emit a terminal evidence report bound to the exact SHA, profile, engine, permissions, toolchain,
   executed checks, omissions, and residual risk.

Do not hard-code `macos-latest`, an assumed Xcode path, a universal simulator model, unconditional
SwiftPM resolution, archive, signing, snapshot tests, or UI tests. These are versioned project facts
or conditional capabilities, not reusable guesses.

## Project-Specific Static Gate Evolution

- Every active GitHub project maintains a user-triggered `static` workflow alongside its local static gate. The workflow runs the same authoritative project-specific checks; it is not a second, drifting collection of ad hoc commands.
- The local and GitHub gates are maintained as product code: update both together when the source graph, architecture, build/configuration, dependencies, platform surface, or evidenced defect changes the credible risk set.
- Add a new blocking check only when it deterministically detects a relevant defect class with a bounded scope and useful remediation. Classify broader signals as warning or review candidates to preserve trust and low noise.
- A missing runtime, toolchain, or permission must report `BLOCKED` or `NOT_RUN_BY_USER_DECISION`; it must never become a successful static result.

## Cost Boundary

- Expected additional monetary cost is `$0`.
- Use standard GitHub-hosted runners only where included usage is available.
- Larger paid runners and automatic paid overage are forbidden by default.
- Private repositories use included quota only; stop before additional spending.
- Workflows must not call OpenAI or another paid AI API, purchase credits, or depend on a paid
  quality service without separate approval.
- Minimize artifact retention and cancel obsolete runs for the same branch when safe.

## Deterministic Check Catalog

The engine owns stable check IDs, severity, applicability, fixture-proven detection, remediation, and
evidence fields. The shared catalog must cover, where applicable: project/profile validity, source
membership, compile and first-party warning policy, Swift concurrency diagnostics, dependency lock
drift, pinned format/lint rules, secrets, generated-file ownership, localization/assets/privacy
resources, signing-file changes, disabled tests, and TODOs without an owner or ticket.

Project-specific rules may additionally prohibit direct networking clients in features, DTOs in
presentation, hard-coded product strings/colors, or other declared architecture violations. Regex
checks are blocking only for fixture-proven subsets with acceptably low false-positive risk.
Complexity, file length, and possible god objects are warning/review signals unless a project has a
validated deterministic threshold. SwiftLint and SwiftFormat versions follow dependency policy and
are pinned when adopted; prefer engine-native checks when they already enforce the same invariant.

Build, unit/integration tests, snapshot/UI tests, archive/signing, dSYM/upload, and release artifacts
remain mode-, profile-, and permission-dependent. Store only relevant bounded artifacts such as
`.xcresult`, logs, coverage, lint/static reports, failure media, dependency reports, dSYM, or IPA;
redact private data and use minimal retention.

## PR Gate Output
Each PR/review states:
1. GitHub Manual Check necessity score and recommended mode.
2. Expected monetary cost and current test permission.
3. Checks selected, actually run, passed, failed, blocked, skipped, or not run by decision.
4. Exact source SHA, relevant toolchain/profile versions, and local evidence.
5. Manual checks and residual risk before merge/release.
6. A separate external Codex Review necessity score and mode; the workflow must not invoke it.

## Reproducibility Rules
- Pin the Xcode/runtime image or explicitly record the selected image/version.
- Pin third-party GitHub Actions by full commit SHA; record the human-readable release in a comment.
- Use fixed tool versions for linters/formatters where possible; avoid unreviewed `latest` installs in release-critical pipelines.
- Cache dependencies and toolchains deliberately. Be cautious with DerivedData caching because stale cache keys can create misleading build failures or hide integration problems.
- Use least-privilege workflow permissions and do not expose write credentials to untrusted code.
- Redact secrets and private data from logs, summaries, filenames, and uploaded artifacts.
- Evidence from another SHA, profile, engine version, or permission set is stale.

## Result Semantics

Individual results may retain the transport labels `PASS`, `FAIL`, `BLOCKED`, `NOT_APPLICABLE`,
`NOT_RUN_BY_USER_DECISION`, or `SKIPPED`. Overall engineering output must use the shared decisions
`PASS`, `NOT_READY`, `READY_WITH_ACCEPTED_RISK`, `BLOCKED`, or `NOT_APPLICABLE`; legacy labels
`READY`, `NEEDS_OWNER_DECISION`, and `BYPASSED` require the explicit mappings in
`UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md`.

A failure can make the engineering verdict not ready, but the workflow remains advisory and does
not technically block GitHub merge under the active policy. `BLOCKED`, `SKIPPED`, missing, stale,
or bypassed evidence must never be displayed as normal PASS. A mode reports overall PASS only when
every check applicable to that mode and profile passed or was explicitly and correctly classified
`NOT_APPLICABLE`; user-denied or unavailable required evidence produces a non-PASS verdict and
states the residual risk.

Coverage is evidence, not the quality goal by itself; never treat a coverage number as a substitute for correctness, privacy, accessibility, performance, and release readiness.
