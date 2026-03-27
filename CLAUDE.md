# Celestia AI Astrology — Project Rules & Build Log

See also: `C:\iosdesigner\CLAUDE.md` for shared iOS project rules.

## Project Info
- **Bundle ID:** com.pcchiu2023.celestia
- **App Name:** Celestia AI Astrology
- **App ID:** 6761231203
- **Current Version:** 1.0.0
- **Info.plist:** CFBundleVersion controls build number, CFBundleShortVersionString controls version

## Critical Files — Handle With Care

| File | Risk | Notes |
|------|------|-------|
| `Celestia/AI/CelestiaBrain.swift` | LLM params (temp, tokens, topP) | temp 0.85, maxTokens 300, topP 0.92 |
| `Celestia/Astrology/ChartEngine.swift` | SwissEphemeris C library wrapper | Complex math, test carefully |
| `Celestia/AI/ReadingParser.swift` | 3-tier JSON parsing | Fragile if LLM output format changes |
| `Celestia/Astrology/AstrologyTypes.swift` | Core types used everywhere | Changes cascade to all views |

## Build Log

### Build 1 (v1.0.0) — 2026-03-27
**Changes:** Enhanced CelestiaTheme with gradients, scalable fonts, layout constants
**Working:**
- Full compilation (archive succeeded)
- Upload to App Store Connect (processing for TestFlight)
- All 41 Swift files compile cleanly
- 5-tab navigation: Today, Tarot, Chat, Match, Profile
- Onboarding flow (language picker + birth data)
- StoreKit 2 subscriptions + token economy
- 6-language localization
- Content filtering
- Star field animation background
**Known Limitations:**
- AI model (Gemma 3n E4B) not bundled yet — app will show "Model not found" for AI features
- No App Store metadata yet (screenshots, description, keywords)
- Export compliance answer not submitted
**Status:** Uploaded to TestFlight, processing

## CelestiaBrain Safe Parameters

DO NOT change these without a dedicated build to test:
```
temperature: 0.85
maxTokens: 300
topP: 0.92
repetitionPenalty: 1.15
Model: gemma-3n-E4B-it-4bit
```

## App Store Versions

| Version | Build | Status |
|---------|-------|--------|
| v1.0.0 | 1 | Processing for TestFlight (2026-03-27) |
