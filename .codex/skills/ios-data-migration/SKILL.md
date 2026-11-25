---
name: ios-data-migration
description: Use this skill for iOS data migration, SwiftData/CoreData/UserDefaults/files/app-group compatibility, schema changes, destructive migrations, old-data fixtures, relaunch checks, rollback, and persistence durability. Trigger whenever migration, schema, persistence compatibility, relaunch data, or app-group data changes are mentioned.
---

# iOS Data Migration

## Workflow
1. Identify source-of-truth vs cache data.
2. Check schema/version compatibility and decode behavior.
3. Decide migration vs destructive reset; require explicit user acceptance for destructive behavior.
4. Define relaunch/old-data verification.
5. Check rollback and app-group/extension implications.

## Output
- Data inventory.
- Migration risks P0-P3.
- Target migration policy.
- Verification plan.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_DATA_MIGRATION_STANDARD.md`
