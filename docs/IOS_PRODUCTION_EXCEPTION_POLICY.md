# iOS Production Exception Policy

<!-- Rule ID: QC.EXCEPTION.CONTRACT v1.0 -->

## Purpose
Prevent temporary compromises from becoming invisible permanent architecture.

## Exception Record Required Fields
- Exception ID and status (`draft`, `proposed`, `approved`, `expired`, or `rejected`)
- Exception title
- Repository/app and exact affected scope
- Rule ID and rule version being bypassed
- Affected area/files
- Rule being bypassed
- Reason
- User/product impact
- Risk level
- Evidence and evidence status
- Owner
- Approver and approved-at timestamp
- Expiry or revisit condition
- Mitigation
- Revalidation trigger
- Rollback
- Verification that the exception is contained

A draft or proposed record is not approval and cannot authorize a bypass. Approval is scoped to
the named repository/app and rule version; it does not change the reusable default or authorize a
different project. Expiry, scope drift, changed toolchain, changed data flow, or a new relevant
finding makes the exception stale and requires revalidation. HIGH/CRITICAL exceptions and any
weakening of a universal floor require explicit user approval.

## Allowed Exceptions
Allowed only when:
- the tradeoff is explicit;
- user/product impact is understood;
- rollback/mitigation exists;
- owner and expiry are recorded.

## Forbidden Exceptions
- Secret leakage.
- Known data loss risk without owner-approved mitigation.
- Silent production fallback to demo/stub/local systems.
- Unbounded main-thread work in critical flows.
- Shipping inaccessible critical user flows.
