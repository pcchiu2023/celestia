# Caelus Visual Character — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a mood-reactive visual character that appears alongside all readings in the Caelus astrology app.

**Architecture:** Pure function mood router (`CaelusMoodRouter`) computes mood from existing reading data. Each view passes mood to `CaelusCharacterView` as a parameter. No shared state. Images preloaded via NSCache on launch.

**Tech Stack:** Swift/SwiftUI, NSCache, Asset Catalogs

**Spec:** `docs/superpowers/specs/2026-03-28-caelus-visual-character-design.md`

---

## Pre-requisite: Art Assets

Before coding begins, the character images must be generated via Ideogram AI. This is a manual step performed by the user (Phil).

**Required assets (minimum viable):**
- `caelus_welcoming.png` (1x/2x/3x)
- `caelus_thoughtful.png` (1x/2x/3x)
- `caelus_encouraging.png` (1x/2x/3x)
- `caelus_serious.png` (1x/2x/3x)
- `caelus_mystical.png` (1x/2x/3x)
- `caelus_excited.png` (1x/2x/3x)
- `caelus_compassionate.png` (1x/2x/3x)
- `caelus_neutral.png` (1x/2x/3x)

Place in: `Celestia/Resources/Assets.xcassets/Character/`

**For development/testing:** Use placeholder colored rectangles until real art is ready. The code will work with or without final assets.

---

### Task 1: Create CaelusMood Enum + MoodRouter

**Files:**
- Create: `Celestia/Character/CaelusMood.swift`

- [ ] **Step 1: Create the Character directory**

```bash
mkdir -p Celestia/Character
```

- [ ] **Step 2: Write CaelusMood enum**

```swift
import Foundation

// MARK: - Mood States

enum CaelusMood: String, CaseIterable {
    case welcoming, thoughtful, encouraging, serious
    case mystical, excited, compassionate, neutral

    var imageName: String { "caelus_\(rawValue)" }

    /// Number of art variants available per mood (for randomization)
    var variantCount: Int {
        switch self {
        case .thoughtful, .encouraging, .mystical: return 3
        case .welcoming, .neutral: return 2
        default: return 1
        }
    }

    /// Returns a random variant image name (e.g., "caelus_thoughtful" or "caelus_thoughtful_2")
    func randomImageName() -> String {
        let count = variantCount
        guard count > 1 else { return imageName }
        let variant = Int.random(in: 1...count)
        return variant == 1 ? imageName : "\(imageName)_\(variant)"
    }
}
```

- [ ] **Step 3: Write CaelusMoodRouter (pure function namespace)**

Add to the same file:

```swift
// MARK: - Mood Router (Pure Functions)

enum CaelusMoodRouter {

    // MARK: - Daily / Weekly Readings
    /// Routes mood based on energy scores (0-1 scale) and keyTheme string
    static func resolve(
        energyLove: Double,
        energyCareer: Double,
        energyHealth: Double,
        energySpiritual: Double,
        keyTheme: String
    ) -> CaelusMood {
        let scores = [energyLove, energyCareer, energyHealth, energySpiritual]
        let avg = scores.reduce(0, +) / Double(scores.count)
        let anyLow = scores.contains(where: { $0 <= 0.3 })
        let anyPerfect = scores.contains(where: { $0 >= 1.0 })

        // Hierarchy: Compassionate > Serious > Excited > Encouraging > Mystical > Thoughtful
        if anyLow { return .compassionate }
        if avg >= 0.85 && anyPerfect { return .excited }
        if avg >= 0.65 { return .encouraging }

        let theme = keyTheme.lowercased()
        if theme.contains("transform") || theme.contains("spiritual") || theme.contains("mystic") {
            return .mystical
        }
        if theme.contains("challenge") || theme.contains("tension") || theme.contains("conflict") {
            return .serious
        }

        return .thoughtful
    }

    // MARK: - Tarot Readings
    /// Routes mood based on drawn tarot cards
    static func resolveForTarot(
        cardNames: [String],
        reversedCount: Int,
        totalCards: Int,
        keyTheme: String
    ) -> CaelusMood {
        let painCards: Set<String> = [
            "Three of Swords", "Ten of Swords", "The Tower",
            "Five of Cups", "Five of Pentacles", "Nine of Swords"
        ]
        let joyCards: Set<String> = [
            "The Sun", "The Star", "The World",
            "Ace of Cups", "Ten of Cups", "The Empress"
        ]

        let hasPainCard = cardNames.contains(where: { painCards.contains($0) })
        let hasJoyCard = cardNames.contains(where: { joyCards.contains($0) })
        let reversedRatio = totalCards > 0 ? Double(reversedCount) / Double(totalCards) : 0

        if hasPainCard { return .compassionate }
        if reversedRatio >= 0.5 { return .serious }
        if hasJoyCard { return .excited }
        return .mystical
    }

    // MARK: - Compatibility
    /// Routes mood based on compatibility reading energy
    static func resolveForCompatibility(energyLove: Double) -> CaelusMood {
        if energyLove < 0.4 { return .compassionate }
        if energyLove >= 0.9 { return .excited }
        if energyLove >= 0.7 { return .encouraging }
        return .thoughtful
    }

    // MARK: - Chat
    /// Routes mood based on AI chat response text
    static func resolveForChat(responseText: String) -> CaelusMood {
        let text = responseText.lowercased()
        let sadKeywords = ["difficult", "loss", "grief", "struggle", "pain", "sorry", "challenging"]
        let excitedKeywords = ["amazing", "wonderful", "fantastic", "incredible", "excellent", "brilliant"]
        let spiritualKeywords = ["destiny", "karma", "past life", "spiritual", "divine", "cosmic"]

        if sadKeywords.contains(where: { text.contains($0) }) { return .compassionate }
        if excitedKeywords.contains(where: { text.contains($0) }) { return .excited }
        if spiritualKeywords.contains(where: { text.contains($0) }) { return .mystical }
        return .encouraging
    }

    // MARK: - App Lifecycle
    static let appLaunch: CaelusMood = .welcoming
    static let settingsScreen: CaelusMood = .thoughtful
    static let fallback: CaelusMood = .neutral
}
```

- [ ] **Step 4: Verify file compiles**

The file should have no dependencies beyond Foundation. Verify no syntax errors.

- [ ] **Step 5: Commit**

```bash
git add Celestia/Character/CaelusMood.swift
git commit -m "feat: add CaelusMood enum and MoodRouter pure functions"
```

---

### Task 2: Create CaelusImageCache

**Files:**
- Create: `Celestia/Character/CaelusImageCache.swift`

- [ ] **Step 1: Write CaelusImageCache**

```swift
import UIKit

/// Preloads and caches all Caelus character images in NSCache.
/// Called once on app launch. System can evict under memory pressure.
final class CaelusImageCache {
    static let shared = CaelusImageCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 30  // max ~18 images + variants
    }

    /// Preload all mood images into cache. Call from CelestiaApp.init().
    func preloadAll() {
        for mood in CaelusMood.allCases {
            // Load base image
            loadImage(named: mood.imageName)
            // Load variants
            for variant in 2...mood.variantCount {
                loadImage(named: "\(mood.imageName)_\(variant)")
            }
        }
    }

    /// Retrieve cached image for a mood (with optional variant)
    func image(for imageName: String) -> UIImage? {
        if let cached = cache.object(forKey: imageName as NSString) {
            return cached
        }
        // Fallback: try loading directly (may have been evicted)
        return loadImage(named: imageName)
    }

    @discardableResult
    private func loadImage(named name: String) -> UIImage? {
        guard let img = UIImage(named: name) else { return nil }
        cache.setObject(img, forKey: name as NSString)
        return img
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Celestia/Character/CaelusImageCache.swift
git commit -m "feat: add CaelusImageCache for preloading character art"
```

---

### Task 3: Create CaelusCharacterView

**Files:**
- Create: `Celestia/Character/CaelusCharacterView.swift`

- [ ] **Step 1: Write CaelusCharacterView**

```swift
import SwiftUI

/// Displays the Caelus character with mood-reactive image and smooth transitions.
struct CaelusCharacterView: View {
    let mood: CaelusMood
    var size: CGFloat = 200
    var showShadow: Bool = true

    @State private var currentImageName: String = ""

    var body: some View {
        Group {
            if let uiImage = CaelusImageCache.shared.image(for: currentImageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                // Placeholder while assets are missing (development)
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(CelestiaTheme.purple.opacity(0.3))
            }
        }
        .frame(height: size)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(CelestiaTheme.gold.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: CelestiaTheme.purple.opacity(showShadow ? 0.2 : 0), radius: 12, y: 4)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .animation(.easeInOut(duration: 0.4), value: currentImageName)
        .id(currentImageName)
        .onAppear { currentImageName = mood.randomImageName() }
        .onChange(of: mood) { _, newMood in
            withAnimation(.easeInOut(duration: 0.4)) {
                currentImageName = newMood.randomImageName()
            }
        }
    }
}

// MARK: - Previews

#Preview("Welcoming") {
    CaelusCharacterView(mood: .welcoming)
        .padding()
        .background(CelestiaTheme.darkBg)
}

#Preview("Mystical") {
    CaelusCharacterView(mood: .mystical, size: 160)
        .padding()
        .background(CelestiaTheme.darkBg)
}
```

- [ ] **Step 2: Commit**

```bash
git add Celestia/Character/CaelusCharacterView.swift
git commit -m "feat: add CaelusCharacterView with mood transitions"
```

---

### Task 4: Create Placeholder Assets

**Files:**
- Create: `Celestia/Resources/Assets.xcassets/Character/` directory + Contents.json files

- [ ] **Step 1: Create the asset catalog structure**

For each mood, create the imageset directory and Contents.json. Until real Ideogram art is ready, the app will show the SF Symbol placeholder from CaelusCharacterView.

```bash
cd Celestia/Resources/Assets.xcassets
mkdir -p Character
```

Create `Character/Contents.json`:
```json
{
  "info": { "version": 1, "author": "xcode" }
}
```

For each mood (welcoming, thoughtful, encouraging, serious, mystical, excited, compassionate, neutral), create:
```bash
mkdir -p Character/caelus_MOOD.imageset
```

Each imageset gets a `Contents.json`:
```json
{
  "images": [
    { "idiom": "universal", "scale": "1x", "filename": "caelus_MOOD.png" },
    { "idiom": "universal", "scale": "2x", "filename": "caelus_MOOD@2x.png" },
    { "idiom": "universal", "scale": "3x", "filename": "caelus_MOOD@3x.png" }
  ],
  "info": { "version": 1, "author": "xcode" }
}
```

- [ ] **Step 2: Commit**

```bash
git add Celestia/Resources/Assets.xcassets/Character/
git commit -m "feat: add character asset catalog structure (placeholders)"
```

---

### Task 5: Wire Up CelestiaApp (Preload on Launch)

**Files:**
- Modify: `Celestia/App/CelestiaApp.swift`

- [ ] **Step 1: Add preload call in init**

In `CelestiaApp.init()`, add:

```swift
CaelusImageCache.shared.preloadAll()
```

This should be added near the existing initialization code in the `init()` method.

- [ ] **Step 2: Commit**

```bash
git add Celestia/App/CelestiaApp.swift
git commit -m "feat: preload character images on app launch"
```

---

### Task 6: Integrate into TodayView (Daily Reading)

**Files:**
- Modify: `Celestia/Views/Today/TodayView.swift`

- [ ] **Step 1: Add computed mood property**

Add a computed property to TodayView:

```swift
private var characterMood: CaelusMood {
    guard let reading = todayReading else { return .neutral }
    return CaelusMoodRouter.resolve(
        energyLove: reading.energyLove,
        energyCareer: reading.energyCareer,
        energyHealth: reading.energyHealth,
        energySpiritual: reading.energySpiritual,
        keyTheme: reading.keyTheme
    )
}
```

- [ ] **Step 2: Add CaelusCharacterView to body**

Insert `CaelusCharacterView(mood: characterMood)` after the stardust bar and before the daily reading card section. Place it inside the existing VStack in the ScrollView.

- [ ] **Step 3: Commit**

```bash
git add Celestia/Views/Today/TodayView.swift
git commit -m "feat: add Caelus character to daily reading view"
```

---

### Task 7: Integrate into WeeklyReadingView

**Files:**
- Modify: `Celestia/Views/Today/WeeklyReadingView.swift`

- [ ] **Step 1: Add computed mood property**

The weekly view builds sections progressively and may not have a single ParsedReading. Use the reading text content for keyword-based routing:

```swift
private var characterMood: CaelusMood {
    // If sections are loaded, analyze the combined text
    let combinedText = sections.map(\.content).joined(separator: " ")
    if combinedText.isEmpty { return CaelusMoodRouter.appLaunch }
    return CaelusMoodRouter.resolveForChat(responseText: combinedText)
}
```

- [ ] **Step 2: Add CaelusCharacterView after headerSection**

Insert `CaelusCharacterView(mood: characterMood)` after the header section in the ScrollView VStack.

- [ ] **Step 3: Commit**

```bash
git add Celestia/Views/Today/WeeklyReadingView.swift
git commit -m "feat: add Caelus character to weekly reading view"
```

---

### Task 8: Integrate into TarotView

**Files:**
- Modify: `Celestia/Views/Tarot/TarotView.swift`

- [ ] **Step 1: Add computed mood property**

```swift
private var characterMood: CaelusMood {
    guard !drawnCards.isEmpty else { return CaelusMoodRouter.appLaunch }
    let cardNames = drawnCards.map(\.name)
    let reversedCount = drawnCards.filter(\.isReversed).count
    return CaelusMoodRouter.resolveForTarot(
        cardNames: cardNames,
        reversedCount: reversedCount,
        totalCards: drawnCards.count,
        keyTheme: interpretation
    )
}
```

Note: The exact property names (`name`, `isReversed`) should match the existing card model in the codebase. Read the TarotView file to confirm the field names before implementing.

- [ ] **Step 2: Add CaelusCharacterView after headerSection**

Insert `CaelusCharacterView(mood: characterMood)` after the header section, before the spread picker.

- [ ] **Step 3: Commit**

```bash
git add Celestia/Views/Tarot/TarotView.swift
git commit -m "feat: add Caelus character to tarot reading view"
```

---

### Task 9: Integrate into CompatReportView

**Files:**
- Modify: `Celestia/Views/Compatibility/CompatReportView.swift`

- [ ] **Step 1: Add computed mood property**

```swift
private var characterMood: CaelusMood {
    guard let reading else { return .neutral }
    return CaelusMoodRouter.resolveForCompatibility(energyLove: reading.energyLove)
}
```

- [ ] **Step 2: Add CaelusCharacterView after headerSection**

Insert `CaelusCharacterView(mood: characterMood)` after `headerSection` (line ~23) and before `chartComparison`.

- [ ] **Step 3: Commit**

```bash
git add Celestia/Views/Compatibility/CompatReportView.swift
git commit -m "feat: add Caelus character to compatibility report"
```

---

### Task 10: Integrate into ChatView

**Files:**
- Modify: `Celestia/Views/Chat/ChatView.swift`

- [ ] **Step 1: Add mood tracking for latest AI response**

In ChatView, add a computed property that inspects the last AI message:

```swift
private var characterMood: CaelusMood {
    guard let lastAIMessage = messages.last(where: { $0.role == .assistant }) else {
        return CaelusMoodRouter.appLaunch
    }
    return CaelusMoodRouter.resolveForChat(responseText: lastAIMessage.content)
}
```

Note: Confirm the exact message model fields (`.role`, `.assistant`, `.content`) by reading the ChatView file before implementing.

- [ ] **Step 2: Add CaelusCharacterView in chat header area**

Insert a small `CaelusCharacterView(mood: characterMood, size: 80)` in the header area of the chat view, so the character is visible while chatting.

- [ ] **Step 3: Commit**

```bash
git add Celestia/Views/Chat/ChatView.swift
git commit -m "feat: add Caelus character to chat view"
```

---

### Task 11: Add Welcoming Character to ContentView / Home

**Files:**
- Modify: `Celestia/App/ContentView.swift`

- [ ] **Step 1: Add CaelusCharacterView to the home/landing screen**

On the main landing screen (before user navigates to a reading), show the welcoming character:

```swift
CaelusCharacterView(mood: .welcoming, size: 180)
```

Read ContentView.swift to find the appropriate insertion point (likely near the app title/greeting area).

- [ ] **Step 2: Commit**

```bash
git add Celestia/App/ContentView.swift
git commit -m "feat: add welcoming Caelus character to home screen"
```

---

### Task 12: Version Bump, Commit, Push, Build

**Files:**
- Modify: `project.yml` (version bump)

- [ ] **Step 1: Bump CURRENT_PROJECT_VERSION**

In `project.yml`, increment `CURRENT_PROJECT_VERSION` from `"8"` to `"9"`.

- [ ] **Step 2: Final commit and push**

```bash
git add -A
git commit -m "feat: Caelus visual character system — mood-reactive AI astrologer persona

- 8 mood states with deterministic routing from reading data
- Pure function MoodRouter (no shared state)
- CaelusCharacterView with smooth transitions
- Integrated into all reading views + home screen
- NSCache preloading for character images"

git push origin master
```

- [ ] **Step 3: Build on Mac Mini**

SSH to Mac Mini and run the standard build workflow:
```bash
ssh phil@192.168.2.120
cd ~/celestia
git pull origin master
# Run XcodeGen + archive + export + upload
```

Follow the Mac Mini build commands in memory file `project_mac_mini_build.md`.

- [ ] **Step 4: Verify on TestFlight**

After upload, verify:
- Placeholder character appears on home screen (welcoming mood)
- Character appears in daily reading (mood changes based on energy)
- Character appears in tarot, compatibility, chat views
- Transitions animate smoothly between moods
- No performance issues from image preloading
