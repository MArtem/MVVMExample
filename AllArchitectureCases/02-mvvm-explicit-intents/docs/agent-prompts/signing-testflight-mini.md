# Mini Prompt: Signing / TestFlight Errors

Source: `Мини-prompt для signing:TestFlight errors.rtf`

---

Analyze this iOS signing / archive / TestFlight upload error.

Check:
- bundle identifier;
- team ID;
- provisioning profile;
- certificate;
- entitlements;
- App Groups / Push / Associated Domains;
- automatic vs manual signing;
- CI keychain;
- Fastlane match;
- App Store Connect API key;
- exportOptions.plist;
- build/version number;
- privacy manifest/export compliance;
- transporter error.

Return:
1. Root cause
2. Evidence from log
3. Minimal fix
4. CI/Fastlane/Xcode config changes
5. Verification steps
6. Prevention checklist
