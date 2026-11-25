# Product Requirements Standard

## Purpose
Prevents agents and engineers from guessing product behavior. Use before implementing any non-trivial feature.

## Required Artifact
Every feature should define:
- user problem / job-to-be-done
- target users
- affected user journeys and failure/recovery paths
- success criteria
- acceptance criteria
- explicit non-goals
- states: loading, empty, error, offline, permission denied, partial success
- analytics/observability requirements
- accessibility/localization requirements
- rollout/release requirements
- open questions

## Derive The Contract From A Short Request

Apply the request-refinement procedure in `AGENT_PREFLIGHT_CHECKLIST.md` before implementation.
Recover the relevant fields above from current user decisions and verified project context; do not
make the user restate known answers or fill an entire template. Explain inapplicable fields rather
than inventing requirements. For each affected critical journey, make the intended action, visible
outcome and relevant failure/recovery case concrete; Given/When/Then is one optional format.

Ask for missing product decisions before dependent changes. A proposed interpretation, existing
implementation, attractive improvement or example prompt does not authorize a new feature,
analytics collection, destructive policy or wider verification. Keep reversible implementation
assumptions and separately proposed improvements distinct from accepted product requirements.

## Stop Rule
If acceptance criteria or state behavior is unclear, ask the user/product owner before implementing.

For a new project/task/worktree, fill or explicitly defer `./docs/NEW_PROJECT_START_CONTRACT.md` before implementation starts.

## Review Output
- Requirements completeness: complete/incomplete.
- Missing decisions.
- Implementation risks.
- Required product answers before coding.
