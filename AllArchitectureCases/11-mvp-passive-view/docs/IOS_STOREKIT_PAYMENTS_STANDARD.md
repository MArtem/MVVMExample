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
