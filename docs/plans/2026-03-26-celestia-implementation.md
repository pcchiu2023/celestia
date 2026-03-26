# Celestia Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Celestia, a premium on-device AI astrology app with 6 languages, tarot, compatibility, and subscription monetization.

**Architecture:** SwissEph (C library via SPM) calculates planetary positions deterministically. Gemma 3n E4B (via MLX Swift) generates personalized readings from structured chart data. SwiftData stores everything locally. Zero network calls.

**Tech Stack:** Swift/SwiftUI, MLX Swift (MLXLLM), SwissEphemeris SPM package, SwiftData, StoreKit 2, UserNotifications, CoreLocation, String Catalogs

**Design Spec:** `C:\celestia\docs\specs\2026-03-26-celestia-design.md`

**Reference Codebase:** Mochi Crew at `C:\iosdesigner` — reuse patterns for MLX integration, JSON parsing, StoreKit 2, content filtering.

**License Note:** SwissEphemeris is GPL 2.0. Must purchase commercial license from Astrodienst AG (astro.com/swisseph) before App Store submission.

---

## File Structure

```
Celestia/
├── App/
│   ├── CelestiaApp.swift              # @main entry, ModelContainer, scene lifecycle
│   └── ContentView.swift              # Tab bar navigation (Today/Tarot/Chat/Compat/Profile)
├── Astrology/
│   ├── ChartEngine.swift              # SwissEph wrapper — birth chart calculations
│   ├── TransitEngine.swift            # Current transit calculations + aspect detection
│   ├── AstrologyTypes.swift           # Enums: Planet, ZodiacSign, Aspect, House, Dignity
│   └── AstrologyFormatter.swift       # Format chart data into human-readable prompt strings
├── AI/
│   ├── CelestiaBrain.swift            # MLX model loading, inference, system prompt builder
│   ├── ReadingParser.swift            # JSON response parsing with 3-tier fallback
│   ├── ReadingGenerator.swift         # Orchestrates: chart data → prompt → AI → parsed reading
│   ├── MemoryEngine.swift             # Builds memory context from past readings for prompt injection
│   └── ContentFilter.swift            # Input filtering (profanity, harmful, prompt injection)
├── Models/
│   ├── UserProfile.swift              # @Model — birth data, chart, language, sub tier
│   ├── ChartData.swift                # Codable — planet placements, houses, aspects
│   ├── Reading.swift                  # @Model — AI-generated readings (daily, tarot, compat, weekly)
│   ├── TarotReading.swift             # @Model — tarot spreads with drawn cards
│   ├── Contact.swift                  # @Model — compatibility contacts with optional chart
│   ├── ChatMessage.swift              # @Model — chat history with Celestia
│   └── TokenBalance.swift             # @Model — token economy (balance, purchases, usage)
├── Tarot/
│   ├── TarotDeck.swift                # 78-card enum, names, meanings, suit/number
│   ├── TarotSpread.swift              # Spread types (single, 3-card, Celtic Cross) with position meanings
│   └── TarotDrawEngine.swift          # Random card draw logic, reversals, spread layout
├── Shop/
│   ├── ShopCatalog.swift              # Product IDs: Star Pass tiers + 2 token packs
│   ├── SubscriptionManager.swift      # Star Pass entitlement checking
│   ├── TokenManager.swift             # Token balance, spend, purchase tracking
│   └── PaywallView.swift              # Paywall UI with trigger-specific messaging
├── Notifications/
│   └── TransitAlertManager.swift      # Push notifications for major transits
├── Views/
│   ├── Onboarding/
│   │   ├── LanguagePickerView.swift   # First-launch language selection
│   │   ├── BirthDataView.swift        # Birth date, time, city input
│   │   └── ChartRevealView.swift      # Animated chart reveal after onboarding
│   ├── Today/
│   │   ├── TodayView.swift            # Daily horoscope, energy meters, transits
│   │   └── EnergyMeterView.swift      # Love/Career/Health/Spiritual meter bars
│   ├── Tarot/
│   │   ├── TarotView.swift            # Spread picker, card draw, reading display
│   │   └── TarotCardView.swift        # Individual card with flip animation
│   ├── Chat/
│   │   └── ChatView.swift             # Ask Celestia conversational UI
│   ├── Compatibility/
│   │   ├── CompatibilityView.swift    # Contact list + add new
│   │   ├── AddContactView.swift       # Birth data entry for contacts
│   │   └── CompatReportView.swift     # Side-by-side charts + reading
│   ├── Profile/
│   │   ├── ProfileView.swift          # Birth chart display, settings, language
│   │   └── ChartWheelView.swift       # Interactive SVG-style chart visualization
│   ├── Journal/
│   │   └── JournalView.swift          # Reading history timeline
│   └── Components/
│       ├── StarFieldView.swift        # Animated star particle background
│       └── CelestiaTheme.swift        # Colors, fonts, spacing constants
└── Resources/
    ├── Localizable.xcstrings          # 6 languages
    ├── Products.storekit              # StoreKit config
    ├── Info.plist                      # Bundle config
    └── Assets.xcassets                # App icon, tarot card art, zodiac art
```

---

## Phase 1: Foundation (Week 1-2)

### Task 1: Project Setup

**Files:**
- Create: `Celestia/App/CelestiaApp.swift`
- Create: `Celestia/App/ContentView.swift`
- Create: `project.yml` (XCGen config)
- Create: `Celestia/Resources/Info.plist`

- [ ] **Step 1: Create the Xcode project directory structure**

```bash
cd /c/celestia
mkdir -p Celestia/{App,Astrology,AI,Models,Tarot,Shop,Notifications,Views/{Onboarding,Today,Tarot,Chat,Compatibility,Profile,Journal,Components},Resources}
```

- [ ] **Step 2: Create project.yml (XCGen config)**

```yaml
name: Celestia
options:
  bundleIdPrefix: com.pcchiu2023
  deploymentTarget:
    iOS: "17.0"
  xcodeVersion: "16.0"
  generateEmptyDirectories: true

settings:
  base:
    SWIFT_VERSION: "5.9"
    TARGETED_DEVICE_FAMILY: "1"
    INFOPLIST_FILE: Celestia/Resources/Info.plist
    DEVELOPMENT_TEAM: 6MB8Q7K6XJ

packages:
  mlx-swift-lm:
    url: https://github.com/ml-explore/mlx-swift-lm
    minorVersion: 2.29.1
  SwissEphemeris:
    url: https://github.com/vsmithers1087/SwissEphemeris.git
    from: 0.0.99

targets:
  Celestia:
    type: application
    platform: iOS
    sources: [Celestia]
    dependencies:
      - package: mlx-swift-lm
        product: MLXLLM
      - package: mlx-swift-lm
        product: MLXLMCommon
      - package: mlx-swift-lm
        product: MLX
      - package: SwissEphemeris
        product: SwissEphemeris
    resources:
      - path: Celestia/Resources
        buildPhase: resources
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.pcchiu2023.celestia
        PRODUCT_NAME: Celestia
```

- [ ] **Step 3: Create Info.plist**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Celestia</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>We need your location to look up your birth city for accurate chart calculations.</string>
</dict>
</plist>
```

- [ ] **Step 4: Create CelestiaApp.swift (minimal entry point)**

```swift
import SwiftUI
import SwiftData

@main
struct CelestiaApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: UserProfile.self,
                Reading.self,
                TarotReading.self,
                Contact.self,
                ChatMessage.self,
                TokenBalance.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
```

- [ ] **Step 5: Create ContentView.swift (placeholder tab bar)**

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("Today")
                .tabItem { Label("Today", systemImage: "sun.max.fill") }
            Text("Tarot")
                .tabItem { Label("Tarot", systemImage: "sparkles") }
            Text("Chat")
                .tabItem { Label("Chat", systemImage: "bubble.left.fill") }
            Text("Compatibility")
                .tabItem { Label("Match", systemImage: "heart.fill") }
            Text("Profile")
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .tint(CelestiaTheme.gold)
    }
}
```

- [ ] **Step 6: Create CelestiaTheme.swift**

```swift
import SwiftUI

enum CelestiaTheme {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)          // #FFD700
    static let purple = Color(red: 0.608, green: 0.447, blue: 0.812)   // #9B72CF
    static let navy = Color(red: 0.05, green: 0.05, blue: 0.15)        // Deep navy
    static let darkBg = Color(red: 0.02, green: 0.02, blue: 0.08)      // Near black
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)

    static let headingFont = Font.custom("Georgia", size: 24)           // Serif
    static let subheadingFont = Font.custom("Georgia", size: 18)
    static let bodyFont = Font.system(size: 16)                         // Sans-serif
    static let captionFont = Font.system(size: 13, design: .rounded)
}
```

- [ ] **Step 7: Initialize git repo and commit**

```bash
cd /c/celestia
git init
echo ".DS_Store\n*.xcodeproj\n*.xcworkspace\nDerivedData/\nbuild/\n.build/\n*.ipa" > .gitignore
git add .
git commit -m "feat: initial project setup with XCGen, SwiftData, MLX, SwissEphemeris deps"
```

---

### Task 2: Astrology Types & Enums

**Files:**
- Create: `Celestia/Astrology/AstrologyTypes.swift`

- [ ] **Step 1: Create all astrology enums and types**

```swift
import Foundation

// MARK: - Zodiac Signs

enum ZodiacSign: String, Codable, CaseIterable {
    case aries, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces

    var symbol: String {
        switch self {
        case .aries: return "♈"
        case .taurus: return "♉"
        case .gemini: return "♊"
        case .cancer: return "♋"
        case .leo: return "♌"
        case .virgo: return "♍"
        case .libra: return "♎"
        case .scorpio: return "♏"
        case .sagittarius: return "♐"
        case .capricorn: return "♑"
        case .aquarius: return "♒"
        case .pisces: return "♓"
        }
    }

    var element: Element {
        switch self {
        case .aries, .leo, .sagittarius: return .fire
        case .taurus, .virgo, .capricorn: return .earth
        case .gemini, .libra, .aquarius: return .air
        case .cancer, .scorpio, .pisces: return .water
        }
    }

    var modality: Modality {
        switch self {
        case .aries, .cancer, .libra, .capricorn: return .cardinal
        case .taurus, .leo, .scorpio, .aquarius: return .fixed
        case .gemini, .virgo, .sagittarius, .pisces: return .mutable
        }
    }

    static func from(longitude: Double) -> ZodiacSign {
        let normalized = longitude.truncatingRemainder(dividingBy: 360.0)
        let index = Int(normalized / 30.0)
        return ZodiacSign.allCases[index]
    }
}

enum Element: String, Codable {
    case fire, earth, air, water
}

enum Modality: String, Codable {
    case cardinal, fixed, mutable
}

// MARK: - Planets

enum CelestialBody: String, Codable, CaseIterable {
    case sun, moon, mercury, venus, mars
    case jupiter, saturn, uranus, neptune, pluto
    case northNode, southNode

    var symbol: String {
        switch self {
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .uranus: return "♅"
        case .neptune: return "♆"
        case .pluto: return "♇"
        case .northNode: return "☊"
        case .southNode: return "☋"
        }
    }
}

// MARK: - Aspects

enum AspectType: String, Codable {
    case conjunction  // 0°
    case sextile      // 60°
    case square        // 90°
    case trine         // 120°
    case opposition    // 180°

    var angle: Double {
        switch self {
        case .conjunction: return 0
        case .sextile: return 60
        case .square: return 90
        case .trine: return 120
        case .opposition: return 180
        }
    }

    var orb: Double {
        switch self {
        case .conjunction: return 8
        case .sextile: return 6
        case .square: return 7
        case .trine: return 8
        case .opposition: return 8
        }
    }

    var nature: String {
        switch self {
        case .conjunction: return "neutral"
        case .sextile, .trine: return "harmonious"
        case .square, .opposition: return "challenging"
        }
    }
}

// MARK: - Dignity

enum Dignity: String, Codable {
    case domicile     // planet rules this sign
    case exaltation   // planet is exalted here
    case detriment    // opposite of domicile
    case fall          // opposite of exaltation
    case peregrine    // no special dignity

    static func calculate(body: CelestialBody, sign: ZodiacSign) -> Dignity {
        switch (body, sign) {
        case (.sun, .leo): return .domicile
        case (.sun, .aries): return .exaltation
        case (.sun, .aquarius): return .detriment
        case (.sun, .libra): return .fall
        case (.moon, .cancer): return .domicile
        case (.moon, .taurus): return .exaltation
        case (.moon, .capricorn): return .detriment
        case (.moon, .scorpio): return .fall
        case (.mercury, .gemini), (.mercury, .virgo): return .domicile
        case (.mercury, .virgo): return .exaltation
        case (.mercury, .sagittarius), (.mercury, .pisces): return .detriment
        case (.mercury, .pisces): return .fall
        case (.venus, .taurus), (.venus, .libra): return .domicile
        case (.venus, .pisces): return .exaltation
        case (.venus, .aries), (.venus, .scorpio): return .detriment
        case (.venus, .virgo): return .fall
        case (.mars, .aries), (.mars, .scorpio): return .domicile
        case (.mars, .capricorn): return .exaltation
        case (.mars, .taurus), (.mars, .libra): return .detriment
        case (.mars, .cancer): return .fall
        case (.jupiter, .sagittarius), (.jupiter, .pisces): return .domicile
        case (.jupiter, .cancer): return .exaltation
        case (.jupiter, .gemini), (.jupiter, .virgo): return .detriment
        case (.jupiter, .capricorn): return .fall
        case (.saturn, .capricorn), (.saturn, .aquarius): return .domicile
        case (.saturn, .libra): return .exaltation
        case (.saturn, .cancer), (.saturn, .leo): return .detriment
        case (.saturn, .aries): return .fall
        default: return .peregrine
        }
    }
}

// MARK: - Placement

struct PlanetPlacement: Codable {
    let body: CelestialBody
    let sign: ZodiacSign
    let house: Int           // 1-12
    let degree: Double       // 0-359.99
    let signDegree: Double   // 0-29.99 within the sign
    let isRetrograde: Bool
    let dignity: Dignity
}

struct HouseCuspData: Codable {
    let house: Int           // 1-12
    let sign: ZodiacSign
    let degree: Double
}

struct AspectData: Codable {
    let body1: CelestialBody
    let body2: CelestialBody
    let type: AspectType
    let orb: Double          // actual orb in degrees
    let isApplying: Bool     // getting closer or separating
}

struct BirthChartData: Codable {
    let planets: [PlanetPlacement]
    let houses: [HouseCuspData]
    let aspects: [AspectData]
    let ascendantSign: ZodiacSign
    let mcSign: ZodiacSign   // Midheaven
    let calculatedAt: Date

    var sunSign: ZodiacSign {
        planets.first(where: { $0.body == .sun })?.sign ?? .aries
    }
    var moonSign: ZodiacSign {
        planets.first(where: { $0.body == .moon })?.sign ?? .aries
    }
    var risingSign: ZodiacSign {
        ascendantSign
    }
}

// MARK: - Transit

struct TransitData: Codable {
    let transiting: CelestialBody
    let natalTarget: CelestialBody?
    let aspectType: AspectType?
    let houseEntering: Int?
    let sign: ZodiacSign
    let description: String
}

// MARK: - Reading Types

enum ReadingType: String, Codable {
    case daily
    case tarot
    case compatibility
    case weekly
    case chat
    case placement   // detailed planet placement reading
}

// MARK: - Language

enum AppLanguage: String, Codable, CaseIterable {
    case en, es, pt, ja, ko, fr

    var displayName: String {
        switch self {
        case .en: return "English"
        case .es: return "Español"
        case .pt: return "Português"
        case .ja: return "日本語"
        case .ko: return "한국어"
        case .fr: return "Français"
        }
    }

    var promptInstruction: String {
        switch self {
        case .en: return "Respond in English."
        case .es: return "Responde en español."
        case .pt: return "Responda em português."
        case .ja: return "日本語で回答してください。"
        case .ko: return "한국어로 답변해 주세요."
        case .fr: return "Répondez en français."
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Celestia/Astrology/AstrologyTypes.swift
git commit -m "feat: add astrology types — zodiac signs, planets, aspects, dignities, placements"
```

---

### Task 3: SwissEph Chart Engine

**Files:**
- Create: `Celestia/Astrology/ChartEngine.swift`

- [ ] **Step 1: Create the chart calculation engine**

```swift
import Foundation
import SwissEphemeris

final class ChartEngine {

    static let shared = ChartEngine()

    private init() {
        JPLFileManager.setEphemerisPath()
    }

    // MARK: - Full Birth Chart

    func calculateBirthChart(
        date: Date,
        latitude: Double,
        longitude: Double
    ) -> BirthChartData {
        let planets = calculatePlanets(date: date, latitude: latitude, longitude: longitude)
        let houses = calculateHouses(date: date, latitude: latitude, longitude: longitude)
        let aspects = calculateAspects(planets: planets)

        let ascSign = houses.first(where: { $0.house == 1 })?.sign ?? .aries
        let mcSign = houses.first(where: { $0.house == 10 })?.sign ?? .capricorn

        return BirthChartData(
            planets: planets,
            houses: houses,
            aspects: aspects,
            ascendantSign: ascSign,
            mcSign: mcSign,
            calculatedAt: Date()
        )
    }

    // MARK: - Planet Positions

    private func calculatePlanets(
        date: Date,
        latitude: Double,
        longitude: Double
    ) -> [PlanetPlacement] {
        let houseCusps = HouseCusps(
            date: date,
            latitude: latitude,
            longitude: longitude,
            houseSystem: .placidus
        )
        let cuspDegrees = extractCuspDegrees(houseCusps)

        let swissPlanets: [(CelestialBody, Planet)] = [
            (.sun, .sun), (.moon, .moon), (.mercury, .mercury),
            (.venus, .venus), (.mars, .mars), (.jupiter, .jupiter),
            (.saturn, .saturn), (.uranus, .uranus), (.neptune, .neptune),
            (.pluto, .pluto)
        ]

        var placements: [PlanetPlacement] = []

        for (body, planet) in swissPlanets {
            let coord = Coordinate<Planet>(planet: planet, date: date)
            let lng = coord.longitude
            let sign = ZodiacSign.from(longitude: lng)
            let signDeg = lng.truncatingRemainder(dividingBy: 30.0)
            let house = houseForDegree(lng, cusps: cuspDegrees)
            let retrograde = coord.speedLongitude < 0

            placements.append(PlanetPlacement(
                body: body,
                sign: sign,
                house: house,
                degree: lng,
                signDegree: signDeg,
                isRetrograde: retrograde,
                dignity: Dignity.calculate(body: body, sign: sign)
            ))
        }

        // Lunar nodes
        let northNode = Coordinate<LunarNorthNode>(date: date)
        let nnLng = northNode.longitude
        let nnSign = ZodiacSign.from(longitude: nnLng)
        placements.append(PlanetPlacement(
            body: .northNode, sign: nnSign,
            house: houseForDegree(nnLng, cusps: cuspDegrees),
            degree: nnLng, signDegree: nnLng.truncatingRemainder(dividingBy: 30.0),
            isRetrograde: true, dignity: .peregrine
        ))

        let snLng = (nnLng + 180).truncatingRemainder(dividingBy: 360)
        let snSign = ZodiacSign.from(longitude: snLng)
        placements.append(PlanetPlacement(
            body: .southNode, sign: snSign,
            house: houseForDegree(snLng, cusps: cuspDegrees),
            degree: snLng, signDegree: snLng.truncatingRemainder(dividingBy: 30.0),
            isRetrograde: true, dignity: .peregrine
        ))

        return placements
    }

    // MARK: - House Cusps

    private func calculateHouses(
        date: Date,
        latitude: Double,
        longitude: Double
    ) -> [HouseCuspData] {
        let cusps = HouseCusps(
            date: date,
            latitude: latitude,
            longitude: longitude,
            houseSystem: .placidus
        )

        let cuspProperties: [KeyPath<HouseCusps, Coordinate<House>>] = [
            \.first, \.second, \.third, \.fourth, \.fifth, \.sixth,
            \.seventh, \.eighth, \.ninth, \.tenth, \.eleventh, \.twelfth
        ]

        return cuspProperties.enumerated().map { index, keyPath in
            let coord = cusps[keyPath: keyPath]
            let lng = coord.longitude
            return HouseCuspData(
                house: index + 1,
                sign: ZodiacSign.from(longitude: lng),
                degree: lng
            )
        }
    }

    // MARK: - Aspects

    private func calculateAspects(planets: [PlanetPlacement]) -> [AspectData] {
        var aspects: [AspectData] = []
        let mainPlanets = planets.filter {
            $0.body != .northNode && $0.body != .southNode
        }

        for i in 0..<mainPlanets.count {
            for j in (i+1)..<mainPlanets.count {
                let p1 = mainPlanets[i]
                let p2 = mainPlanets[j]
                let angle = angleBetween(p1.degree, p2.degree)

                for aspectType in AspectType.allCases {
                    let diff = abs(angle - aspectType.angle)
                    if diff <= aspectType.orb {
                        aspects.append(AspectData(
                            body1: p1.body,
                            body2: p2.body,
                            type: aspectType,
                            orb: diff,
                            isApplying: p1.isRetrograde != p2.isRetrograde
                        ))
                    }
                }
            }
        }

        return aspects.sorted { $0.orb < $1.orb }
    }

    // MARK: - Helpers

    private func angleBetween(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b)
        return diff > 180 ? 360 - diff : diff
    }

    private func houseForDegree(_ degree: Double, cusps: [Double]) -> Int {
        for i in 0..<12 {
            let start = cusps[i]
            let end = cusps[(i + 1) % 12]
            if start < end {
                if degree >= start && degree < end { return i + 1 }
            } else {
                if degree >= start || degree < end { return i + 1 }
            }
        }
        return 1
    }

    private func extractCuspDegrees(_ cusps: HouseCusps) -> [Double] {
        let keyPaths: [KeyPath<HouseCusps, Coordinate<House>>] = [
            \.first, \.second, \.third, \.fourth, \.fifth, \.sixth,
            \.seventh, \.eighth, \.ninth, \.tenth, \.eleventh, \.twelfth
        ]
        return keyPaths.map { cusps[keyPath: $0].longitude }
    }
}

extension AspectType: CaseIterable {
    static var allCases: [AspectType] {
        [.conjunction, .sextile, .square, .trine, .opposition]
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Celestia/Astrology/ChartEngine.swift
git commit -m "feat: add ChartEngine — SwissEph integration for birth charts, houses, aspects"
```

---

### Task 4: Transit Engine

**Files:**
- Create: `Celestia/Astrology/TransitEngine.swift`

- [ ] **Step 1: Create transit calculation engine**

```swift
import Foundation
import SwissEphemeris

final class TransitEngine {

    static let shared = TransitEngine()
    private init() {}

    /// Calculate current transits relative to a natal chart
    func calculateTransits(
        natalChart: BirthChartData,
        transitDate: Date = Date()
    ) -> [TransitData] {
        var transits: [TransitData] = []

        // Get current planetary positions
        let currentPlanets = currentPositions(date: transitDate)

        // Check transits to natal planets
        for current in currentPlanets {
            for natal in natalChart.planets {
                let angle = angleBetween(current.degree, natal.degree)

                for aspectType in AspectType.allCases {
                    let diff = abs(angle - aspectType.angle)
                    if diff <= aspectType.orb * 0.75 { // tighter orbs for transits
                        transits.append(TransitData(
                            transiting: current.body,
                            natalTarget: natal.body,
                            aspectType: aspectType,
                            houseEntering: nil,
                            sign: current.sign,
                            description: "\(current.body.symbol) \(current.body.rawValue.capitalized) \(aspectType.rawValue) natal \(natal.body.symbol) \(natal.body.rawValue.capitalized)"
                        ))
                    }
                }
            }

            // Check house ingress (planet entering a new house)
            let house = houseForTransit(current.degree, natalHouses: natalChart.houses)
            let natalHouseSign = natalChart.houses.first(where: { $0.house == house })?.sign
            if current.sign == natalHouseSign {
                transits.append(TransitData(
                    transiting: current.body,
                    natalTarget: nil,
                    aspectType: nil,
                    houseEntering: house,
                    sign: current.sign,
                    description: "\(current.body.symbol) \(current.body.rawValue.capitalized) entering house \(house)"
                ))
            }
        }

        // Deduplicate and sort by importance (outer planets first)
        return Array(Set(transits.map { $0.description }).compactMap { desc in
            transits.first(where: { $0.description == desc })
        }).sorted { importance($0) > importance($1) }
    }

    /// Check for significant upcoming transits (for notifications)
    func significantTransitsToday(natalChart: BirthChartData) -> [TransitData] {
        let all = calculateTransits(natalChart: natalChart)
        return all.filter { importance($0) >= 5 }
    }

    // MARK: - Private

    private func currentPositions(date: Date) -> [PlanetPlacement] {
        let bodies: [(CelestialBody, Planet)] = [
            (.sun, .sun), (.moon, .moon), (.mercury, .mercury),
            (.venus, .venus), (.mars, .mars), (.jupiter, .jupiter),
            (.saturn, .saturn), (.uranus, .uranus), (.neptune, .neptune),
            (.pluto, .pluto)
        ]

        return bodies.map { body, planet in
            let coord = Coordinate<Planet>(planet: planet, date: date)
            let lng = coord.longitude
            let sign = ZodiacSign.from(longitude: lng)
            return PlanetPlacement(
                body: body, sign: sign, house: 0,
                degree: lng,
                signDegree: lng.truncatingRemainder(dividingBy: 30.0),
                isRetrograde: coord.speedLongitude < 0,
                dignity: Dignity.calculate(body: body, sign: sign)
            )
        }
    }

    private func importance(_ transit: TransitData) -> Int {
        var score = 0
        // Outer planets = more significant
        switch transit.transiting {
        case .pluto: score += 10
        case .neptune: score += 9
        case .uranus: score += 8
        case .saturn: score += 7
        case .jupiter: score += 6
        case .mars: score += 4
        case .venus: score += 3
        case .sun: score += 3
        case .mercury: score += 2
        case .moon: score += 1
        default: score += 1
        }
        // Conjunctions and oppositions most impactful
        switch transit.aspectType {
        case .conjunction: score += 3
        case .opposition: score += 2
        case .square: score += 2
        case .trine: score += 1
        case .sextile: score += 1
        case .none: break
        }
        return score
    }

    private func angleBetween(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b)
        return diff > 180 ? 360 - diff : diff
    }

    private func houseForTransit(_ degree: Double, natalHouses: [HouseCuspData]) -> Int {
        let cusps = natalHouses.sorted(by: { $0.house < $1.house }).map { $0.degree }
        for i in 0..<12 {
            let start = cusps[i]
            let end = cusps[(i + 1) % 12]
            if start < end {
                if degree >= start && degree < end { return i + 1 }
            } else {
                if degree >= start || degree < end { return i + 1 }
            }
        }
        return 1
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Celestia/Astrology/TransitEngine.swift
git commit -m "feat: add TransitEngine — current transit calculations relative to natal chart"
```

---

### Task 5: Astrology Formatter (Chart Data → Prompt Strings)

**Files:**
- Create: `Celestia/Astrology/AstrologyFormatter.swift`

- [ ] **Step 1: Create formatter that converts chart data into AI prompt strings**

```swift
import Foundation

enum AstrologyFormatter {

    /// Format a full birth chart for the AI system prompt
    static func formatChartForPrompt(_ chart: BirthChartData) -> String {
        var lines: [String] = ["USER'S BIRTH CHART:"]

        // Key placements
        for p in chart.planets {
            let retro = p.isRetrograde ? " (retrograde)" : ""
            let dignityStr = p.dignity != .peregrine ? " [\(p.dignity.rawValue)]" : ""
            lines.append("\(p.body.symbol) \(p.body.rawValue.capitalized): \(p.sign.rawValue.capitalized) \(Int(p.signDegree))° (House \(p.house))\(retro)\(dignityStr)")
        }

        // Ascendant and Midheaven
        lines.append("")
        lines.append("Ascendant (Rising): \(chart.ascendantSign.rawValue.capitalized) \(chart.ascendantSign.symbol)")
        lines.append("Midheaven (MC): \(chart.mcSign.rawValue.capitalized) \(chart.mcSign.symbol)")

        // Key aspects
        let significantAspects = chart.aspects.filter { $0.orb < 5 }.prefix(10)
        if !significantAspects.isEmpty {
            lines.append("")
            lines.append("KEY ASPECTS:")
            for a in significantAspects {
                lines.append("\(a.body1.symbol) \(a.body1.rawValue.capitalized) \(a.type.rawValue) \(a.body2.symbol) \(a.body2.rawValue.capitalized) (orb: \(String(format: "%.1f", a.orb))°, \(a.type.nature))")
            }
        }

        return lines.joined(separator: "\n")
    }

    /// Format current transits for the AI prompt
    static func formatTransitsForPrompt(_ transits: [TransitData]) -> String {
        guard !transits.isEmpty else { return "No significant transits today." }

        var lines = ["TODAY'S TRANSITS:"]
        for t in transits.prefix(8) {
            lines.append("• \(t.description)")
        }
        return lines.joined(separator: "\n")
    }

    /// Format compatibility data for two charts
    static func formatCompatibility(chart1: BirthChartData, name1: String, chart2: BirthChartData, name2: String) -> String {
        var lines = [
            "COMPATIBILITY ANALYSIS:",
            "",
            "\(name1)'s Sun: \(chart1.sunSign.rawValue.capitalized) \(chart1.sunSign.symbol)",
            "\(name1)'s Moon: \(chart1.moonSign.rawValue.capitalized)",
            "\(name1)'s Rising: \(chart1.risingSign.rawValue.capitalized)",
            "",
            "\(name2)'s Sun: \(chart2.sunSign.rawValue.capitalized) \(chart2.sunSign.symbol)",
            "\(name2)'s Moon: \(chart2.moonSign.rawValue.capitalized)",
            "\(name2)'s Rising: \(chart2.risingSign.rawValue.capitalized)",
            "",
            "ELEMENT COMPATIBILITY:"
        ]

        let el1 = chart1.sunSign.element
        let el2 = chart2.sunSign.element
        let compatibility = elementCompatibility(el1, el2)
        lines.append("\(el1.rawValue.capitalized) + \(el2.rawValue.capitalized) = \(compatibility)")

        // Cross-aspects between charts
        lines.append("")
        lines.append("KEY CROSS-ASPECTS:")
        let crossAspects = calculateCrossAspects(chart1: chart1, chart2: chart2)
        for a in crossAspects.prefix(8) {
            lines.append("• \(name1)'s \(a.body1.rawValue.capitalized) \(a.type.rawValue) \(name2)'s \(a.body2.rawValue.capitalized) (\(a.type.nature))")
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Private

    private static func elementCompatibility(_ e1: Element, _ e2: Element) -> String {
        if e1 == e2 { return "Very harmonious — same element, deep understanding" }
        switch (e1, e2) {
        case (.fire, .air), (.air, .fire): return "Exciting and stimulating — fire and air fuel each other"
        case (.earth, .water), (.water, .earth): return "Nurturing and stable — earth and water complement naturally"
        case (.fire, .earth), (.earth, .fire): return "Challenging but grounding — different paces, mutual growth"
        case (.fire, .water), (.water, .fire): return "Intense and transformative — steam when combined"
        case (.air, .earth), (.earth, .air): return "Contrasting perspectives — mind meets matter"
        case (.air, .water), (.water, .air): return "Cerebral meets emotional — requires patience and understanding"
        default: return "Unique dynamic"
        }
    }

    private static func calculateCrossAspects(chart1: BirthChartData, chart2: BirthChartData) -> [AspectData] {
        var aspects: [AspectData] = []
        let main1 = chart1.planets.filter { [.sun, .moon, .venus, .mars, .mercury].contains($0.body) }
        let main2 = chart2.planets.filter { [.sun, .moon, .venus, .mars, .mercury].contains($0.body) }

        for p1 in main1 {
            for p2 in main2 {
                let angle = abs(p1.degree - p2.degree)
                let normalized = angle > 180 ? 360 - angle : angle

                for aspectType in AspectType.allCases {
                    let diff = abs(normalized - aspectType.angle)
                    if diff <= aspectType.orb {
                        aspects.append(AspectData(
                            body1: p1.body, body2: p2.body,
                            type: aspectType, orb: diff, isApplying: false
                        ))
                    }
                }
            }
        }
        return aspects.sorted { $0.orb < $1.orb }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Celestia/Astrology/AstrologyFormatter.swift
git commit -m "feat: add AstrologyFormatter — converts chart data to AI prompt strings"
```

---

### Task 6: SwiftData Models

**Files:**
- Create: `Celestia/Models/UserProfile.swift`
- Create: `Celestia/Models/ChartData.swift`
- Create: `Celestia/Models/Reading.swift`
- Create: `Celestia/Models/TarotReading.swift`
- Create: `Celestia/Models/Contact.swift`
- Create: `Celestia/Models/ChatMessage.swift`
- Create: `Celestia/Models/TokenBalance.swift`

- [ ] **Step 1: Create UserProfile model**

```swift
import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var name: String
    var birthDate: Date
    var birthTime: Date
    var birthCity: String
    var birthLatitude: Double
    var birthLongitude: Double
    var language: String          // AppLanguage.rawValue
    var chartDataJSON: Data?      // Encoded BirthChartData
    var createdAt: Date
    var subscriptionTier: String  // "free", "weekly", "monthly", "yearly"
    var onboardingComplete: Bool

    init(
        name: String,
        birthDate: Date,
        birthTime: Date,
        birthCity: String,
        birthLatitude: Double,
        birthLongitude: Double,
        language: AppLanguage = .en
    ) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.birthCity = birthCity
        self.birthLatitude = birthLatitude
        self.birthLongitude = birthLongitude
        self.language = language.rawValue
        self.createdAt = Date()
        self.subscriptionTier = "free"
        self.onboardingComplete = false
    }

    var appLanguage: AppLanguage {
        AppLanguage(rawValue: language) ?? .en
    }

    var chartData: BirthChartData? {
        get {
            guard let data = chartDataJSON else { return nil }
            return try? JSONDecoder().decode(BirthChartData.self, from: data)
        }
        set {
            chartDataJSON = try? JSONEncoder().encode(newValue)
        }
    }
}
```

- [ ] **Step 2: Create Reading model**

```swift
import Foundation
import SwiftData

@Model
final class Reading {
    var id: UUID
    var type: String              // ReadingType.rawValue
    var content: String
    var transitDataJSON: Data?    // Encoded [TransitData]
    var energyLove: Double
    var energyCareer: Double
    var energyHealth: Double
    var energySpiritual: Double
    var keyTheme: String
    var actionAdvice: String
    var createdAt: Date
    var language: String

    init(
        type: ReadingType,
        content: String,
        transits: [TransitData] = [],
        energy: (love: Double, career: Double, health: Double, spiritual: Double) = (0.5, 0.5, 0.5, 0.5),
        keyTheme: String = "",
        actionAdvice: String = "",
        language: AppLanguage = .en
    ) {
        self.id = UUID()
        self.type = type.rawValue
        self.content = content
        self.transitDataJSON = try? JSONEncoder().encode(transits)
        self.energyLove = energy.love
        self.energyCareer = energy.career
        self.energyHealth = energy.health
        self.energySpiritual = energy.spiritual
        self.keyTheme = keyTheme
        self.actionAdvice = actionAdvice
        self.createdAt = Date()
        self.language = language.rawValue
    }
}
```

- [ ] **Step 3: Create TarotReading model**

```swift
import Foundation
import SwiftData

@Model
final class TarotReading {
    var id: UUID
    var spreadType: String        // SpreadType.rawValue
    var cardsJSON: Data?          // Encoded [DrawnCardData]
    var question: String?
    var interpretation: String
    var createdAt: Date

    init(
        spreadType: String,
        cards: [DrawnCardData],
        question: String? = nil,
        interpretation: String
    ) {
        self.id = UUID()
        self.spreadType = spreadType
        self.cardsJSON = try? JSONEncoder().encode(cards)
        self.question = question
        self.interpretation = interpretation
        self.createdAt = Date()
    }

    var cards: [DrawnCardData] {
        guard let data = cardsJSON else { return [] }
        return (try? JSONDecoder().decode([DrawnCardData].self, from: data)) ?? []
    }
}

struct DrawnCardData: Codable {
    let cardId: String        // TarotCard rawValue
    let position: Int
    let isReversed: Bool
    let positionMeaning: String
}
```

- [ ] **Step 4: Create Contact model**

```swift
import Foundation
import SwiftData

@Model
final class Contact {
    var id: UUID
    var name: String
    var birthDate: Date
    var birthTime: Date?
    var birthCity: String?
    var birthLatitude: Double?
    var birthLongitude: Double?
    var relationship: String      // "partner", "friend", "family", "crush"
    var chartDataJSON: Data?
    var createdAt: Date

    init(
        name: String,
        birthDate: Date,
        birthTime: Date? = nil,
        birthCity: String? = nil,
        birthLatitude: Double? = nil,
        birthLongitude: Double? = nil,
        relationship: String = "friend"
    ) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.birthCity = birthCity
        self.birthLatitude = birthLatitude
        self.birthLongitude = birthLongitude
        self.relationship = relationship
        self.createdAt = Date()
    }

    var chartData: BirthChartData? {
        get {
            guard let data = chartDataJSON else { return nil }
            return try? JSONDecoder().decode(BirthChartData.self, from: data)
        }
        set {
            chartDataJSON = try? JSONEncoder().encode(newValue)
        }
    }
}
```

- [ ] **Step 5: Create ChatMessage model**

```swift
import Foundation
import SwiftData

@Model
final class ChatMessage {
    var id: UUID
    var role: String              // "user" or "celestia"
    var content: String
    var createdAt: Date

    init(role: String, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.createdAt = Date()
    }
}
```

- [ ] **Step 6: Create TokenBalance model**

```swift
import Foundation
import SwiftData

@Model
final class TokenBalance {
    var currentTokens: Int
    var totalPurchased: Int
    var totalSpent: Int

    init() {
        self.currentTokens = 0
        self.totalPurchased = 0
        self.totalSpent = 0
    }

    func spend(_ amount: Int) -> Bool {
        guard currentTokens >= amount else { return false }
        currentTokens -= amount
        totalSpent += amount
        return true
    }

    func add(_ amount: Int) {
        currentTokens += amount
        totalPurchased += amount
    }
}
```

- [ ] **Step 7: Update CelestiaApp.swift ModelContainer with all models**

Update the `init()` in `CelestiaApp.swift` — the model container already lists all 6 types from Task 1.

- [ ] **Step 8: Commit**

```bash
git add Celestia/Models/
git commit -m "feat: add SwiftData models — UserProfile, Reading, TarotReading, Contact, ChatMessage, TokenBalance"
```

---

### Task 7: AI Brain — Model Loading & Inference

**Files:**
- Create: `Celestia/AI/CelestiaBrain.swift`

- [ ] **Step 1: Create CelestiaBrain (based on Mochi Crew's DollBrain pattern)**

```swift
import Foundation
import MLXLLM
import MLXLMCommon
import MLX

@MainActor
final class CelestiaBrain: ObservableObject {
    @Published var isModelLoaded = false
    @Published var isGenerating = false
    @Published var loadingProgress: String = "Awakening the stars..."

    private var container: ModelContainer?

    // MARK: - Model Loading

    func loadModel() async {
        loadingProgress = "Aligning the cosmos..."

        GPU.set(cacheLimit: 1024 * 1024 * 1024) // 1GB GPU cache

        guard let modelURL = findModelPath() else {
            loadingProgress = "Model not found"
            return
        }

        do {
            let config = ModelConfiguration(directory: modelURL)
            container = try await LLMModelFactory.shared.loadContainer(configuration: config)
            isModelLoaded = true
            loadingProgress = "The stars are ready"
        } catch {
            loadingProgress = "Failed to load: \(error.localizedDescription)"
        }
    }

    // MARK: - Text Generation

    func generate(systemPrompt: String, userPrompt: String) async -> String {
        guard let container else { return "" }
        isGenerating = true
        defer { isGenerating = false }

        let messages: [Chat.Message] = [
            .system(systemPrompt),
            .user(userPrompt)
        ]

        do {
            let input = UserInput(chat: messages)
            let lmInput = try await container.prepare(input: input)
            let params = GenerateParameters(
                maxTokens: 300,
                temperature: 0.85,
                topP: 0.92,
                repetitionPenalty: 1.15
            )

            var fullResponse = ""
            let stream = try await container.generate(input: lmInput, parameters: params)

            for await generation in stream {
                switch generation {
                case .chunk(let text):
                    fullResponse += text
                case .done:
                    break
                }
            }

            return fullResponse
        } catch {
            return ""
        }
    }

    // MARK: - Model Path

    private func findModelPath() -> URL? {
        let modelName = "gemma-3n-E4B-it-4bit" // Will be updated when model is bundled

        // Check bundle resources
        if let url = Bundle.main.resourceURL?.appendingPathComponent(modelName) {
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }

        // Check bundle path directly
        if let url = Bundle.main.url(forResource: modelName, withExtension: nil) {
            return url
        }

        return nil
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Celestia/AI/CelestiaBrain.swift
git commit -m "feat: add CelestiaBrain — MLX model loading and text generation"
```

---

### Task 8: Reading Parser (JSON Response Parsing)

**Files:**
- Create: `Celestia/AI/ReadingParser.swift`

- [ ] **Step 1: Create ReadingParser (based on Mochi Crew's ResponseParser)**

```swift
import Foundation

struct ParsedReading {
    let reading: String
    let energyLove: Double
    let energyCareer: Double
    let energyHealth: Double
    let energySpiritual: Double
    let keyTheme: String
    let actionAdvice: String
    let luckyColor: String
    let luckyNumber: Int
    let luckyCrystal: String
}

enum ReadingParser {

    // Codable struct matching expected JSON output
    private struct RawReading: Codable {
        let reading: String?
        let energy: Energy?
        let keyTheme: String?
        let actionAdvice: String?
        let luckyElements: LuckyElements?

        struct Energy: Codable {
            let love: Double?
            let career: Double?
            let health: Double?
            let spiritual: Double?
        }

        struct LuckyElements: Codable {
            let color: String?
            let number: Int?
            let crystal: String?
        }
    }

    static func parse(_ text: String) -> ParsedReading {
        // Tier 1: Try JSON extraction
        if let jsonStart = text.firstIndex(of: "{"),
           let jsonEnd = text.lastIndex(of: "}") {
            let jsonString = String(text[jsonStart...jsonEnd])
            if let data = jsonString.data(using: .utf8),
               let raw = try? JSONDecoder().decode(RawReading.self, from: data),
               let readingText = raw.reading, !readingText.isEmpty {
                return ParsedReading(
                    reading: readingText,
                    energyLove: raw.energy?.love ?? 0.5,
                    energyCareer: raw.energy?.career ?? 0.5,
                    energyHealth: raw.energy?.health ?? 0.5,
                    energySpiritual: raw.energy?.spiritual ?? 0.5,
                    keyTheme: raw.keyTheme ?? "general_guidance",
                    actionAdvice: raw.actionAdvice ?? "",
                    luckyColor: raw.luckyElements?.color ?? "gold",
                    luckyNumber: raw.luckyElements?.number ?? 7,
                    luckyCrystal: raw.luckyElements?.crystal ?? "clear quartz"
                )
            }
        }

        // Tier 2: Extract plain text (strip markdown/JSON artifacts)
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !$0.hasPrefix("{") && !$0.hasPrefix("}") && !$0.hasPrefix("\"") }
            .joined(separator: " ")

        if !cleaned.isEmpty && cleaned.count > 10 {
            return ParsedReading(
                reading: String(cleaned.prefix(500)),
                energyLove: 0.5, energyCareer: 0.5,
                energyHealth: 0.5, energySpiritual: 0.5,
                keyTheme: "general_guidance",
                actionAdvice: "",
                luckyColor: "gold", luckyNumber: 7, luckyCrystal: "clear quartz"
            )
        }

        // Tier 3: Fallback
        return fallbackReading()
    }

    private static func fallbackReading() -> ParsedReading {
        let fallbacks = [
            "The stars are shifting in your favor today. Trust your intuition and stay open to unexpected opportunities.",
            "A gentle cosmic energy surrounds you. Take a moment to reflect on what truly matters to you.",
            "The universe is aligning for a period of growth. Be patient with yourself as new paths reveal themselves.",
            "Today carries a quiet but powerful energy. Pay attention to the small signs around you.",
        ]
        return ParsedReading(
            reading: fallbacks.randomElement()!,
            energyLove: 0.6, energyCareer: 0.5,
            energyHealth: 0.7, energySpiritual: 0.6,
            keyTheme: "general_guidance",
            actionAdvice: "Trust your intuition today.",
            luckyColor: "gold", luckyNumber: 7, luckyCrystal: "amethyst"
        )
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Celestia/AI/ReadingParser.swift
git commit -m "feat: add ReadingParser — 3-tier JSON parsing with fallback for AI readings"
```

---

### Task 9: Reading Generator (Orchestrator)

**Files:**
- Create: `Celestia/AI/ReadingGenerator.swift`
- Create: `Celestia/AI/MemoryEngine.swift`

- [ ] **Step 1: Create MemoryEngine**

```swift
import Foundation
import SwiftData

enum MemoryEngine {

    /// Build memory context from recent readings for prompt injection
    static func buildContext(modelContext: ModelContext, limit: Int = 5) -> String {
        let descriptor = FetchDescriptor<Reading>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        guard let readings = try? modelContext.fetch(descriptor) else {
            return "No previous readings."
        }

        let recent = readings.prefix(limit)
        guard !recent.isEmpty else { return "This is the user's first reading." }

        var lines = ["MEMORY (recent readings):"]
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        for reading in recent {
            let timeAgo = formatter.localizedString(for: reading.createdAt, relativeTo: Date())
            let preview = String(reading.content.prefix(80))
            lines.append("• \(timeAgo): [\(reading.type)] \(preview)...")
        }

        return lines.joined(separator: "\n")
    }

    /// Build chat history context
    static func buildChatContext(modelContext: ModelContext, limit: Int = 10) -> String {
        let descriptor = FetchDescriptor<ChatMessage>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        guard let messages = try? modelContext.fetch(descriptor) else {
            return ""
        }

        let recent = Array(messages.prefix(limit).reversed())
        guard !recent.isEmpty else { return "" }

        var lines = ["RECENT CONVERSATION:"]
        for msg in recent {
            let role = msg.role == "user" ? "User" : "Celestia"
            lines.append("\(role): \(String(msg.content.prefix(100)))")
        }
        return lines.joined(separator: "\n")
    }
}
```

- [ ] **Step 2: Create ReadingGenerator**

```swift
import Foundation
import SwiftData

@MainActor
final class ReadingGenerator: ObservableObject {

    private let brain: CelestiaBrain

    init(brain: CelestiaBrain) {
        self.brain = brain
    }

    // MARK: - Daily Horoscope

    func generateDailyReading(
        profile: UserProfile,
        modelContext: ModelContext
    ) async -> ParsedReading {
        guard let chart = profile.chartData else { return ReadingParser.parse("") }

        let transits = TransitEngine.shared.calculateTransits(natalChart: chart)
        let memory = MemoryEngine.buildContext(modelContext: modelContext)
        let lang = profile.appLanguage

        let systemPrompt = """
        You are Celestia, a wise and mystical AI astrologer.
        \(lang.promptInstruction)
        Tone: warm, insightful, specific, empowering — never vague or generic.
        Always reference specific planetary placements and transits.

        \(AstrologyFormatter.formatChartForPrompt(chart))

        \(AstrologyFormatter.formatTransitsForPrompt(transits))

        \(memory)
        """

        let userPrompt = """
        Write today's personalized horoscope. 80-120 words.
        Focus on the most significant transits.
        If memory mentions relevant past readings, reference them naturally.
        Respond in valid JSON:
        {"reading":"...","energy":{"love":0.0-1.0,"career":0.0-1.0,"health":0.0-1.0,"spiritual":0.0-1.0},"keyTheme":"...","actionAdvice":"...","luckyElements":{"color":"...","number":N,"crystal":"..."}}
        """

        let raw = await brain.generate(systemPrompt: systemPrompt, userPrompt: userPrompt)
        return ReadingParser.parse(raw)
    }

    // MARK: - Chat Response

    func generateChatResponse(
        message: String,
        profile: UserProfile,
        modelContext: ModelContext
    ) async -> String {
        guard let chart = profile.chartData else { return "I need your birth chart first." }

        let transits = TransitEngine.shared.calculateTransits(natalChart: chart)
        let chatHistory = MemoryEngine.buildChatContext(modelContext: modelContext)
        let memory = MemoryEngine.buildContext(modelContext: modelContext, limit: 3)
        let lang = profile.appLanguage

        let systemPrompt = """
        You are Celestia, a wise and mystical AI astrologer.
        \(lang.promptInstruction)
        You are having a conversation. Be warm, personal, and reference the user's chart.
        Keep responses under 150 words.

        \(AstrologyFormatter.formatChartForPrompt(chart))

        \(AstrologyFormatter.formatTransitsForPrompt(transits))

        \(memory)

        \(chatHistory)
        """

        let raw = await brain.generate(systemPrompt: systemPrompt, userPrompt: message)

        // For chat, extract plain text (not JSON)
        let cleaned = raw
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned.isEmpty ? "The stars are quiet right now... ask me again." : cleaned
    }

    // MARK: - Compatibility Reading

    func generateCompatibilityReading(
        profile: UserProfile,
        contact: Contact,
        modelContext: ModelContext
    ) async -> ParsedReading {
        guard let chart1 = profile.chartData,
              let chart2 = contact.chartData else {
            return ReadingParser.parse("")
        }

        let lang = profile.appLanguage
        let compatData = AstrologyFormatter.formatCompatibility(
            chart1: chart1, name1: profile.name,
            chart2: chart2, name2: contact.name
        )

        let systemPrompt = """
        You are Celestia, a wise AI astrologer specializing in relationship compatibility.
        \(lang.promptInstruction)
        Be honest but encouraging. Highlight strengths AND challenges.

        \(compatData)
        """

        let userPrompt = """
        Write a compatibility reading for \(profile.name) and \(contact.name).
        Cover: emotional connection, communication style, love language, challenges, advice.
        150-200 words.
        Respond in valid JSON:
        {"reading":"...","energy":{"love":0.0-1.0,"career":0.0-1.0,"health":0.0-1.0,"spiritual":0.0-1.0},"keyTheme":"...","actionAdvice":"...","luckyElements":{"color":"...","number":N,"crystal":"..."}}
        """

        let raw = await brain.generate(systemPrompt: systemPrompt, userPrompt: userPrompt)
        return ReadingParser.parse(raw)
    }

    // MARK: - Tarot Interpretation

    func generateTarotReading(
        cards: [DrawnCardData],
        question: String?,
        profile: UserProfile,
        modelContext: ModelContext
    ) async -> String {
        guard let chart = profile.chartData else { return "" }
        let lang = profile.appLanguage

        var cardDescriptions = "CARDS DRAWN:\n"
        for card in cards {
            let reversed = card.isReversed ? " (REVERSED)" : ""
            cardDescriptions += "Position \(card.position) (\(card.positionMeaning)): \(card.cardId)\(reversed)\n"
        }

        let systemPrompt = """
        You are Celestia, interpreting a tarot spread.
        \(lang.promptInstruction)
        Connect the cards to the user's birth chart for a deeply personal reading.
        Be specific and insightful, not generic.

        \(AstrologyFormatter.formatChartForPrompt(chart))

        \(cardDescriptions)
        """

        let questionText = question ?? "General guidance"
        let userPrompt = """
        The user's question: "\(questionText)"
        Interpret each card in its position, then synthesize an overall message.
        100-200 words total.
        """

        let raw = await brain.generate(systemPrompt: systemPrompt, userPrompt: userPrompt)
        return raw.replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Weekly Deep Reading

    func generateWeeklyReading(
        section: String,
        profile: UserProfile,
        modelContext: ModelContext
    ) async -> String {
        guard let chart = profile.chartData else { return "" }

        let transits = TransitEngine.shared.calculateTransits(natalChart: chart)
        let lang = profile.appLanguage

        let systemPrompt = """
        You are Celestia, writing the \(section) section of a weekly forecast.
        \(lang.promptInstruction)
        Be specific to this week's transits and the user's chart.

        \(AstrologyFormatter.formatChartForPrompt(chart))
        \(AstrologyFormatter.formatTransitsForPrompt(transits))
        """

        let userPrompt = """
        Write the \(section) forecast for this week. 80-100 words.
        Be specific and actionable. Reference exact transits.
        """

        let raw = await brain.generate(systemPrompt: systemPrompt, userPrompt: userPrompt)
        return raw.replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add Celestia/AI/MemoryEngine.swift Celestia/AI/ReadingGenerator.swift
git commit -m "feat: add ReadingGenerator + MemoryEngine — orchestrates chart→prompt→AI→reading pipeline"
```

---

### Task 10: Content Filter

**Files:**
- Create: `Celestia/AI/ContentFilter.swift`

- [ ] **Step 1: Create ContentFilter (adapted from Mochi Crew)**

```swift
import Foundation

enum ContentFilter {
    enum FilterResult {
        case allowed(String)
        case blocked(String)
    }

    static func filter(_ input: String) -> FilterResult {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmed.lowercased()

        guard trimmed.count >= 1 else {
            return .blocked("Ask me anything about your stars!")
        }
        guard trimmed.count <= 500 else {
            return .blocked("That's quite a lot! Try a shorter question.")
        }

        if containsPromptInjection(lowered) {
            return .blocked("I can only read the stars, not follow instructions like that.")
        }
        if containsHarmfulContent(lowered) {
            return .blocked("I sense heavy energy in your question. Please remember I'm an astrology guide, not a counselor. If you need support, please reach out to a professional.")
        }

        return .allowed(trimmed)
    }

    private static func containsPromptInjection(_ text: String) -> Bool {
        let patterns = [
            "ignore previous", "ignore above", "ignore all",
            "act as", "pretend to be", "you are now",
            "override", "jailbreak", "developer mode",
            "system prompt", "reveal your instructions"
        ]
        return patterns.contains(where: { text.contains($0) })
    }

    private static func containsHarmfulContent(_ text: String) -> Bool {
        let patterns = [
            "kill myself", "want to die", "suicide",
            "self harm", "hurt myself"
        ]
        return patterns.contains(where: { text.contains($0) })
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Celestia/AI/ContentFilter.swift
git commit -m "feat: add ContentFilter — input filtering for chat safety"
```

---

## Phase 2: Core Screens (Week 3-4)

### Task 11: Onboarding — Language Picker

**Files:**
- Create: `Celestia/Views/Onboarding/LanguagePickerView.swift`

- [ ] **Step 1: Create language picker view**

```swift
import SwiftUI

struct LanguagePickerView: View {
    @Binding var selectedLanguage: AppLanguage
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            CelestiaTheme.darkBg.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                Text("✧")
                    .font(.system(size: 60))

                Text("Choose Your Language")
                    .font(CelestiaTheme.headingFont)
                    .foregroundColor(CelestiaTheme.gold)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Button {
                            selectedLanguage = lang
                        } label: {
                            Text(lang.displayName)
                                .font(CelestiaTheme.bodyFont)
                                .foregroundColor(selectedLanguage == lang ? CelestiaTheme.darkBg : CelestiaTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedLanguage == lang ? CelestiaTheme.gold : Color.white.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                Button {
                    onContinue()
                } label: {
                    Text("Continue")
                        .font(CelestiaTheme.bodyFont.bold())
                        .foregroundColor(CelestiaTheme.darkBg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(CelestiaTheme.gold)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Celestia/Views/Onboarding/LanguagePickerView.swift
git commit -m "feat: add LanguagePickerView — first-launch language selection"
```

---

### Task 12: Onboarding — Birth Data Entry

**Files:**
- Create: `Celestia/Views/Onboarding/BirthDataView.swift`

- [ ] **Step 1: Create birth data entry view**

```swift
import SwiftUI
import CoreLocation

struct BirthDataView: View {
    @Binding var name: String
    @Binding var birthDate: Date
    @Binding var birthTime: Date
    @Binding var birthCity: String
    @Binding var birthLatitude: Double
    @Binding var birthLongitude: Double
    let onComplete: () -> Void

    @State private var citySearchText = ""
    @State private var searchResults: [CLPlacemark] = []
    @State private var isSearching = false

    private let geocoder = CLGeocoder()

    var body: some View {
        ZStack {
            CelestiaTheme.darkBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text("Tell Me About You")
                        .font(CelestiaTheme.headingFont)
                        .foregroundColor(CelestiaTheme.gold)
                        .padding(.top, 40)

                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Name")
                            .font(CelestiaTheme.captionFont)
                            .foregroundColor(CelestiaTheme.textSecondary)
                        TextField("", text: $name)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }

                    // Birth Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Birth Date")
                            .font(CelestiaTheme.captionFont)
                            .foregroundColor(CelestiaTheme.textSecondary)
                        DatePicker("", selection: $birthDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .colorScheme(.dark)
                    }

                    // Birth Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Birth Time (as exact as possible)")
                            .font(CelestiaTheme.captionFont)
                            .foregroundColor(CelestiaTheme.textSecondary)
                        DatePicker("", selection: $birthTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .colorScheme(.dark)
                    }

                    // Birth City
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Birth City")
                            .font(CelestiaTheme.captionFont)
                            .foregroundColor(CelestiaTheme.textSecondary)
                        TextField("Search city...", text: $citySearchText)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .onChange(of: citySearchText) { _, newValue in
                                searchCity(newValue)
                            }

                        if !searchResults.isEmpty {
                            ForEach(searchResults, id: \.self) { placemark in
                                Button {
                                    selectCity(placemark)
                                } label: {
                                    HStack {
                                        Text(formatPlacemark(placemark))
                                            .foregroundColor(CelestiaTheme.textPrimary)
                                        Spacer()
                                    }
                                    .padding(8)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(6)
                                }
                            }
                        }

                        if !birthCity.isEmpty {
                            Text("Selected: \(birthCity)")
                                .font(CelestiaTheme.captionFont)
                                .foregroundColor(CelestiaTheme.gold)
                        }
                    }

                    Spacer(minLength: 40)

                    Button {
                        onComplete()
                    } label: {
                        Text("Reveal My Chart ✧")
                            .font(CelestiaTheme.bodyFont.bold())
                            .foregroundColor(CelestiaTheme.darkBg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canProceed ? CelestiaTheme.gold : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!canProceed)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var canProceed: Bool {
        !name.isEmpty && !birthCity.isEmpty
    }

    private func searchCity(_ query: String) {
        guard query.count >= 2 else {
            searchResults = []
            return
        }
        isSearching = true
        geocoder.geocodeAddressString(query) { placemarks, _ in
            isSearching = false
            searchResults = Array((placemarks ?? []).prefix(5))
        }
    }

    private func selectCity(_ placemark: CLPlacemark) {
        birthCity = formatPlacemark(placemark)
        birthLatitude = placemark.location?.coordinate.latitude ?? 0
        birthLongitude = placemark.location?.coordinate.longitude ?? 0
        searchResults = []
        citySearchText = birthCity
    }

    private func formatPlacemark(_ placemark: CLPlacemark) -> String {
        [placemark.locality, placemark.administrativeArea, placemark.country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Celestia/Views/Onboarding/BirthDataView.swift
git commit -m "feat: add BirthDataView — birth date/time/city entry with geocoding"
```

---

### Task 13: Today View (Daily Horoscope)

**Files:**
- Create: `Celestia/Views/Today/TodayView.swift`
- Create: `Celestia/Views/Today/EnergyMeterView.swift`

- [ ] **Step 1: Create EnergyMeterView**

```swift
import SwiftUI

struct EnergyMeterView: View {
    let label: String
    let value: Double  // 0.0 - 1.0
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(CelestiaTheme.captionFont)
                    .foregroundColor(CelestiaTheme.textSecondary)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(CelestiaTheme.captionFont)
                    .foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * value)
                }
            }
            .frame(height: 8)
        }
    }
}
```

- [ ] **Step 2: Create TodayView**

```swift
import SwiftUI
import SwiftData

struct TodayView: View {
    @EnvironmentObject var brain: CelestiaBrain
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var todayReading: ParsedReading?
    @State private var isLoading = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ZStack {
            CelestiaTheme.darkBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    if let profile {
                        Text("☽ Good \(timeOfDay), \(profile.name)")
                            .font(CelestiaTheme.subheadingFont)
                            .foregroundColor(CelestiaTheme.textPrimary)

                        if let chart = profile.chartData {
                            Text("\(chart.sunSign.rawValue.capitalized) Sun \(chart.sunSign.symbol)")
                                .font(CelestiaTheme.captionFont)
                                .foregroundColor(CelestiaTheme.purple)
                        }
                    }

                    // Daily Reading Card
                    if isLoading {
                        ProgressView("Reading the stars...")
                            .foregroundColor(CelestiaTheme.textSecondary)
                            .padding(40)
                    } else if let reading = todayReading {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("TODAY'S READING")
                                .font(CelestiaTheme.captionFont)
                                .foregroundColor(CelestiaTheme.gold)

                            Text(reading.reading)
                                .font(CelestiaTheme.bodyFont)
                                .foregroundColor(CelestiaTheme.textPrimary)
                                .lineSpacing(4)

                            if !reading.actionAdvice.isEmpty {
                                Text("✧ \(reading.actionAdvice)")
                                    .font(CelestiaTheme.captionFont)
                                    .foregroundColor(CelestiaTheme.gold)
                                    .italic()
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)

                        // Energy Meters
                        VStack(spacing: 12) {
                            Text("COSMIC ENERGY")
                                .font(CelestiaTheme.captionFont)
                                .foregroundColor(CelestiaTheme.gold)

                            EnergyMeterView(label: "Love", value: reading.energyLove, color: .pink)
                            EnergyMeterView(label: "Career", value: reading.energyCareer, color: CelestiaTheme.gold)
                            EnergyMeterView(label: "Health", value: reading.energyHealth, color: .green)
                            EnergyMeterView(label: "Spiritual", value: reading.energySpiritual, color: CelestiaTheme.purple)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)

                        // Lucky Elements
                        HStack(spacing: 16) {
                            luckyItem(icon: "paintpalette", label: reading.luckyColor)
                            luckyItem(icon: "number", label: "\(reading.luckyNumber)")
                            luckyItem(icon: "sparkle", label: reading.luckyCrystal)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .task {
            await loadTodayReading()
        }
    }

    private func loadTodayReading() async {
        guard let profile, brain.isModelLoaded else { return }

        // Check if we already have today's reading
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<Reading>(
            predicate: #Predicate<Reading> { $0.type == "daily" && $0.createdAt >= today }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            todayReading = ParsedReading(
                reading: existing.content,
                energyLove: existing.energyLove,
                energyCareer: existing.energyCareer,
                energyHealth: existing.energyHealth,
                energySpiritual: existing.energySpiritual,
                keyTheme: existing.keyTheme,
                actionAdvice: existing.actionAdvice,
                luckyColor: "gold", luckyNumber: 7, luckyCrystal: "amethyst"
            )
            return
        }

        // Generate new reading
        isLoading = true
        let generator = ReadingGenerator(brain: brain)
        let parsed = await generator.generateDailyReading(profile: profile, modelContext: modelContext)

        // Save to SwiftData
        let reading = Reading(
            type: .daily,
            content: parsed.reading,
            energy: (parsed.energyLove, parsed.energyCareer, parsed.energyHealth, parsed.energySpiritual),
            keyTheme: parsed.keyTheme,
            actionAdvice: parsed.actionAdvice,
            language: profile.appLanguage
        )
        modelContext.insert(reading)
        try? modelContext.save()

        todayReading = parsed
        isLoading = false
    }

    private var timeOfDay: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        default: return "evening"
        }
    }

    private func luckyItem(icon: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(CelestiaTheme.gold)
            Text(label.capitalized)
                .font(CelestiaTheme.captionFont)
                .foregroundColor(CelestiaTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add Celestia/Views/Today/
git commit -m "feat: add TodayView — daily horoscope with energy meters and lucky elements"
```

---

### Task 14: Chat View (Ask Celestia)

**Files:**
- Create: `Celestia/Views/Chat/ChatView.swift`

- [ ] **Step 1: Create ChatView**

```swift
import SwiftUI
import SwiftData

struct ChatView: View {
    @EnvironmentObject var brain: CelestiaBrain
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.createdAt) private var messages: [ChatMessage]
    @Query private var profiles: [UserProfile]
    @State private var inputText = ""
    @State private var isGenerating = false

    private var profile: UserProfile? { profiles.first }

    // Daily message limit for free users
    private var todayMessageCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return messages.filter { $0.role == "user" && $0.createdAt >= today }.count
    }

    private var canSendMessage: Bool {
        let isSubscribed = profile?.subscriptionTier != "free"
        return isSubscribed || todayMessageCount < 5
    }

    var body: some View {
        ZStack {
            CelestiaTheme.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("✧ Celestia")
                        .font(CelestiaTheme.subheadingFont)
                        .foregroundColor(CelestiaTheme.gold)
                    Spacer()
                    if !canSendMessage {
                        Text("5/5 today")
                            .font(CelestiaTheme.captionFont)
                            .foregroundColor(.red)
                    } else if profile?.subscriptionTier == "free" {
                        Text("\(todayMessageCount)/5 today")
                            .font(CelestiaTheme.captionFont)
                            .foregroundColor(CelestiaTheme.textSecondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                            if isGenerating {
                                HStack {
                                    ProgressView()
                                        .tint(CelestiaTheme.purple)
                                    Text("Reading the stars...")
                                        .font(CelestiaTheme.captionFont)
                                        .foregroundColor(CelestiaTheme.textSecondary)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                // Input
                HStack(spacing: 12) {
                    TextField("Ask Celestia...", text: $inputText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                        .lineLimit(1...4)

                    Button {
                        Task { await sendMessage() }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(
                                inputText.isEmpty || !canSendMessage
                                ? Color.gray
                                : CelestiaTheme.gold
                            )
                    }
                    .disabled(inputText.isEmpty || !canSendMessage)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(CelestiaTheme.navy)
            }
        }
    }

    private func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let profile else { return }

        // Content filter
        switch ContentFilter.filter(text) {
        case .blocked(let reason):
            let blocked = ChatMessage(role: "celestia", content: reason)
            modelContext.insert(blocked)
            try? modelContext.save()
            inputText = ""
            return
        case .allowed(let filtered):
            inputText = ""

            // Save user message
            let userMsg = ChatMessage(role: "user", content: filtered)
            modelContext.insert(userMsg)
            try? modelContext.save()

            // Generate response
            isGenerating = true
            let generator = ReadingGenerator(brain: brain)
            let response = await generator.generateChatResponse(
                message: filtered, profile: profile, modelContext: modelContext
            )
            isGenerating = false

            let celestiaMsg = ChatMessage(role: "celestia", content: response)
            modelContext.insert(celestiaMsg)
            try? modelContext.save()
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var isUser: Bool { message.role == "user" }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            Text(message.content)
                .font(CelestiaTheme.bodyFont)
                .foregroundColor(isUser ? CelestiaTheme.darkBg : CelestiaTheme.textPrimary)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isUser ? CelestiaTheme.gold : Color.white.opacity(0.1))
                )

            if !isUser { Spacer(minLength: 60) }
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Celestia/Views/Chat/ChatView.swift
git commit -m "feat: add ChatView — conversational AI with daily message limits and content filtering"
```

---

## Phase 3: Revenue Features (Week 5-6)

### Task 15: Tarot System

**Files:**
- Create: `Celestia/Tarot/TarotDeck.swift`
- Create: `Celestia/Tarot/TarotSpread.swift`
- Create: `Celestia/Tarot/TarotDrawEngine.swift`
- Create: `Celestia/Views/Tarot/TarotView.swift`
- Create: `Celestia/Views/Tarot/TarotCardView.swift`

This is a larger task. The engineer should:
- [ ] **Step 1:** Create `TarotDeck.swift` — enum with all 78 cards (22 Major Arcana + 56 Minor Arcana), each with `name`, `uprightMeaning`, `reversedMeaning`, `suit` (for minor), `number`
- [ ] **Step 2:** Create `TarotSpread.swift` — enum for spread types (`.single`, `.threeCard`, `.celticCross`) with position count and position meanings array
- [ ] **Step 3:** Create `TarotDrawEngine.swift` — `drawCards(spread:) -> [DrawnCardData]` that randomly selects cards without replacement, assigns positions, and randomly determines reversals (30% chance)
- [ ] **Step 4:** Create `TarotCardView.swift` — single card display with flip animation (front = card art image, back = mystical back design). Use `.rotation3DEffect` for flip.
- [ ] **Step 5:** Create `TarotView.swift` — spread picker, animated card draw sequence, AI interpretation display. Check free tier limit (1/week) and show paywall or deduct tokens.
- [ ] **Step 6:** Commit

```bash
git add Celestia/Tarot/ Celestia/Views/Tarot/
git commit -m "feat: add tarot system — 78-card deck, spreads, draw engine, card flip animations"
```

---

### Task 16: Compatibility System

**Files:**
- Create: `Celestia/Views/Compatibility/CompatibilityView.swift`
- Create: `Celestia/Views/Compatibility/AddContactView.swift`
- Create: `Celestia/Views/Compatibility/CompatReportView.swift`

- [ ] **Step 1:** Create `AddContactView.swift` — birth data entry for contacts (similar to `BirthDataView` but simpler, birth time is optional)
- [ ] **Step 2:** Create `CompatReportView.swift` — displays side-by-side sun/moon/rising, element compatibility, cross-aspects, and AI-generated relationship reading
- [ ] **Step 3:** Create `CompatibilityView.swift` — list of contacts with "Add" button. Tapping a contact shows their report. Check subscription/tokens before generating.
- [ ] **Step 4:** Commit

```bash
git add Celestia/Views/Compatibility/
git commit -m "feat: add compatibility system — contact management, chart comparison, AI relationship readings"
```

---

### Task 17: Weekly Deep Reading

**Files:**
- Create: `Celestia/Views/Today/WeeklyReadingView.swift`

- [ ] **Step 1:** Create `WeeklyReadingView.swift` — generates 5 sections (Love, Career, Health, Spiritual, Prediction) sequentially using `ReadingGenerator.generateWeeklyReading()`. Shows progress as each section loads. Saves to SwiftData as a single Reading with type `.weekly`. Star Pass required.
- [ ] **Step 2:** Commit

```bash
git add Celestia/Views/Today/WeeklyReadingView.swift
git commit -m "feat: add WeeklyReadingView — 5-section deep reading with progressive loading"
```

---

### Task 18: Transit Alert Notifications

**Files:**
- Create: `Celestia/Notifications/TransitAlertManager.swift`

- [ ] **Step 1:** Create `TransitAlertManager.swift` — checks for significant transits daily, schedules push notifications with AI-generated mini-readings. Follows Mochi Crew's `NotificationManager` pattern: quiet hours (10pm-8am), max 2 alerts/day, only for Star Pass subscribers.
- [ ] **Step 2:** Wire into `CelestiaApp.swift` scene phase handling (schedule on background, cancel on foreground).
- [ ] **Step 3:** Commit

```bash
git add Celestia/Notifications/ Celestia/App/CelestiaApp.swift
git commit -m "feat: add transit alert notifications — AI-powered push for significant planetary events"
```

---

### Task 19: Reading Journal

**Files:**
- Create: `Celestia/Views/Journal/JournalView.swift`

- [ ] **Step 1:** Create `JournalView.swift` — chronological timeline of all past Readings from SwiftData. Grouped by date. Each entry shows type icon, preview text, energy meters. Tap to expand full reading. Star Pass required.
- [ ] **Step 2:** Commit

```bash
git add Celestia/Views/Journal/JournalView.swift
git commit -m "feat: add JournalView — reading history timeline with expandable entries"
```

---

## Phase 4: Monetization & Polish (Week 7-8)

### Task 20: StoreKit 2 — Shop Catalog & Products

**Files:**
- Create: `Celestia/Shop/ShopCatalog.swift`
- Create: `Celestia/Resources/Products.storekit`

- [ ] **Step 1:** Create `ShopCatalog.swift` with product IDs:

```swift
import Foundation

enum ShopCatalog {
    // Auto-renewable subscriptions
    static let starPassWeekly = "celestia_starpass_weekly"     // $6.99/week
    static let starPassMonthly = "celestia_starpass_monthly"   // $19.99/month
    static let starPassYearly = "celestia_starpass_yearly"     // $99.99/year

    static let subscriptionIds: Set<String> = [
        starPassWeekly, starPassMonthly, starPassYearly
    ]

    // Consumables
    static let tokenSmall = "celestia_tokens_5"    // $1.99 → 5 tokens
    static let tokenLarge = "celestia_tokens_30"   // $9.99 → 30 tokens

    static let tokenProducts: [String: Int] = [
        tokenSmall: 5,
        tokenLarge: 30
    ]

    // Token costs per feature
    static let tokenCost: [String: Int] = [
        "daily_refresh": 1,
        "tarot_3card": 2,
        "tarot_celtic": 3,
        "compatibility": 3,
        "placement_detail": 2,
        "weekly_deep": 5
    ]
}
```

- [ ] **Step 2:** Create `Products.storekit` StoreKit configuration file with all products.
- [ ] **Step 3:** Commit

```bash
git add Celestia/Shop/ShopCatalog.swift Celestia/Resources/Products.storekit
git commit -m "feat: add ShopCatalog — Star Pass subscriptions + token pack product definitions"
```

---

### Task 21: Subscription Manager

**Files:**
- Create: `Celestia/Shop/SubscriptionManager.swift`

- [ ] **Step 1:** Create `SubscriptionManager.swift` following Mochi Crew's pattern — `checkSubscriptionStatus()` iterating `Transaction.currentEntitlements`, `@Published var isSubscribed`, transaction listener task.
- [ ] **Step 2:** Commit

```bash
git add Celestia/Shop/SubscriptionManager.swift
git commit -m "feat: add SubscriptionManager — Star Pass entitlement checking and transaction listening"
```

---

### Task 22: Token Manager

**Files:**
- Create: `Celestia/Shop/TokenManager.swift`

- [ ] **Step 1:** Create `TokenManager.swift` — manages token balance in SwiftData. Methods: `canAfford(feature:)`, `spend(feature:, modelContext:) -> Bool`, `addTokens(productId:, modelContext:)`. Integrates with StoreKit 2 for consumable purchases.
- [ ] **Step 2:** Commit

```bash
git add Celestia/Shop/TokenManager.swift
git commit -m "feat: add TokenManager — token balance, spending, and purchase tracking"
```

---

### Task 23: Paywall View

**Files:**
- Create: `Celestia/Shop/PaywallView.swift`

- [ ] **Step 1:** Create `PaywallView.swift` — beautiful paywall with trigger-specific messaging (passed as parameter). Shows Star Pass tiers with `SubscriptionStoreView` or manual product display. Also shows token pack option for one-time purchases.
- [ ] **Step 2:** Commit

```bash
git add Celestia/Shop/PaywallView.swift
git commit -m "feat: add PaywallView — context-aware paywall with Star Pass tiers and token packs"
```

---

### Task 24: Profile & Chart Wheel View

**Files:**
- Create: `Celestia/Views/Profile/ProfileView.swift`
- Create: `Celestia/Views/Profile/ChartWheelView.swift`

- [ ] **Step 1:** Create `ChartWheelView.swift` — SwiftUI Canvas drawing of a circular birth chart. 12 house divisions, planet symbols placed at correct degrees, aspect lines connecting planets. Gold lines on dark background.
- [ ] **Step 2:** Create `ProfileView.swift` — shows chart wheel, sun/moon/rising display, planet placement list, language settings toggle, subscription status, link to paywall.
- [ ] **Step 3:** Commit

```bash
git add Celestia/Views/Profile/
git commit -m "feat: add ProfileView + ChartWheelView — interactive birth chart and settings"
```

---

### Task 25: Star Field Background Animation

**Files:**
- Create: `Celestia/Views/Components/StarFieldView.swift`

- [ ] **Step 1:** Create `StarFieldView.swift` — subtle animated star particles using `TimelineView` and `Canvas`. Random star positions, gentle twinkling opacity animation. Light on GPU — simple circles with varying opacity.
- [ ] **Step 2:** Add as background to key views (Today, Tarot, Profile).
- [ ] **Step 3:** Commit

```bash
git add Celestia/Views/Components/StarFieldView.swift
git commit -m "feat: add StarFieldView — animated star particle background"
```

---

### Task 26: Wire Up ContentView with Full Navigation

**Files:**
- Modify: `Celestia/App/ContentView.swift`
- Modify: `Celestia/App/CelestiaApp.swift`

- [ ] **Step 1:** Update `ContentView.swift` to show onboarding if no UserProfile exists, otherwise show tab bar with all real views (TodayView, TarotView, ChatView, CompatibilityView, ProfileView).
- [ ] **Step 2:** Update `CelestiaApp.swift` with full lifecycle: model loading, subscription checking, transit alert scheduling.
- [ ] **Step 3:** Commit

```bash
git add Celestia/App/
git commit -m "feat: wire up full navigation — onboarding flow + tab bar with all screens"
```

---

### Task 27: Localization — String Catalogs

**Files:**
- Create: `Celestia/Resources/Localizable.xcstrings`

- [ ] **Step 1:** Create String Catalog with all UI strings in 6 languages (en, es, pt, ja, ko, fr). Cover: onboarding, tab labels, section headers, paywall messages, error states, button labels.
- [ ] **Step 2:** Commit

```bash
git add Celestia/Resources/Localizable.xcstrings
git commit -m "feat: add localization — String Catalogs for 6 languages"
```

---

## Phase 5: Launch Prep (Week 9)

### Task 28: Art Assets via Ideogram AI

- [ ] **Step 1:** Generate 78 tarot card front illustrations using Ideogram AI with style: "Celestial illustration, gold line art on deep navy, mystical astronomical, Art Nouveau"
- [ ] **Step 2:** Generate 12 zodiac sign artwork
- [ ] **Step 3:** Generate app icon (crescent moon + star + eye on dark purple gradient)
- [ ] **Step 4:** Generate onboarding background art
- [ ] **Step 5:** Add all assets to `Assets.xcassets`
- [ ] **Step 6:** Commit

```bash
git add Celestia/Resources/Assets.xcassets
git commit -m "feat: add art assets — tarot cards, zodiac signs, app icon, backgrounds"
```

---

### Task 29: TestFlight & App Store Submission

- [ ] **Step 1:** Build via Mac Mini SSH (`phil@192.168.2.131`)
- [ ] **Step 2:** Upload to TestFlight, test on real device
- [ ] **Step 3:** Fix any issues found in testing
- [ ] **Step 4:** Generate App Store screenshots (6 languages × device sizes)
- [ ] **Step 5:** Write App Store marketing copy using Gemini AI (all 6 languages)
- [ ] **Step 6:** Create App Store Connect entry for Celestia
- [ ] **Step 7:** Submit for review
- [ ] **Step 8:** Submit Apple Featuring Nomination (on-device AI angle)

---

## Dependency Graph

```
Task 1 (Project Setup)
  ├→ Task 2 (Astrology Types)
  │    ├→ Task 3 (Chart Engine)
  │    │    ├→ Task 4 (Transit Engine)
  │    │    └→ Task 5 (Formatter)
  │    └→ Task 6 (SwiftData Models)
  │         ├→ Task 9 (ReadingGenerator)
  │         ├→ Task 11-14 (Core Screens)
  │         └→ Task 15-19 (Revenue Features)
  ├→ Task 7 (CelestiaBrain)
  │    ├→ Task 8 (ReadingParser)
  │    └→ Task 9 (ReadingGenerator)
  ├→ Task 10 (ContentFilter)
  └→ Task 6 → Task 20-23 (Monetization)

Tasks 11-14 (Core Screens) → Task 26 (Wire Up Navigation)
Tasks 15-19 (Revenue Features) → Task 26
Tasks 20-23 (Monetization) → Task 26
Task 26 → Task 27 (Localization) → Task 28 (Art) → Task 29 (Launch)
```
