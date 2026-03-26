# Celestia — On-Device AI Astrology App

> Design Spec v1.0 — 2026-03-26
> Status: Approved for implementation

---

## 1. Overview

**Celestia** is a premium AI astrology app that runs 100% on-device. Unlike Co-Star, Nebula, and every other astrology app that sends your data to cloud servers, Celestia keeps all your birth chart data, readings, and conversations permanently on your phone.

The AI is the product — a personal astrologer named Celestia who knows your chart by heart, remembers your past readings, and gets more personalized over time.

### Market Opportunity

- Astrology app market: $4.73B (2025), growing 25% CAGR to $29.82B by 2033
- 120M+ monthly active users across top astrology platforms
- Primary audience: women 18-35 (70-80% of paying users)
- Top competitors (Co-Star, Nebula) all use cloud AI — privacy vulnerability
- COPPA 2.0 and 78 state AI chatbot safety bills increase compliance costs for cloud competitors
- On-device architecture is inherently compliant with all privacy regulations

### Competitive Advantage

| Advantage | Details |
|-----------|---------|
| **Zero server costs** | Every subscription dollar is margin (minus Apple's 15-30% cut) |
| **Privacy by architecture** | Data literally cannot leave the device |
| **AI memory** | Readings reference your real life — no cloud app can match this |
| **Offline** | Works on planes, in foreign countries, anywhere |
| **Multilingual at zero cost** | AI generates in any language — no per-request API cost |
| **Regulatory moat** | Every new privacy law hurts cloud competitors, helps us |

---

## 2. Architecture

```
┌─────────────────────────────────────────────┐
│              CELESTIA APP                    │
├─────────────┬───────────────┬───────────────┤
│  UI Layer   │  Data Layer   │  AI Layer     │
│  (SwiftUI)  │  (SwiftData)  │  (MLX)        │
├─────────────┴───────┬───────┴───────────────┤
│                     │                        │
│  ┌─────────────┐    │    ┌──────────────┐   │
│  │ Chart Engine │    │    │ Gemma 3n E4B │   │
│  │ (SwissEph)  │    │    │  (~3GB, 4B   │   │
│  │             │    │    │  active params│   │
│  │ Calculates: │    │    │              │   │
│  │ - Planets   │    │    │ Generates:   │   │
│  │ - Houses    │    │    │ - Readings   │   │
│  │ - Aspects   │    │    │ - Chat       │   │
│  │ - Transits  │    │    │ - Tarot      │   │
│  └──────┬──────┘    │    └──────▲───────┘   │
│         │           │           │            │
│         └───────────┼───────────┘            │
│     Structured      │    AI writes prose     │
│     chart data      │    from chart data     │
│                     │                        │
│  ┌──────────────────┴───────────────────┐   │
│  │       Local Storage (SwiftData)       │   │
│  │  - User birth chart                   │   │
│  │  - Reading history                    │   │
│  │  - Life events & context              │   │
│  │  - Partner/friend charts              │   │
│  │  - Preferences & personality profile  │   │
│  └───────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
         Zero network calls. 100% on-device.
```

### Key Separation of Concerns

- **SwissEph** (open-source C ephemeris library) handles ALL astronomy math — planetary positions accurate to the arc-second. Same library used by professional astrology software.
- **Gemma 3n E4B** handles ONLY creative writing — receives structured chart data, writes personalized interpretations.
- **SwiftData** stores everything locally — readings improve over time as AI references your history.

### AI Model

- **Model:** Google Gemma 3n E4B (only)
- **Active parameters:** ~4B (total ~8B, PLE offloads embeddings to CPU)
- **4-bit quantized VRAM:** ~3GB
- **Bundled app size:** ~3.5-4GB total
- **Supports:** 140+ languages natively
- **No fallback model.** Single code path, single model.

### Target Devices

- **Minimum:** iPhone 15 Pro (8GB RAM) or newer
- **Rationale:** Premium device requirement filters for higher-spending users. iPhone 15 Pro launched Sep 2023 — large install base by ship date.

---

## 3. Features & Screens

### Navigation

Tab bar: **Today** | **Tarot** | **Chat** | **Compatibility** | **Profile**

### Feature Matrix

| Screen | What User Sees | What AI Does | Free or Paid |
|--------|---------------|-------------|-------------|
| **Onboarding** | Language picker → birth date/time/location → animated chart | Nothing — pure math | Free |
| **Home / Today** | Daily horoscope (80-120 words) + transit highlights + energy meters | Generates reading from current transits × user chart | Free (1/day) |
| **Ask Celestia** | Chat interface — ask anything about chart, life, relationships | Conversational AI with full chart context + memory | 5 free/day, unlimited with Star Pass |
| **Tarot** | Choose spread → animated card flip → reading | Interprets each card in context of chart + question | 1 free/week, then tokens |
| **Compatibility** | Add partner/friend birth info → side-by-side charts → reading | Compares both charts, writes relationship analysis | Star Pass or tokens |
| **Transit Alerts** | Push notifications on major transits | Writes 1-2 sentence mini-reading | Star Pass |
| **Weekly Deep Reading** | 5-section report: Love / Career / Health / Spiritual / Prediction | Generates each section (~100 words) from weekly transits | Star Pass |
| **Reading Journal** | Timeline of past readings, AI-spotted themes | References history, notes recurring themes | Star Pass |
| **Profile / Chart** | Birth chart visualization, planet/house details | Writes personality descriptions per placement | Free (basic), detailed = Star Pass |

### Paywall Trigger Points

| Trigger | Message |
|---------|---------|
| Tap Compatibility with no sub | "See if you're meant to be" |
| 6th chat message of the day | "Celestia loves talking to you! Unlock unlimited chat" |
| 2nd tarot reading in a week | "Your cards are calling — unlock unlimited readings" |
| Tap Transit Alerts | "Never miss a cosmic moment" |
| Tap Weekly Deep Reading | "Your personalized weekly forecast awaits" |
| After 7 days of daily use | Special offer: first week free trial |

---

## 4. Monetization & Pricing

### Subscription Tiers

| Tier | Price | What You Get |
|------|-------|-------------|
| **Free** | $0 | Birth chart, 1 daily horoscope, 1 tarot/week, 5 chats/day, basic profile |
| **Star Pass (Weekly)** | $6.99/week | Everything unlimited + compatibility + transit alerts + weekly reading + journal |
| **Star Pass (Monthly)** | $19.99/month | Same as weekly (slight discount) |
| **Star Pass (Yearly)** | $99.99/year | Same (best value — ~$8.33/mo) |

### Token Packs (Consumable IAP)

| Pack | Price | Tokens | Per Token |
|------|-------|--------|-----------|
| **Small** | $1.99 | 5 tokens | $0.40 |
| **Large** | $9.99 | 30 tokens | $0.33 (17% savings) |

Star Pass users spend zero tokens — everything is unlimited.

### Token Costs (for non-subscribers)

| Feature | Tokens |
|---------|--------|
| Extra daily horoscope refresh | 1 |
| Tarot reading (3-card) | 2 |
| Tarot reading (Celtic Cross) | 3 |
| Compatibility report | 3 |
| Detailed planet placement reading | 2 |
| Weekly deep reading | 5 |

### Revenue Projections (Conservative)

| Timeline | Users | Paid % | Monthly Revenue |
|----------|-------|--------|----------------|
| 3 months | 50K | 4% | ~$40K/mo |
| 6 months | 150K | 5% | ~$150K/mo |
| 12 months | 500K | 5% | ~$500K/mo |

Assumes ARPU of $20/mo for paying users (mix of weekly subs + tokens).

### Business Model Advantage

Zero server costs. Cloud AI competitors spend $0.01-0.05 per reading on API calls. At 500K users with multiple daily readings, that's $50-100K/month in server costs. Our cost is $0. Every subscription dollar is margin minus Apple's cut.

---

## 5. Design & Visual Identity

### Aesthetic

Dark, cosmic, premium — luxury meets cosmos. Not cheesy crystal-ball mysticism.

| Element | Choice | Reasoning |
|---------|--------|-----------|
| Background | Deep navy/black + subtle star field particles | Premium, low eye strain, matches nighttime usage |
| Accent colors | Gold (#FFD700) + soft purple (#9B72CF) + white text | Gold = premium. Purple = spiritual. High contrast. |
| Typography | Serif headings (elegant) + sans-serif body (readable) | Serif conveys authority and tradition — builds trust |
| Charts | Animated SVG birth charts with glowing planet markers | Interactive, shareable |
| Tarot cards | Custom Ideogram AI illustrated deck | Unique to Celestia, no licensing |
| Animations | Constellation connections, floating particles, card flips | Magical without being slow |
| App icon | Crescent moon + star + eye on dark purple gradient | Instantly reads as "astrology" |

### Art Pipeline

**Ideogram AI** ($20/mo subscription) for all visual assets:
- 78 tarot card front illustrations
- 12 zodiac sign artwork
- Background textures and celestial elements
- Onboarding screens and marketing art
- App Store screenshots

Style direction: *"Celestial illustration, gold line art on deep navy, mystical astronomical, premium luxury spiritual, Art Nouveau influenced"*

---

## 6. Data Models

### SwiftData Schema

```swift
// Core user profile with birth chart
UserProfile {
    id: UUID
    name: String
    birthDate: Date
    birthTime: Date
    birthCity: String
    birthLatitude: Double
    birthLongitude: Double
    language: Language          // enum: en, es, pt, ja, ko, fr
    sunSign: ZodiacSign
    moonSign: ZodiacSign
    risingSign: ZodiacSign
    chartData: ChartData
    createdAt: Date
    subscriptionTier: SubscriptionTier
}

// Calculated chart data from SwissEph
ChartData {
    planets: [PlanetPlacement]  // Sun through Pluto + nodes
    houses: [HouseCusp]        // 12 houses with degrees
    aspects: [Aspect]          // conjunctions, trines, squares, etc.
    calculatedAt: Date
}

PlanetPlacement {
    planet: Planet             // enum
    sign: ZodiacSign           // enum
    house: Int                 // 1-12
    degree: Double
    isRetrograde: Bool
    dignity: Dignity           // domicile/exaltation/detriment/fall
}

// AI-generated readings
Reading {
    id: UUID
    type: ReadingType          // daily/tarot/compatibility/weekly/chat
    content: String
    transitData: [Transit]
    createdAt: Date
    language: Language
    userNotes: String?
}

// Tarot system
TarotReading {
    id: UUID
    spreadType: SpreadType     // single/threeCard/celticCross
    cards: [DrawnCard]
    question: String?
    interpretation: String
    createdAt: Date
}

DrawnCard {
    card: TarotCard            // enum — 78 cards
    position: Int
    isReversed: Bool
    positionMeaning: String
}

// Compatibility contacts
Contact {
    id: UUID
    name: String
    birthDate: Date
    birthTime: Date?           // optional — partial chart ok
    birthLatitude: Double?
    birthLongitude: Double?
    relationship: Relationship // partner/friend/family/crush
    chartData: ChartData?
    compatibilityReadings: [Reading]
}

// Chat history
ChatMessage {
    id: UUID
    role: Role                 // user/celestia
    content: String
    createdAt: Date
    referencedReading: Reading?
}

// Token economy
TokenBalance {
    currentTokens: Int
    purchaseHistory: [TokenPurchase]
    usageHistory: [TokenUsage]
}
```

### AI Response Format

```json
{
    "reading": "Today Venus enters your 7th house...",
    "energy": {
        "love": 0.8,
        "career": 0.55,
        "health": 0.75,
        "spiritual": 0.9
    },
    "keyTheme": "romantic_opportunity",
    "actionAdvice": "Express your feelings openly today",
    "luckyElements": {
        "color": "rose gold",
        "number": 7,
        "crystal": "rose quartz"
    }
}
```

### AI Prompt Architecture

Dynamic system prompt built per reading:

```
SYSTEM: You are Celestia, a wise and mystical AI astrologer.
Language: {user.language}
Tone: warm, insightful, specific, empowering — never vague.

USER'S BIRTH CHART:
Sun: Pisces 15° (12th house)
Moon: Cancer 8° (4th house)
Rising: Aries 22°
[...all placements with aspects...]

TODAY'S TRANSITS:
Venus entering 7th house
Mercury retrograde in Pisces conjunct natal Sun
[...current transits from ephemeris...]

MEMORY (from past readings):
- 3 days ago: asked about career change
- Last week: reading mentioned upcoming Venus transit
- User noted: started dating someone new

TASK: Write today's personalized horoscope.
80-120 words. Focus on love + communication.
Respond in valid JSON format.
```

---

## 7. Technical Dependencies

| Component | Library/Framework | Purpose |
|-----------|------------------|---------|
| AI inference | MLX Swift + MLXLLM | Run Gemma 3n E4B on-device |
| Ephemeris | SwissEph (C bridge to Swift) | Planetary position calculations |
| Persistence | SwiftData | Local storage for all data |
| IAP | StoreKit 2 | Star Pass subscriptions + token packs |
| Notifications | UserNotifications | Transit alert push notifications |
| Location | CoreLocation | Birth city geocoding |
| Charts UI | SwiftUI Canvas | Birth chart visualization |
| Animations | SwiftUI + custom shaders | Star fields, card flips, transitions |
| Localization | String Catalogs (.xcstrings) | 6 languages from day 1 |

---

## 8. Multilingual Support

### Launch Languages (Day 1)

| Language | Code | Market Reason |
|----------|------|--------------|
| English | en | #1 app spend globally |
| Spanish | es | 500M speakers, huge astrology market |
| Portuguese | pt | Brazil = #3 astrology market globally |
| Japanese | ja | Fortune-telling apps are top-grossing in Japan |
| Korean | ko | High app spend per user, K-astrology trending |
| French | fr | Strong astrology culture (France + Africa) |

All 6 use Western/tropical astrology — same chart engine, different AI output language.

### Implementation

- UI strings: iOS String Catalogs (.xcstrings), one per language
- AI readings: Language instruction in system prompt ("Respond in {language}")
- Astrology terms: Glossary included in system prompt per language
- App Store listings: Gemini AI writes localized descriptions
- User flow: Language picker on first launch, changeable in Settings anytime

### Future Languages (v1.1+)

- Hindi (requires Vedic/sidereal astrology system — separate chart engine)
- Chinese (Simplified + Traditional)
- German, Italian, Turkish, Arabic
- Vedic astrology as a separate mode (different zodiac system entirely)

---

## 9. Development Phases

### Phase 1: Foundation (Week 1-2)
- New Xcode project, SwiftData models, bundle ID, GitHub repo
- SwissEph C-to-Swift bridge, birth chart calculation engine
- Chart accuracy verification against known reference charts
- Gemma 3n E4B integration via MLX Swift
- AI prompt engine + JSON response parser
- Language system with String Catalogs for 6 languages

**Milestone:** Input birth date → accurate chart data → AI writes a reading

### Phase 2: Core Screens (Week 3-4)
- Onboarding: language picker → birth data → city search → chart animation
- Home/Today: daily horoscope, energy meters, transit highlights
- Profile/Chart: interactive birth chart SVG, planet placement details
- Chat (Ask Celestia): conversational UI, memory injection, message history
- AI memory system: store readings + life context, inject into prompts

**Milestone:** Full daily loop — open app, read horoscope, chat with Celestia

### Phase 3: Revenue Features (Week 5-6)
- Tarot: 78-card deck, spread layouts, animated draw, AI interpretation
- Compatibility: add contact birth data, chart comparison, relationship reading
- Weekly deep reading: 5-section generation
- Transit alert notifications: ephemeris-triggered push with AI mini-reading
- Reading journal: timeline view, AI theme detection

**Milestone:** All premium features working

### Phase 4: Monetization & Polish (Week 7-8)
- StoreKit 2: Star Pass (3 tiers) + 2 token packs
- Paywall screens at all trigger points, free trial support
- Token economy: purchase, spend, balance tracking
- Art assets via Ideogram AI: 78 tarot cards, 12 zodiac signs, backgrounds, icon
- Animations: star field, card flips, chart drawing, transitions
- Localization QA across all 6 languages

**Milestone:** Monetized, polished, production-ready

### Phase 5: Launch (Week 9)
- TestFlight beta testing on real devices
- App Store screenshots (6 languages × device sizes)
- Marketing copy via Gemini AI in all 6 languages
- App Store submission
- Apple Featuring Nomination (on-device AI angle)

**Milestone:** Live on App Store

### Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| SwissEph C bridge complexity | Well-documented, Swift wrappers exist on GitHub |
| Gemma 3n memory pressure | Test early on real device in Phase 1; E2B as emergency fallback |
| 78 tarot card art production time | Start Ideogram generation in Phase 1, parallel to coding |
| App Review rejection | Privacy-first = simple review. No data collection. |
| Market timing | 9-week timeline is aggressive — ship before competitors adapt |

---

## 10. Build & Deploy Infrastructure

- **Code:** Written on Windows 11, pushed to GitHub
- **Build:** Mac Mini SSH (phil@192.168.2.131)
- **Testing:** TestFlight on real devices
- **Bundle ID:** com.pcchiu2023.celestia
- **New App Store Connect entry** (separate from Mochi Crew)
- **Codemagic:** Backup CI only

---

## 11. Future Expansion (Post-v1)

- **Vedic astrology mode** (sidereal zodiac — massive India market)
- **Apple Watch complication** (daily reading on wrist)
- **Widgets** (daily horoscope on home screen)
- **Social sharing** (beautiful chart cards for Instagram/TikTok)
- **Voice mode** (speak to Celestia using on-device speech recognition)
- **Additional languages** (Hindi, Chinese, German, Italian, Arabic, Turkish)
- **Yearly forecast** (premium one-time IAP, long-form sectional report)
