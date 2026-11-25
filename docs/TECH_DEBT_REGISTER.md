# Tech Debt Register

## Purpose
Tracks intentional technical debt separately from unknown defects.

## Entry Template
- ID
- Date
- Debt
- Area
- Why accepted
- Impact
- Owner
- Cleanup trigger
- Target cleanup phase
- Status

## Rule
Prioritize debt by concrete risk, change frequency and expected outcome. Name a bounded payoff
and cleanup trigger; debt accounting does not authorize an automatic rewrite.

Do not use “tech debt” to hide correctness, data loss, security, or severe performance problems.
