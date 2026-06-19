# iOS Analytics And Telemetry Taxonomy

## Purpose
Keep analytics useful, privacy-safe, and stable as the product grows.

## Required Rules
- Events must have owner, purpose, schema, privacy classification, and retention expectation.
- Track user intent and outcome, not noisy implementation details.
- Avoid high-cardinality unbounded properties.
- Do not log tokens, secrets, raw PII, private file paths, or full request/response bodies.
- Performance and error signals must connect to product-critical journeys.
- Analytics changes that affect business reporting require review.

## Review Checklist
- What decision will this event support?
- Is the event emitted once per user action?
- Can it be joined to outcome/failure?
- Are properties bounded and privacy-safe?
- Does it work offline and flush safely?
