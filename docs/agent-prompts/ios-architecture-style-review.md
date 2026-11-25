# iOS Architecture Style Review Prompt

Use this prompt when the user asks for architecture review, architecture migration planning, or review of code that may follow MVVM, SwiftUI native state, Clean/Layered, Coordinator, Modular, Hexagonal, TCA, UDF, ReactorKit, VIP, VIPER, MVP, RIBs, or MVC migration styles.

## Required Inputs
- Active project rules from `./docs/README.md`.
- Model routing from `./docs/MODEL_ROUTING_RULE.md`.
- Architecture router from `./docs/IOS_ARCHITECTURE_STYLE_ROUTER.md`.
- Relevant production gates from `./docs/IOS_PRODUCTION_FRAMEWORK.md`.

## Mandatory Guardrails
- Do not apply rules that conflict with active project rules.
- Do not introduce speculative architecture, wrappers, protocols, factories, adapters, use cases, or per-view models.
- In MVVM, prefer explicit ViewModel intent methods. Generic `send(_:)` / action enum dispatch requires explicit reducer/state-machine architecture approval and documented rationale.
- Tests are not generated unless the user explicitly opened test-writing scope.
- Fixture/mock/local JSON paths must be explicit dev/test seams, not silent production behavior.

## Review Steps
1. Identify the architecture style already present in the code.
2. If the code is mixed-style, identify intentional boundaries versus accidental mixing.
3. Apply only the matching architecture-specific review gate from `./docs/IOS_ARCHITECTURE_STYLE_ROUTER.md`.
4. Check dependency direction, state ownership, navigation ownership, data/model boundaries, concurrency, performance hot paths, error handling, accessibility, security/privacy, and verification needs.
5. Separate findings into:
   - must do now;
   - should do next;
   - later / only if needed;
   - do not do / overengineering.
6. If a proposed architecture change is broad or irreversible, require ADR/user decision before implementation.

## Output Format
For each finding, report:

- **Priority**: P0/P1/P2/P3.
- **Architecture**: detected style/gate.
- **Affected files**: concrete paths.
- **Issue**: what is wrong or risky.
- **Target state**: what correct architecture should look like.
- **Why it matters**: runtime/product/maintenance risk.
- **Decision**: integrate / reject / needs user decision.
- **Verification**: static/build/test/manual/profiler need, or why not needed.

## Completion Rule
Do not claim architecture is clean unless:

- the architecture style was identified;
- the matching gate was applied;
- conflicting rules were explicitly rejected;
- remaining risks are listed.
