---
name: ios-security-privacy
description: Review iOS security/privacy when the task audits or changes a sensitive-data flow, trust boundary, permission, credential lifecycle, or security control; not for an incidental mention.
---

# iOS Security Privacy

## Workflow
1. Apply the security gate to the affected assets, entry points, trust boundaries, and data lifecycle.
2. For a requested scoped or whole-project audit, use the security review prompt for evidence, reachability, confidence, and unknowns; do not treat keyword matches as vulnerabilities.
3. Classify severity from demonstrated impact and exposure, not from the API name alone. A review request is read-only; implement only when the user requests an implementation or fix.

## Output
- Affected assets and boundaries; evidence-backed findings or a scoped no-finding result.
- Severity, confidence, remediation, and permitted or user-owned verification.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_SECURITY_PRIVACY_GATE.md`
- `DOC:agent-prompts/ios-security-privacy-review.md` for an audit request only.
