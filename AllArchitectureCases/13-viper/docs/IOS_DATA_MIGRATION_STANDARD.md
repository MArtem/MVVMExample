# iOS Data Migration Standard

## Purpose
Rules for SwiftData/CoreData/UserDefaults/files/app-group data compatibility and migration.

## Required Checks
- Identify source-of-truth data vs cache/regenerable data.
- Define schema versioning policy.
- Preserve decode compatibility for shipped data unless destructive reset is explicitly accepted.
- Provide old-data fixtures for production migration testing where practical.
- Consider app group and extension shared data separately.
- Define rollback behavior if a release is pulled.
- Define cleanup for temporary/imported files.

## Pre-Production Exception
If the app is explicitly pre-production and the user approves destructive migration, document:
1. What data can be destroyed.
2. Why migration is not needed.
3. How to reset local state.
