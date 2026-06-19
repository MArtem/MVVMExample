# Master Prompt: ADR

Source: `master prompt для Architecture Decision Record : ADR.rtf`

---

You are a Staff-level iOS Architect and Principal iOS Engineer.

Your task is to create an Architecture Decision Record (ADR) for a real production iOS app.

The ADR must be practical, clear, reviewable, and useful for a small iOS team.
Do not write vague architecture theory.
Do not overengineer.
Do not assume the most complex solution is the best solution.

The goal is to document:
- what decision we are making;
- why we are making it;
- what alternatives were considered;
- what trade-offs we accept;
- how this decision affects the project over 3–5 years;
- how AI-generated code should follow this decision.

============================================================
PROJECT CONTEXT
============================================================

Project:
- Production iOS app
- SwiftUI
- iOS 17+
- Feature-based MVVM by default
- Small team: 2–3 iOS developers
- Backend/API exists or will exist
- Offline/cache/database may be needed
- Codebase should live for 3–5 years
- AI-assisted development is part of workflow

General engineering preferences:
- Best practices without overengineering
- Clear boundaries
- Human-readable architecture
- Low onboarding threshold
- Dependencies through init
- Repository protocols where they protect real boundaries
- DTO must not leak into SwiftUI Views
- View receives ViewState, not DTO/API/DB models
- ViewModel is usually @MainActor if it owns UI state
- async/await
- cancellation-aware code
- no hidden singleton dependencies
- no direct URLSession in View/ViewModel
- no force unwrap / try! / print in production
- design tokens via AppTheme/AppSpacing/AppTypography/AppRadius
- AppLocalization for strings
- feature flags for risky rollout
- tests and CI are part of architecture quality

============================================================
DECISION INPUT
============================================================

ADR title:
[PASTE TITLE]

Decision area:
[Architecture / State management / Navigation / Networking / Persistence / Sync / Design System / AI Layer / CI/CD / Testing / Modularization / Other]

Problem statement:
[WHAT PROBLEM ARE WE SOLVING?]

Current situation:
[HOW IT WORKS NOW / WHAT PAIN EXISTS]

Decision to evaluate:
[THE PROPOSED DECISION]

Known constraints:
- Team size:
[2–3 iOS developers / other]

- Timeline:
[MVP / production soon / long-term refactor / migration]

- Existing code:
[legacy MVVM / SwiftUI / UIKit mix / no architecture / existing packages / etc.]

- Backend/API:
[stable / unstable / not ready / mock JSON / real endpoints]

- Offline/cache:
[needed / not needed / future requirement / unknown]

- Testing:
[current test level / desired test level]

- Release risk:
[low / medium / high]

- AI-generated code:
[will be used / not used / agent-generated PRs expected]

Possible options:
[PASTE OPTIONS IF KNOWN, OTHERWISE PROPOSE 3–5 OPTIONS]

Decision owner:
[NAME / TEAM / ROLE]

Date:
[DATE]

Status:
[Proposed / Accepted / Deprecated / Superseded]

============================================================
YOUR TASK
============================================================

Create a complete ADR.

Before writing the final ADR, analyze the decision deeply.

Think through:
1. Product impact.
2. Engineering impact.
3. Team impact.
4. Long-term maintainability.
5. Migration complexity.
6. Testing strategy.
7. Swift Concurrency implications.
8. AI-generated code implications.
9. Release safety.
10. Rollback strategy.

Do not choose an option only because it is architecturally elegant.
Choose the option that is best for this project, team, timeline, and long-term maintainability.

============================================================
ADR REQUIREMENTS
============================================================

The ADR must include these sections:

1. Title

Use format:
ADR-XXX: [Decision title]

2. Status

One of:
- Proposed
- Accepted
- Deprecated
- Superseded

If Superseded, mention by which ADR.

3. Date

Use ISO format if possible.

4. Decision owner

Who owns this decision.

5. Context

Explain:
- what problem exists;
- why now;
- why this decision matters;
- what will happen if we do nothing;
- what constraints exist;
- what parts of the app are affected.

6. Goals

List what the decision should optimize for.

Examples:
- production safety;
- maintainability;
- testability;
- simplicity;
- team onboarding;
- AI-generated code consistency;
- performance;
- offline readiness;
- release safety;
- scalability over 3–5 years.

7. Non-goals

Clearly say what this decision does not try to solve.

Examples:
- not building full Clean Architecture;
- not introducing TCA;
- not solving offline sync yet;
- not modularizing every feature now;
- not rewriting legacy code in one big PR.

8. Decision drivers

List the forces behind the decision.

Include:
- team size;
- existing architecture;
- project lifetime;
- expected feature growth;
- backend stability;
- need for tests;
- performance constraints;
- concurrency risks;
- AI-assisted development risks;
- release risk.

9. Options considered

Evaluate at least 3 options.

For each option include:
- Description
- Pros
- Cons
- Risks
- Complexity
- Testing impact
- Migration impact
- Long-term consequences
- AI-generated code implications

Use practical iOS examples.

10. Decision

Clearly state the selected option.

Use direct language:
“We will use...”
“We will not use...”
“We will allow...”
“We will forbid...”

11. Rationale

Explain why this option is better than the alternatives for this project.

Do not say only:
“because it is cleaner.”

Explain:
- why this level of complexity is appropriate;
- why it is not too simple;
- why it is not overengineered;
- how it helps the team;
- how it supports AI-assisted development;
- how it supports testing and release safety.

12. Consequences

Split into:

Positive consequences:
- ...

Negative consequences:
- ...

Neutral / accepted trade-offs:
- ...

13. Architecture rules

Turn the decision into concrete rules.

For example:
- Views must not receive DTOs.
- ViewModels must depend on repository protocols.
- Repositories must not be @MainActor unless justified.
- Feature modules must not import other feature internals.
- DesignSystem must not depend on features.
- AI clients must be hidden behind protocols.
- Feature flags are required for risky rollout.

14. File structure impact

Show recommended file/module structure.

Example:

Features/
  Feed/
    Presentation/
    Domain/
    Data/
    Tests/

Packages/
  DesignSystem/
  Networking/
  Analytics/
  TestSupport/

15. Dependency graph

Explain allowed dependencies.

Use ASCII diagram if useful.

Example:

App
 ├── Features
 ├── DesignSystem
 ├── Networking
 ├── Persistence
 ├── Analytics
 └── FeatureFlags

Features
 ├── DesignSystem
 ├── Domain protocols
 └── Shared infrastructure protocols

DesignSystem
 └── no feature dependencies

16. Implementation plan

Give incremental steps.

Each step must:
- be small enough for a PR;
- compile independently;
- be reviewable;
- have testing guidance;
- minimize production risk.

Use format:

Step 1:
- change:
- files:
- tests:
- risk:
- rollback:

Step 2:
...

17. Migration plan

If legacy code exists, define:
- current state;
- target state;
- intermediate states;
- compatibility bridge;
- how old and new code coexist;
- how to avoid big bang rewrite.

18. Testing strategy

List required tests:
- unit tests;
- mapper tests;
- async/concurrency tests;
- snapshot tests;
- UI tests;
- integration tests if needed.

For each test type, explain what it protects.

19. Swift Concurrency implications

If relevant, include:
- MainActor rules;
- task ownership;
- cancellation;
- stale response prevention;
- actor usage;
- Sendable requirements;
- repository/cache thread safety;
- heavy work off main.

20. AI-assisted development implications

Explain how AI-generated code must follow this ADR.

Include:
- prompt rules;
- code review checklist;
- forbidden patterns;
- required file structure;
- required tests;
- examples of acceptable vs unacceptable AI-generated code.

21. Release safety

Include:
- feature flag needs;
- rollout strategy;
- monitoring;
- crash reporting;
- analytics;
- rollback plan.

22. Rollback strategy

Explain how to revert or disable this decision if it causes problems.

Examples:
- disable feature flag;
- keep old implementation temporarily;
- use adapter layer;
- rollback package version;
- revert PR;
- clear cache/schema if needed.

23. Observability

What should be monitored:
- crashes;
- performance;
- time to first content;
- error rate;
- cache hit rate;
- sync failures;
- AI latency/failure if relevant;
- analytics events.

24. Security and privacy

If relevant:
- data boundaries;
- logging restrictions;
- token storage;
- PII handling;
- AI prompt/output privacy;
- analytics privacy.

25. Open questions

List unresolved questions.

26. Review checklist

Create a checklist reviewers can use to enforce this ADR in PRs.

27. Examples

Provide concrete examples:

- Good example
- Bad example
- Borderline example

Use Swift/SwiftUI snippets when helpful.

28. Final recommendation

End with:
- selected decision;
- why it is recommended;
- what to do next.

============================================================
OUTPUT FORMAT
============================================================

Use this exact structure:

# ADR-XXX: [Title]

## Status

## Date

## Decision Owner

## Context

## Goals

## Non-goals

## Decision Drivers

## Options Considered

### Option 1: [Name]
- Description:
- Pros:
- Cons:
- Risks:
- Testing impact:
- Migration impact:
- AI-generated code impact:
- Long-term consequences:

### Option 2: [Name]
...

### Option 3: [Name]
...

## Decision

## Rationale

## Consequences

### Positive

### Negative

### Accepted Trade-offs

## Architecture Rules

## File Structure Impact

## Dependency Graph

## Implementation Plan

## Migration Plan

## Testing Strategy

## Swift Concurrency Implications

## AI-assisted Development Implications

## Release Safety

## Rollback Strategy

## Observability

## Security and Privacy

## Open Questions

## PR Review Checklist

## Examples

### Good Example

### Bad Example

### Borderline Example

## Final Recommendation

============================================================
STYLE REQUIREMENTS
============================================================

Write clearly and practically.
Use direct engineering language.
Avoid abstract enterprise jargon.
Avoid architecture astronaut language.
Prefer concrete iOS examples.
Separate facts from assumptions.
Be honest about trade-offs.
Do not hide downsides.
Do not recommend the most complex solution by default.
Prefer the simplest production-safe architecture.

The ADR should be useful for:
- human engineers;
- AI coding agents;
- future maintainers;
- PR reviewers;
- onboarding developers.

The ADR should help prevent future architecture drift.
