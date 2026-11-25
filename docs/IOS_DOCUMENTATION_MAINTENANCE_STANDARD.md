# iOS Documentation Maintenance Standard

## Purpose
Keep documentation accurate enough to drive implementation, review, onboarding, and incident response.

## Required Rules
- Docs that define behavior must be updated in the same change that changes behavior.
- Obsolete docs must be archived or marked superseded; do not leave conflicting active docs.
- Every production-critical area must have owner, source of truth, and update trigger.
- Context-transfer docs must include current constraints, verification status, and remaining risks.
- Generic rules must not contain app-specific facts.
- Apply `./docs/IOS_PLATFORM_SCOPE_AND_KNOWLEDGE_POLICY.md` to reusable iOS theory and maintain topic status in `./docs/IOS_KNOWLEDGE_COVERAGE_REGISTRY.json`.
- Re-check primary sources after the policy's toolchain, WWDC, App Review, privacy, security, incident, or deprecation triggers; update the verification date or mark the topic stale.
- A heading, placeholder, keyword, or package entry does not qualify a topic as complete.

## Review Checklist
- Did implementation change product behavior?
- Did architecture/data/API behavior change?
- Did verification or release process change?
- Did risk/debt change?
- Are docs indexed from the main documentation map?
- Does the coverage registry still point to existing, routed operating docs, deep references, skills, and review triggers?
