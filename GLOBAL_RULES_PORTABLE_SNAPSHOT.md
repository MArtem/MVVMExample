# Portable Global Rules Snapshot

<!-- AIZENFLOW_GLOBAL_RULES_PORTABLE_SNAPSHOT_V1 -->

## Purpose

This compact, versioned fallback keeps an adopted repository operable in an authorized clean clone
or review worktree under `/Users/Artem/.zenflow` where the canonical documentation vault is
unavailable. It is not a second authority and must never be described as the latest canonical
baseline.

## Activation

Use this snapshot only when
`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/GLOBAL_RULES_BOOTSTRAP.md` cannot be
read. Respect the already-loaded repository `AGENTS.md` and tracked local documentation; do not
fetch, invent, or borrow rules from another app or archive. This fallback never authorizes work
outside `/Users/Artem/.zenflow`; an external CI runner or checkout remains blocked until the user
grants a separate sandbox. Report
`canonical-baseline-unavailable` and this snapshot marker in the handoff, receipt, or completion
report.

## Effective instruction and project-type routing

- The repository-root `AGENTS.md` marker is the portable adoption point. Parent instruction files
  are defense in depth; an empty or unrelated global Codex file does not replace a repository
  entry.
- Load the common engineering baseline first, then route by project/task type. iOS specialist rules
  and QualityControl engine adoption remain profile/opt-in scoped; this snapshot must not silently
  rewrite non-iOS projects or activate the engine.
- Inspect and preserve repository-local or nested `AGENTS.override.md` overlays. One marker is not
  proof that every downstream document was received.
- Record snapshot identity, canonical-unavailable state, repository root, environment facts and
  selected routes. Unset values remain unknown. When canonical authority returns, re-route from it
  and do not silently overwrite the snapshot.

## Minimum Non-Negotiables

- Follow explicit user instructions and repository instructions; local overlays may strengthen but
  may not silently weaken known reusable rules.
- Keep work inside the authorized project sandbox. Do not access secrets, external workspaces,
  machine-wide caches, toolchains, Simulator runtimes, or unrelated user files without authority.
- Do not run build, tests, Simulator, signing, archive, or external services unless authorized.
- Use one bounded patch, targeted inspection, and relevant static evidence. Do not expand a
  documentation or product PR into speculative tooling, broad cleanup, or unrelated review work.
- A new iOS/Xcode Git repository must receive the governed bootstrap before project work. When an
  externally created repository lacks it, block project work until bootstrap or an explicit owned
  deferral is recorded.
- GitHub verification remains user-triggered; reusable workflows use `workflow_dispatch` only.
  Missing, skipped, stale, denied, or unavailable evidence is never normal PASS.
- After the user explicitly authorizes a new PR, perform the internal Exhaustive candidate-range and
  exact-SHA review, resolve P0–P2, and keep external Codex Review user-triggered.
- Do not claim current global-rule compliance, exact canonical revision, passing unrun checks, or
  production readiness while operating through this fallback.

## Return To Canonical Authority

When the canonical vault becomes available, resume normal routing from its global bootstrap. A
project snapshot is updated only through a reviewed baseline-adoption change; it is never
overwritten automatically.
