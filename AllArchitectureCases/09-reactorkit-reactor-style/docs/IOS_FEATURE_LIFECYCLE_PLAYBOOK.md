# iOS Feature Lifecycle Playbook

## Purpose
A reusable end-to-end workflow for any iOS feature from idea to production operation.

## Lifecycle
1. **Intake**
   - Define user problem, target users, success criteria, non-goals.
   - Identify regulatory/privacy/security/platform constraints.
2. **Requirements**
   - Define acceptance criteria and all user states: loading, empty, error, offline, permission denied, partial success.
   - Define analytics, accessibility, localization, rollout, and support needs.
3. **Architecture**
   - Decide state owner, data owner, module boundary, API/persistence boundary, and failure ownership.
   - Record ADR for irreversible or broad decisions.
4. **Implementation**
   - Keep the solution minimal.
   - Avoid speculative abstractions and UI.
   - Keep hot paths clean and data flow explicit.
5. **Review**
   - Apply production review completeness gate.
   - Check generic iOS domains plus feature-specific domains.
6. **Verification**
   - Run static/build/test/manual/profiler gates appropriate to risk.
   - Capture evidence, not impressions.
7. **Release**
   - Use feature flags/rollout where risk warrants it.
   - Confirm App Store, privacy, signing, and compatibility requirements.
8. **Operation**
   - Monitor SLOs, crashes, performance, analytics, support issues.
   - Run incident process when thresholds are breached.
9. **Maintenance**
   - Update docs, risk/debt registers, runbooks, and ownership records.

## Stop Rule
If product behavior, ownership, rollback, or verification is unclear, stop and ask. Do not guess.
