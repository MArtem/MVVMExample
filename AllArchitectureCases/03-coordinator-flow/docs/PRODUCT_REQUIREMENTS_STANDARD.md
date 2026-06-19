# Product Requirements Standard

## Purpose
Prevents agents and engineers from guessing product behavior. Use before implementing any non-trivial feature.

## Required Artifact
Every feature should define:
- user problem / job-to-be-done
- target users
- success criteria
- acceptance criteria
- explicit non-goals
- states: loading, empty, error, offline, permission denied, partial success
- analytics/observability requirements
- accessibility/localization requirements
- rollout/release requirements
- open questions

## Stop Rule
If acceptance criteria or state behavior is unclear, ask the user/product owner before implementing.

## Review Output
- Requirements completeness: complete/incomplete.
- Missing decisions.
- Implementation risks.
- Required product answers before coding.
