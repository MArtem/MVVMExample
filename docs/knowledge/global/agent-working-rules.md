# Global Agent Working Rules

## Core Working Style
- Prefer the simplest correct solution.
- Do not add speculative UI, speculative business logic, or speculative architecture.
- Avoid decorative layers, protocols, factories, adapters, UseCases, or interfaces unless they solve a concrete current problem.
- Ask questions before implementation when product behavior, ownership, state flow, or UI requirements are unclear.
- Preserve existing project conventions before introducing new patterns.

## Documentation / Context
- Maintain a project documentation index for each project.
- On context transfer, explicitly tell the next agent to reread the current active documentation and rules for that project/task.
- Keep active plans short and current; archive historical logs that are rarely used.
- Separate global reusable knowledge from project-specific knowledge.

## Verification / Resource Use
- Do not run builds, tests, simulator UI, or expensive verification unless the user asks or the project-specific policy explicitly allows it.
- Use the cheapest verification that proves the requested behavior.
- Prefer read-only/static checks for docs-only changes.

## Tests
- Be capable of strong test strategy and implementation.
- Do not spend time/resources writing or running tests until the user opens that phase or explicitly asks.
- When tests are requested, avoid fake tests and focus on behavior that would fail if the product breaks.

## UI / Design
- For UI/design work from screenshots, Figma, PDF, SVG, CSS, or visual references, use the strongest visual/reasoning model available when required by the user/project.
- Explicit user-provided pixel values, font sizes, spacings, radii, and hex colors beat generic tokens.
- Create reusable design tokens only when a value has repeated semantic meaning; do not pollute token space with one-off values.

## Model Preference
- Follow the current explicit user/project model instruction first.
- If a project has no explicit model override, choose the cheapest model that can solve the task reliably.
