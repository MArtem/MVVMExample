# Localization And Internationalization Standard

## Purpose
Rules for production localization and internationalization.

## Required Checks
- All user-facing strings use localization resources.
- Pluralization is handled with localized rules.
- Dates, times, numbers, currencies, and measurements use locale-aware formatting.
- Layout handles text expansion.
- RTL is considered if supported markets require it.
- Accessibility labels are localized.
- Screenshots/App Store text are localized when needed.

## Forbidden By Default
- Hard-coded user-facing strings in production UI.
- Locale-sensitive formatting with string concatenation.
- Layout that assumes English text length.
