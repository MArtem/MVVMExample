# iOS Production Readiness Review Prompt

<!-- Refer to QC.VERDICT.READINESS, QC.EVIDENCE.FRESHNESS, and QC.EXCEPTION.CONTRACT. -->

```markdown
Проведи iOS production readiness review без узкого фокуса.

Перед выводом свяжи каждый finding и общий verdict с применимым Rule ID из
`./docs/QUALITY_RULE_CATALOG.md`. Разделяй severity, confidence, applicability, evidence status и
readiness level; отсутствие runtime/build/test evidence оставляй как remaining risk.

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
