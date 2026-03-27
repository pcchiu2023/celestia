# Celestia v2.0 — AI Astrology Redesign

**Date:** 2026-03-27
**Status:** Approved (brainstorming complete)
**Predecessor:** `2026-03-26-celestia-design.md` (v1.0 — shipped to TestFlight)
**Competitive Analysis:** `2026-03-27-competitive-analysis.md`

---

## Executive Summary

Celestia v2.0 upgrades the on-device AI astrology app with an **Accuracy Gate Architecture**, a new **Qwen3.5-4B model** (replacing Gemma 3n E4B), a **Stardust token economy** with referral system, and expansion to **8 languages** including Hindi for the Indian Vedic astrology market.

**Core thesis:** Competitors (Co-Star, Sanctuary, Nebula) use cloud AI with generic outputs. Celestia uses on-device AI grounded in real astronomical math (SwissEphemeris) with curated astrology knowledge, producing readings that are both accurate and private.

---

## Key Decisions (Locked)

| Decision | v1.0 | v2.0 | Rationale |
|----------|------|------|-----------|
| AI Model | Gemma 3n E4B (restricted license) | **Qwen3.5-4B** (Apache 2.0) | Irrevocable license, better creative writing, deeper cultural knowledge, 201 languages |
| Model delivery | Not bundled | **Bundled in-app (~2.5GB)** | Users perceive larger apps as more substantial; works offline immediately |
| Accuracy | AI generates freely | **Accuracy Gate** (knowledge injection + validation) | Prevents hallucination; grounds readings in real astrology |
| Monetization | Star Pass ($6.99/wk) + tokens | **Stardust economy** + Star Pass ($2.99/mo) | Simpler, fairer, competitive pricing |
| Languages | 6 (EN, ES, PT, JA, KO, FR) | **8** (+Hindi, +German) | Hindi = untapped Vedic market; German = #1 EU esoteric market |
| UX pattern | Streaming text | **Batch generation + reveal animation** | Builds anticipation; hides slower Qwen inference behind mystical UX |
| Writing/copy | Claude | **Gemini AI** | Per user preference — Gemini for all marketing/user-facing text |
| Art/graphics | None | **Ideogram AI** | Per user preference — Ideogram for all visual assets |

---

## 1. Accuracy Gate Architecture

### Problem
On-device AI models hallucinate astrology facts. Users who know astrology will catch errors and lose trust. Competitors with human astrologers have an accuracy advantage.

### Solution: Structured Knowledge Injection + Post-Validation

The AI never invents astrology facts. Instead:

1. **SwissEphemeris computes** exact planetary positions, houses, aspects, transits (arc-second accuracy)
2. **Knowledge Engine** maps computed data to curated interpretation snippets
3. **AI writes prose** grounded in the injected knowledge — creative writing only, no fact invention
4. **Validator** checks the AI output against the computed data, catching any hallucinated positions or aspects

### Architecture Diagram

```
User Request (e.g., "Daily Horoscope")
        │
        ▼
┌─────────────────────┐
│   SwissEphemeris     │ ← Computes real planetary positions
│   ChartEngine        │   (Sun in Aries 15°, Moon in Cancer 22°, etc.)
└─────────┬───────────┘
          │ Structured chart data (JSON)
          ▼
┌─────────────────────┐
│   Knowledge Engine   │ ← Maps positions to curated snippets
│   (New component)    │   ("Sun in Aries: bold, pioneering energy...")
└─────────┬───────────┘
          │ Chart data + relevant knowledge snippets
          ▼
┌─────────────────────┐
│   Prompt Builder     │ ← Constructs grounded prompt:
│   (Enhanced)         │   "Given these FACTS: [chart data + snippets]
│                      │    Write a reading that interprets these energies.
│                      │    Do NOT invent positions or aspects."
└─────────┬───────────┘
          │ Complete prompt
          ▼
┌─────────────────────┐
│   Qwen3.5-4B         │ ← Generates interpretive prose only
│   (CelestiaBrain)   │   Creative writing grounded in provided facts
└─────────┬───────────┘
          │ Raw AI output
          ▼
┌─────────────────────┐
│   Reading Validator  │ ← Checks output against chart data:
│   (New component)    │   - Are mentioned signs/planets correct?
│                      │   - Are aspect descriptions accurate?
│                      │   - Any hallucinated positions?
│                      │   → Pass: deliver to user
│                      │   → Fail: regenerate or use knowledge-only fallback
└─────────┬───────────┘
          │ Validated reading
          ▼
      User sees reading
```

### Knowledge Engine Details

**Curated knowledge base** (~100-150 snippets per language):

| Category | Examples | Count |
|----------|---------|-------|
| Planet-in-Sign | "Mars in Scorpio: intense drive, strategic, passionate" | 120 (12 planets × 12 signs, minus outliers) |
| Aspect meanings | "Sun conjunct Moon: unified identity, inner harmony" | ~30 major aspects |
| House meanings | "7th house: partnerships, marriage, open enemies" | 12 |
| Transit interpretations | "Saturn return: restructuring, maturity, life review" | ~20 major transits |
| Vedic basics (Hindi) | Nakshatra meanings, Dasha periods | ~27 nakshatras + major dashas |

**Storage:** Bundled JSON files per language. No server needed.

**Content creation:** Use **Gemini AI** to draft all knowledge snippets, then have them reviewed for astrological accuracy. Snippets are factual reference material, not creative writing.

### Validator Rules

The `ReadingValidator` checks AI output against the computed chart:

1. **Sign accuracy** — If chart says "Sun in Aries," reading must not say "Sun in Taurus"
2. **Aspect accuracy** — If chart has "Mars square Saturn," reading must not reference "Mars trine Saturn"
3. **Planet presence** — Reading should not reference planets/aspects not in the chart data
4. **Degree claims** — If reading mentions specific degrees, they must match computed values (±1°)
5. **Retrograde accuracy** — If Mercury is retrograde, reading must not say "Mercury direct" and vice versa

**On validation failure:**
- First attempt: Regenerate with stricter prompt ("IMPORTANT: Only reference these exact positions: [list]")
- Second failure: Use knowledge-only fallback (curated snippet text without AI prose)
- Log failure for analysis

---

## 2. AI Model: Qwen3.5-4B

### Why Qwen3.5-4B over Gemma 3n E4B

| Factor | Gemma 3n E4B | Qwen3.5-4B |
|--------|-------------|-------------|
| License | Restricted (Google can revoke) | **Apache 2.0 (irrevocable)** |
| Creative writing | Good | **Better** (deeper cultural knowledge) |
| Languages | 6 native | **201 native** (critical for Hindi, German) |
| Speed (iPhone 15 Pro) | 60-70 tok/s | 5-12 tok/s |
| Model size (4-bit) | ~2GB | ~2.5GB |
| Astrology knowledge | Basic Western | Western + Vedic + Chinese cultural context |

### Speed Mitigation

Qwen is slower, but this is manageable:

1. **Background pre-generation** — Daily horoscope generates on app launch, cached for the day
2. **Batch reveal UX** — All readings use "consulting the cosmos..." loading animation → full reveal
3. **Cache aggressively** — Same reading type + same chart data = cached result (daily, weekly)
4. **Progressive enhancement** — iPhone 16/17 will be faster; speed improves every generation
5. **300 tokens at 5 tok/s = 60 seconds worst case** — with a beautiful animation, acceptable

### Integration Changes

**Files to modify:**
- `CelestiaBrain.swift` — Replace Gemma model ID with Qwen, adjust parameters
- `project.yml` — Update MLX dependency if needed for Qwen support
- Bundle Qwen3.5-4B-4bit model files in app resources

**New CelestiaBrain parameters (to be tested):**
```
model: Qwen3.5-4B-4bit (exact MLX model ID TBD)
temperature: 0.85 (keep same, test and adjust)
maxTokens: 300 (keep same)
topP: 0.92 (keep same)
repetitionPenalty: 1.15 (keep same)
```

**IMPORTANT:** Parameters must be tested in a dedicated build. Do not change multiple things at once. See CLAUDE.md one-concern-per-build rule.

---

## 3. Stardust Token Economy

### Currency: Stardust (✦)

Replaces the v1.0 token system with a more engaging, themed economy.

### Free Tier (Always Available)

| Feature | Access |
|---------|--------|
| Daily horoscope (summary) | Always free |
| 1 chat message per day | Always free |
| Basic birth chart | Always free |
| Profile + settings | Always free |

### Stardust Costs

| Feature | Cost | Rationale |
|---------|------|-----------|
| Chat message | 1 ✦ | Low friction, encourages engagement |
| Daily detailed reading | 2 ✦ | Premium version of free summary |
| Tarot — Single card | 2 ✦ | Quick answer |
| Tarot — 3-card spread | 5 ✦ | Medium depth |
| Tarot — Celtic Cross | 10 ✦ | Premium experience |
| Compatibility reading | 5 ✦ | High perceived value |
| Monthly forecast | 8 ✦ | Long-form content |
| Weekly deep reading | 3 ✦ | Regular premium content |

### Free Earning

| Action | Reward | Frequency |
|--------|--------|-----------|
| Open app daily | +2 ✦ | Daily |
| 7-day streak bonus | +5 ✦ | Weekly |
| Complete birth profile | +10 ✦ | One-time |
| Referral (both sides) | +15 ✦ | Up to 5/month |

**Weekly free earning (active user):** ~19 ✦/week (enough for a few chats + a tarot reading, not unlimited)

### Paid Options

| Package | Price | Stardust | Per-✦ Cost | Psychology |
|---------|-------|----------|-----------|------------|
| Starter | $1.99 | 30 ✦ | $0.066 | Impulse buy, "just try it" |
| Popular | $4.99 | 100 ✦ | $0.050 | Best everyday value |
| Cosmic Bundle | $9.99 | 250 ✦ | $0.040 | Power users, bulk savings |

### Star Pass Subscription ($2.99/mo)

The subscription is the primary revenue driver:

| Perk | Description |
|------|-------------|
| 80 ✦ per month | Auto-credited on renewal |
| Unlimited chat | Chat messages cost 0 ✦ |
| Detailed daily horoscope | Free users get summary only |
| Priority generation | Readings queued first (UX perception) |
| Exclusive themes | Subscriber-only birth chart visual themes |
| No future ads | Protected from any future ad implementation |

**Annual option:** $19.99/yr (saves 44% vs monthly — $1.67/mo effective)

### Conversion Funnel

```
Day 1:  Free daily horoscope + 10✦ welcome bonus → tries chat + tarot
Day 3:  Running low on stardust → "Earn more by opening daily!"
Day 7:  Streak bonus → but wants Celtic Cross → sees $1.99 starter
Day 14: Bought starter, used it up → sees Star Pass value prop
Day 30: Subscriber → habit locked in
```

### StoreKit 2 Product IDs

| Product ID | Type | Price |
|-----------|------|-------|
| `com.pcchiu2023.celestia.starpass.monthly` | Auto-renewable | $2.99/mo |
| `com.pcchiu2023.celestia.starpass.annual` | Auto-renewable | $19.99/yr |
| `com.pcchiu2023.celestia.stardust.starter` | Consumable | $1.99 |
| `com.pcchiu2023.celestia.stardust.popular` | Consumable | $4.99 |
| `com.pcchiu2023.celestia.stardust.cosmic` | Consumable | $9.99 |

---

## 4. Referral System

### Core Mechanic

1. User shares a **personal referral link** (deep link with referral code)
2. Friend downloads → completes birth profile (activation requirement)
3. **Both users receive 15 ✦**
4. Cap: **5 successful referrals per month** (75 ✦ max)

### Natural Trigger Points

Referral prompts appear at moments of delight, not randomly:

| Trigger | Message (Gemini AI to write final copy) |
|---------|----------------------------------------|
| After a resonant reading | "Share your cosmic connection — invite a friend, both get 15 ✦" |
| Compatibility check | "Want [name] to see their side? Invite them to Celestia" |
| 7-day streak | "You're cosmically aligned! Share the stars with a friend" |
| After first purchase | "Unlock more stardust — invite a friend" |

### The Compatibility Hook (Viral Mechanic)

This is the key viral loop:

1. User enters friend's name + birthday for compatibility reading
2. Reading concludes with: "Want [friend] to see their perspective? Invite them!"
3. Friend receives personalized link: "[Your name] checked your cosmic compatibility"
4. Friend downloads → sees the compatibility reading waiting for them → hooked
5. Both earn 15 ✦

**Implementation:** Deep link with referral code + compatibility reading ID. On first launch, the referred user sees the compatibility reading after completing onboarding.

### Technical Requirements

- **Referral code:** 8-character alphanumeric, stored in UserProfile
- **Deep link:** `celestia://refer/{code}` + Universal Link fallback
- **Tracking:** SwiftData model for referral events (code, referred user, date, rewarded)
- **Fraud prevention:** Require birth profile completion before rewarding; device fingerprint check

---

## 5. Languages: 8 at Launch

### Language List

| Language | Code | Market | Astrology System | New in v2.0? |
|----------|------|--------|-----------------|--------------|
| English | en | US, UK, Canada, Australia, global | Western | No |
| Spanish | es | Mexico, Spain, Latin America, US Hispanic | Western | No |
| Portuguese | pt-BR | Brazil | Western | No |
| Japanese | ja | Japan | Western + Uranai | No |
| Korean | ko | South Korea | Western + Saju | No |
| French | fr | France, Belgium, Quebec, West Africa | Western | No |
| **Hindi** | **hi** | **India (600M speakers)** | **Western + Vedic basics** | **Yes** |
| **German** | **de** | **Germany, Austria, Switzerland** | **Western** | **Yes** |

### Localization Strategy

| Component | Approach |
|-----------|----------|
| UI strings (~300 per language) | Qwen drafts translations → human review |
| AI-generated readings | Qwen generates natively in target language (zero effort) |
| Knowledge snippets (~150 per language) | **Gemini AI** drafts → astrological accuracy review |
| Vedic knowledge (Hindi only) | **Gemini AI** drafts Nakshatra/Dasha descriptions → expert review |
| App Store listings (8 languages) | **Gemini AI** writes all marketing copy |
| Astrology terms | Mostly universal (Aries, etc.) — localize only where conventions differ |

### Hindi / Vedic Astrology Basics

For v2.0, include basic Vedic astrology alongside Western:

- **Nakshatras** (27 lunar mansions) — compute from Moon position
- **Basic Dasha period** — current planetary period
- **Vedic-style reading option** — user chooses Western or Vedic in settings
- SwissEphemeris supports both tropical (Western) and sidereal (Vedic) zodiac calculations

This is a **differentiator** — no major Western competitor offers Vedic readings. The Indian market (600M+ Hindi speakers) has poor-UX competitors (AstroSage, Kundli) that a premium app can disrupt.

---

## 6. UX: Batch Generation + Reveal Animation

### The Pattern

All AI-generated content uses this flow:

1. User taps "Get Reading" (or similar action)
2. **Mystical loading animation** plays (15-60 seconds depending on content length)
3. Full reading **reveals at once** with entrance animation

### Loading Animations (Ideogram AI to design, developer to implement)

| Reading Type | Animation Concept |
|-------------|-------------------|
| Daily horoscope | Stars slowly aligning into constellation pattern |
| Tarot | Cards shuffling, floating, settling face-down |
| Compatibility | Two star charts orbiting, then merging |
| Chat response | Cosmic energy swirling in a crystal ball |
| Monthly forecast | Moon phases cycling through the month |

### Implementation

- Use SwiftUI animations (no external animation library needed)
- Loading state managed in each view's ViewModel
- `CelestiaBrain.generateReading()` returns a complete result (no streaming)
- Cache generated readings in SwiftData (keyed by reading type + date + chart hash)

### Pre-generation Strategy

| Content | When Generated | Cache Duration |
|---------|---------------|----------------|
| Daily horoscope | App launch (background) | 24 hours |
| Weekly reading | Monday app launch | 7 days |
| Monthly forecast | 1st of month app launch | 30 days |
| Tarot | On demand | Not cached (unique each time) |
| Chat | On demand | Not cached |
| Compatibility | On demand | Cached per pair indefinitely |

---

## 7. Feature Changes from v1.0

### Modified Features

| Feature | v1.0 | v2.0 |
|---------|------|------|
| Daily horoscope | Single version | **Two tiers:** free summary (3-4 sentences) + detailed (Star Pass, full paragraph with transit analysis) |
| Chat | 5 free/day, unlimited with sub | **1 free/day**, additional cost 1 ✦ each, **unlimited with Star Pass** |
| Tarot | 1 free/week, tokens for more | **Stardust costs** (2/5/10 ✦ by spread type) |
| Compatibility | 3 tokens | **5 ✦** + referral hook |
| Subscription | $6.99/wk, $19.99/mo, $99.99/yr | **$2.99/mo or $19.99/yr** |
| Token system | Generic tokens ($1.99/5, $9.99/30) | **Stardust** with earning mechanics + 3 purchase tiers |

### New Features

| Feature | Description |
|---------|-------------|
| **Knowledge Engine** | Curated astrology knowledge base for accuracy gating |
| **Reading Validator** | Post-generation accuracy checker |
| **Stardust economy** | Earn + spend virtual currency |
| **Daily login reward** | +2 ✦ per day, streak bonuses |
| **Referral system** | Invite friends → both earn 15 ✦ |
| **Vedic mode (Hindi)** | Basic Nakshatra + Dasha readings |
| **Batch reveal UX** | Mystical loading → full reveal (replaces streaming) |
| **Background pre-gen** | Daily/weekly readings generated on app launch |

### Removed/Unchanged

| Feature | Status |
|---------|--------|
| Star field background | **Keep** — signature visual |
| Onboarding flow | **Keep** — language picker + birth data |
| 5-tab navigation | **Keep** — Today, Tarot, Chat, Compatibility, Profile |
| SwissEphemeris engine | **Keep** — foundation of accuracy |
| Content filtering | **Keep** — child safety |
| Transit notifications | **Keep** — engagement driver |
| Journal/reading history | **Keep** — user value |

---

## 8. File Architecture Changes

### New Files

| File | Purpose |
|------|---------|
| `Celestia/AI/KnowledgeEngine.swift` | Loads + queries curated astrology knowledge base |
| `Celestia/AI/ReadingValidator.swift` | Post-generation accuracy validation |
| `Celestia/AI/PromptBuilder.swift` | Constructs grounded prompts with knowledge injection |
| `Celestia/Models/StardustBalance.swift` | Replaces TokenBalance — Stardust earning + spending |
| `Celestia/Models/ReferralEvent.swift` | Tracks referral invites + rewards |
| `Celestia/Models/DailyStreak.swift` | Tracks consecutive login days + bonus rewards |
| `Celestia/Views/Components/CosmicLoadingView.swift` | Mystical loading animation (used across all reading views) |
| `Celestia/Views/Components/ReadingRevealView.swift` | Full reading reveal with entrance animation |
| `Celestia/Views/Referral/ReferralView.swift` | Share referral link + see referral history |
| `Celestia/Shop/StardustManager.swift` | Replaces TokenManager — earn/spend/purchase Stardust |
| `Celestia/Resources/Knowledge/` | Directory of curated knowledge JSON files per language |
| `Celestia/Astrology/VedicEngine.swift` | Nakshatra + Dasha calculation (Hindi/Vedic mode) |

### Modified Files

| File | Changes |
|------|---------|
| `CelestiaBrain.swift` | Swap Gemma → Qwen model, integrate PromptBuilder |
| `ReadingGenerator.swift` | Use KnowledgeEngine + ReadingValidator pipeline |
| `ReadingParser.swift` | Adjust for any Qwen output format differences |
| `SubscriptionManager.swift` | New product IDs, $2.99/mo + $19.99/yr |
| `ShopCatalog.swift` | New Stardust product definitions |
| `PaywallView.swift` | Stardust-aware paywall with earning explanation |
| `TodayView.swift` | Two-tier horoscope (summary vs detailed) |
| `ChatView.swift` | Stardust cost per message, Star Pass unlimited |
| `TarotView.swift` | Stardust costs by spread type |
| `CompatibilityView.swift` | Referral hook after reading |
| `ContentView.swift` | Daily login reward trigger |
| `UserProfile.swift` | Add referral code, preferred astrology system (Western/Vedic) |
| `Localizable.xcstrings` | Add Hindi (hi) + German (de) |
| `Products.storekit` | New product IDs |
| `project.yml` | Update model dependency, add new files |

### Deleted Files

| File | Reason |
|------|--------|
| `TokenBalance.swift` | Replaced by `StardustBalance.swift` |
| `TokenManager.swift` | Replaced by `StardustManager.swift` |

---

## 9. Content Creation Pipeline

All user-facing text and visual assets are created with external AI tools:

### Gemini AI (Writing)

| Content | Details |
|---------|---------|
| Knowledge base snippets | ~150 per language × 8 languages = ~1,200 snippets |
| App Store listings | 8 languages: title, subtitle, description, keywords, what's new |
| Onboarding text | Welcome messages, tutorial copy |
| Paywall copy | Star Pass value proposition, Stardust explanation |
| Referral messages | Trigger-specific invite text |
| Loading screen messages | "Consulting the cosmos...", "Reading the stars...", etc. |
| Error messages | Friendly, on-brand error copy |

### Ideogram AI (Graphics)

| Asset | Details |
|-------|---------|
| Loading animations | Concept art for developer to implement in SwiftUI |
| App icon (if updated) | Cosmic theme variants |
| Tarot card backs | Mystical card back design |
| Stardust icon | ✦ symbol variations for UI |
| Onboarding illustrations | Cosmic-themed step illustrations |
| App Store screenshots | 8 languages × screenshot frames |
| Referral share card | Social-media-optimized share image |

---

## 10. Testing Strategy

### Accuracy Gate Testing

| Test | Method |
|------|--------|
| Knowledge Engine loads all snippets | Unit test: load each language's JSON, verify count + structure |
| Validator catches wrong sign | Unit test: feed reading with wrong Sun sign, assert rejection |
| Validator catches wrong aspect | Unit test: feed reading with invented aspect, assert rejection |
| Validator passes correct reading | Unit test: feed accurate reading, assert pass |
| End-to-end reading accuracy | Manual: generate 20 readings, compare against known chart data |

### Stardust Economy Testing

| Test | Method |
|------|--------|
| Daily reward credits correctly | Unit test: simulate daily open, verify +2 ✦ |
| Streak bonus at 7 days | Unit test: simulate 7 consecutive days, verify +5 ✦ bonus |
| Purchase credits correctly | StoreKit testing: buy each pack, verify balance |
| Spending deducts correctly | Unit test: spend on each feature, verify deduction |
| Star Pass unlimited chat | Unit test: subscriber sends chat, verify 0 ✦ cost |
| Insufficient stardust blocks action | Unit test: try action with 0 balance, verify paywall shown |

### Model Testing

| Test | Method |
|------|--------|
| Qwen loads on iPhone 15 Pro | Device test: app launch, model loads without crash |
| Qwen generates in all 8 languages | Device test: generate reading in each language |
| Generation completes within 90s | Device test: time 300-token generation |
| Memory usage under 6GB | Device test: monitor RAM during generation |

---

## 11. Risk Register

| Risk | Impact | Mitigation |
|------|--------|------------|
| Qwen3.5-4B not available in MLX format | Blocks v2.0 | Check MLX model hub first; fallback to GGUF conversion |
| Qwen too slow on iPhone 15 Pro (>90s) | Poor UX | Reduce maxTokens to 200; use summary-only mode; fall back to Gemma |
| 2.5GB app rejected by App Store | Can't ship | Apple allows up to 4GB; 2.5GB is well within limits |
| Knowledge base has astrology errors | Trust loss | Have astrology-knowledgeable reviewer check snippets |
| Referral system gamed | Revenue loss | Cap at 5/month; require profile completion; device fingerprint |
| Hindi/Vedic astrology inaccurate | Market backlash | Start with basic Nakshatras only; clearly label as "introductory" |

---

## 12. Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Day-1 retention | >60% | Daily login reward effectiveness |
| Day-7 retention | >35% | Streak bonus + reading quality |
| Free → paid conversion | >5% | Stardust scarcity funnel |
| Star Pass subscriber rate | >3% of MAU | Paywall placement + value prop |
| Referral rate | >10% of users send 1+ invite | Trigger point effectiveness |
| Referral conversion | >20% of invitees download | Compatibility hook virality |
| Reading accuracy | >95% pass validation | Accuracy gate effectiveness |
| Average session time | >3 minutes | Content depth + engagement |
| App Store rating | >4.5 stars | Overall quality |

---

## Appendix A: Stardust Economy Balance Sheet

**Monthly stardust flow for a daily active free user:**
- Daily opens (30 days): 60 ✦
- Streak bonuses (4 weeks): 20 ✦
- **Total earned: ~80 ✦/month**

**Monthly stardust spend for typical usage:**
- Daily detailed reading (20 days): 40 ✦
- Chat messages (15): 15 ✦
- Tarot 3-card (2): 10 ✦
- Compatibility (1): 5 ✦
- **Total desired: ~70 ✦/month**

**Analysis:** A very active free user can almost sustain themselves but will feel the pinch on tarot + compatibility. They're always ~10-20 ✦ short of doing everything they want — this is the conversion pressure. One referral (15 ✦) or one starter purchase ($1.99 = 30 ✦) bridges the gap for a month.

**Star Pass subscriber ($2.99/mo):**
- Gets 80 ✦ + unlimited chat + detailed daily horoscope
- Chat alone saves ~30 ✦/month (if chatting daily)
- Effective value: 110+ ✦/month worth of content for $2.99
- Clear value proposition: "Why buy packs when the pass gives you more?"

---

## Appendix B: Competitive Positioning

Based on `2026-03-27-competitive-analysis.md`:

| Feature | Co-Star | Sanctuary | Nebula | **Celestia v2.0** |
|---------|---------|-----------|--------|-------------------|
| AI Chat | Paid only (VOID) | Human + AI ($4.99/wk) | AI chat | **Free 1/day + Stardust** |
| Privacy | Cloud | Cloud | Cloud | **100% on-device** |
| Accuracy | "NASA data" (marketing) | Human astrologers | Unknown | **SwissEphemeris + Accuracy Gate** |
| Price | $9-15/mo | $4.99/wk ($260/yr) | $9.99/wk | **$2.99/mo ($36/yr)** |
| Languages | EN only | EN only | 12 | **8 (incl. Hindi/Vedic)** |
| Vedic astrology | No | No | Basic | **Yes (Hindi market)** |
| Referral system | No | No | No | **Yes (compatibility hook)** |
| Offline | No | No | No | **Yes (fully offline)** |

**Celestia's moat:** On-device AI + accuracy gating + privacy + fair pricing + Vedic astrology. No competitor combines all five.
