---
name: ios-release-engineering
description: Use this skill for iOS release readiness, TestFlight, App Store, signing, provisioning, entitlements, app groups, bundle IDs, dSYM upload, build numbers, privacy labels, archives, rollout, rollback, and release checklists. Trigger whenever the user mentions release, TestFlight, App Store, signing, archive, provisioning, or production rollout.
---

# iOS Release Engineering

## Workflow
1. Check signing, bundle IDs, entitlements, App Groups, version/build number.
2. Check archive/TestFlight/App Store requirements.
3. Check privacy labels/manifests and dSYM/crash reporting.
4. Check critical-flow smoke matrix and rollback plan.
5. Return release/no-release recommendation.

## Output
- Release blockers.
- Remaining risks.
- Required verification.
- Release recommendation.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_RELEASE_CHECKLIST.md`
- `DOC:CI_CD_QUALITY_GATES.md`
