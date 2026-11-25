# iOS Security And Privacy Gate

## Purpose
Mandatory review gate for secure storage, privacy, logging, permissions, and sensitive data handling in iOS apps.

For identity, OAuth/OIDC/PKCE, passkeys, Sign in with Apple, sessions, LocalAuthentication, cryptography, App Attest, and authorization design, also load `./docs/knowledge/global/ios/IDENTITY_AUTHENTICATION_AND_APP_SECURITY.md`.

Record each applicable data, permission, SDK and lifecycle claim in
`./docs/IOS_RELEASE_PRIVACY_PERFORMANCE_MATRIX.md`. The matrix is project-owned; this gate remains
the normative security/privacy review for the row.

## Required Checks
### Secrets And Tokens
- Apply `./docs/SECRET_HANDLING_AND_SECURITY_INTAKE_STANDARD.md` before creating, importing, auditing, or remediating a project that may contain local secrets.
- Store tokens/secrets in Keychain or approved secure storage.
- Never store tokens in plain UserDefaults, logs, analytics, screenshots, or crash metadata.
- Define token refresh, logout, revocation, and expired-session behavior.
- Do not ship permanent server secrets, private keys, service credentials, or third-party AI/API provider keys inside the app bundle. Route secret-bearing provider access through an authenticated backend unless the key is explicitly public and non-sensitive.
- Token refresh must be single-flight or otherwise deduplicated so concurrent 401 responses do not trigger parallel refresh storms or token races.
- Separate remote identity/authentication, local user-presence checks, authorization, and fraud signals.
- Do not treat client logic as an authoritative security boundary.

### Files And App Groups
- Review file protection class for persisted user data.
- Exclude caches/regenerable media from backups.
- App Group data must have clear ownership, cleanup, and access policy.
- Do not persist temporary picker/provider URLs as durable data.

### Privacy Manifests And Permissions

Audit declared tracking domains against actual app/SDK destinations and the current applicable Apple
tracking/privacy contract; a domain list or a valid manifest alone does not establish compliant
tracking behavior. Unknown endpoint purpose or classification remains unverified rather than
inferred from a hostname. This review does not authorize network access, tracking or consent
changes.

- Info.plist permission strings must match actual usage.
- Privacy manifests must reflect SDK/API usage.
- Permission denial paths must be user-friendly.
- Reconcile manifest declarations, required-reason API use, third-party SDK behavior and actual
  runtime data flow; a structurally valid manifest alone is not a compliance verdict.

### Logging And Analytics
- Redact PII, tokens, private URLs, payload bodies, auth headers, and user-generated private content.
- Production logs must be actionable and bounded.
- Analytics events must avoid sensitive values.

### External Input
- Validate external URLs, shared files, deeplinks, universal links, pasteboard, documents, and imported media.
- Do not trust extension/app handoff payloads without validation.

### Transport And Device Integrity
- Do not disable ATS globally with arbitrary loads.
- Certificate pinning is not a default checkbox. If used, it requires primary and backup pins, rotation plan, outage strategy, certificate-expiry monitoring, and test evidence for the next chain before rollout.
- App Attest and DeviceCheck are server-verified risk signals, not client-only authorization.
- Jailbreak/root detection must never be the only security boundary; treat it as one risk signal with false-positive and bypass assumptions documented.
- Biometric unlock protects local access only; it does not replace server authorization for privileged backend actions.

### Data Lifecycle
- Define logout cleanup.
- Define account deletion/local data deletion behavior where relevant.
- Define retention for caches, media, drafts, and diagnostics.
- Record owner, destination, retention, deletion/export path, permission state and evidence for each
  sensitive data flow; unknown lifecycle values remain unknown until the app supplies evidence.

## Blocking Findings
Treat the following as potential blocking findings. Assign P0–P3 from actual
exposure and impact under the shared audit matrix; do not assign P0/P1 from
the category name alone. Keep confidence separate from severity, and do not
clear an unknown sensitive-data boundary as a normal PASS:
- secret/PII logging
- insecure token persistence
- unintended backup of sensitive data
- unvalidated external file/URL execution path
- missing permission/privacy explanation for shipped capability
- secret-bearing cloud/AI/API provider access directly from the app with an embedded permanent secret
- global ATS disablement without a documented, temporary, app-specific exception
- real secrets present in tracked files, normal AI-readable workspace files, or app bundle resources
