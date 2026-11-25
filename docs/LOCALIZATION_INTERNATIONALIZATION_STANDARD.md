# Localization And Internationalization Standard

## Purpose
Rules for production localization and internationalization.

## Required Checks
- All user-facing strings use localization resources.
- Pluralization is handled with localized rules.
- Dates, times, numbers, currencies, and measurements use locale-aware formatting.
- Define relevant Locale, Calendar and TimeZone inputs for date/number formatting; use supported
  FormatStyle/Foundation formatting rather than concatenation. Display formatting is not a wire-format contract.
- Layout handles text expansion.
- RTL is considered if supported markets require it.
- Accessibility labels are localized.
- Screenshots/App Store text are localized when needed.

## Forbidden By Default
- Hard-coded user-facing strings in production UI.
- Locale-sensitive formatting with string concatenation.
- Layout that assumes English text length.

## Mental Model And Failure Example
A localization key identifies meaning; its translation is not an English sentence with
substituted suffixes. String Catalogs can track localizable API inputs, translator context,
plural forms and selected variants. Retain an existing supported strings/stringsdict workflow
when the project's toolchain or resource contract requires it; this guidance does not authorize
migration or a build to populate a catalog.

For example, a count changes from one to two while the interface uses another locale. The
localized plural category and formatted number must come from that locale's rules, not from
`count == 1` plus an English suffix. Exercise zero/one/other relevant categories, long text,
RTL and known accessibility consumers within current permissions. A catalog's translated
status does not prove correct grammar, bundle lookup or layout at runtime.

Primary theory: [Localizing and varying text with a string catalog](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog).
Use the shared interaction reference at `knowledge/global/ios/SWIFTUI_UIKIT_AND_ADAPTIVE_IPAD_UI.md`
for layout, semantics and evidence boundaries when those concerns are selected.
