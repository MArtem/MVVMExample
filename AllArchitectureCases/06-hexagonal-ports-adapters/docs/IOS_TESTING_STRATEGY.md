# iOS Testing Strategy

## Purpose
Defines when production iOS work requires unit, integration, UI, manual, relaunch, offline, migration, or performance verification.

This does not override task-local instructions that tests are opt-in. It defines what a production strategy should require when the user opens testing or release-readiness work.

## Test Decision Matrix
### Unit Tests
Use for:
- pure domain logic
- validation rules
- mappers/formatters/parsers
- reducers/state transitions
- date/number/string edge cases
- retry/backoff/idempotency decisions

### Integration Tests
Use for:
- repository + persistence
- API client + DTO mapping with mocked transport
- sync/outbox/conflict flows
- file import/export and media ownership logic
- auth/session refresh policy

### UI Tests
Use for:
- login/signup/logout smoke
- critical navigation paths
- composer/form submission
- destructive confirmations
- permission prompts where practical
- accessibility identifiers on critical flows

### Manual Simulator/Device QA
Use for:
- gestures, scrolling, animations, sheets
- visual polish
- keyboard/focus behavior
- device-size-specific layouts
- share extension and system integration flows

### Instruments / Performance Verification
Use for:
- feed/list scrolling
- media-heavy screens
- launch performance
- memory growth/leaks
- repeated navigation
- main-thread stalls

### Relaunch / Migration Verification
Use for:
- persistence changes
- schema changes
- app group shared data
- token/session storage
- settings/preferences
- draft/offline data

### Network/Offline Verification
Use for:
- API-backed screens
- sync flows
- login/session refresh
- upload/download
- retry and partial failure

## Required Production Test Report
For production-ready claims, state:
1. Test types required.
2. Test types executed.
3. Test types intentionally deferred and why.
4. Remaining risk if any required test was not run.
