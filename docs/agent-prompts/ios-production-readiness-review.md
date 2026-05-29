# iOS Production Readiness Review Prompt

```markdown
Проведи iOS production readiness review без узкого фокуса.

Проверь:
- product contract and core flows;
- app lifecycle: cold/warm launch, foreground/background, relaunch;
- state ownership and navigation;
- persistence/data durability/migration;
- network/offline/sync/auth failure behavior;
- SwiftUI/UI hot paths, scrolling, media, memory;
- security/privacy/logging;
- accessibility/localization;
- observability/crash/performance metrics;
- release/TestFlight/App Store readiness;
- verification gaps.

Для каждого finding: P0/P1/P2/P3, affected files, evidence, why problem, target state, remediation order, required verification.
Если не можешь доказать production readiness, явно напиши remaining risk.
```
