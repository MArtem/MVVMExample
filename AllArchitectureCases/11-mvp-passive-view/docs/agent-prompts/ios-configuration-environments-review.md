# iOS Configuration And Environments Review Prompt

Use this for dev/staging/prod config, build flags, secrets, environment routing, and debug-only behavior.

## Prompt
Проведи production-grade iOS configuration/environments review.

Проверь:
- base URLs, auth mode, logging, flags, analytics/crash routing per environment;
- no production fallback to demo/stub/local services;
- secret source and committed-default risks;
- debug UI/logs gated out of production;
- diagnostics visibility without secret leakage;
- default-safe feature flags.

For every finding provide severity, affected files, evidence, target state, remediation order, and verification.
