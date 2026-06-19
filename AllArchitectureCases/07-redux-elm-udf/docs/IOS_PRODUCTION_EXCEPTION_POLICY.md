# iOS Production Exception Policy

## Purpose
Prevent temporary compromises from becoming invisible permanent architecture.

## Exception Record Required Fields
- Exception title
- Affected area/files
- Rule being bypassed
- Reason
- User/product impact
- Risk level
- Owner
- Expiry or revisit condition
- Mitigation
- Verification that the exception is contained

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
