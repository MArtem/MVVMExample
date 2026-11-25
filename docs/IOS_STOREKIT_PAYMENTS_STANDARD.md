# iOS StoreKit And Payments Standard

## Purpose
Provide generic production rules for subscriptions, purchases, paywalls, and entitlement gating when an app uses StoreKit or payments.

## Required Rules
- Product catalog, entitlement state, restore flow, pending purchases, refunds, grace period, billing retry, and family sharing behavior must be explicit.
- Never gate critical state solely on local UI flags.
- Receipt/transaction validation, server sync, and offline entitlement behavior must be defined before release.
- Paywall copy and pricing must follow App Store rules and localization requirements.
- Purchase flows require accessibility and failure-state review.

## Review Checklist
- What happens if purchase succeeds but app is killed before entitlement update?
- What happens offline?
- Is restore available and discoverable?
- Are subscription states represented correctly?
- Are analytics privacy-safe and useful?

## Delivery And Recovery Procedure
For each product type, trace verified transaction → owned content/entitlement delivery →
durable reconciliation → finish. A pending result is not access; an unverified transaction
is not a successful validation. Repeated transaction delivery after relaunch must not duplicate
consumable credits. Current entitlements and unfinished transactions answer different questions.

Use `knowledge/global/ios/APP_STORE_PRIVACY_AND_COMPLIANCE.md`, StoreKit and Transaction Delivery
And Recovery Example, when the transaction lifecycle or compliance boundary is in scope.
That reference supplies the explanation and interrupted-delivery scenario. The selected
`ios-storekit-payments` route lists it as an optional candidate, not an automatic full read.
Select conceptual/static review or currently permitted StoreKit evidence for the claim;
this procedure grants no purchases, sandbox session, server or release action.
