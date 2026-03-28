# Caelus Visual Character System — Design Spec

**Goal:** Add a mood-reactive visual character (the AI astrologer "Caelus") that appears alongside readings, differentiating the app from text-only astrology competitors.

**Approved by:** Phil (user) + Gemini (creative direction) + Claude (architecture)

---

## 1. Character Design

### Identity
- **Name:** Caelus (the app's AI astrologer persona)
- **Appearance:** 25-year-old woman, modern Japanese scholar aesthetic
- **Signature look:** Minimalist dark charcoal high-neck linen top, delicate silver crescent moon necklace
- **Hair:** Sleek, dark
- **Framing:** Medium close-up, chest up — locked camera angle for consistency
- **Background:** Shallow depth of field, blurred dark wood study
- **Lighting:** Soft cinematic with deep dramatic shadows

### 8 Mood States

| Mood | Expression | Eyes | Distinguishing Feature |
|------|-----------|------|----------------------|
| **Welcoming** | Warm inviting smile | Friendly direct gaze | Slightly tilted head |
| **Thoughtful** | Contemplative, slight brow furrow | Gaze subtly upward/away | Pensive look |
| **Encouraging** | Broad bright smile | Warm supportive direct gaze | Strongest "standard" smile |
| **Serious** | Composed, firm but empathetic | Steady intense focused gaze | Unsmiling, calm |
| **Mystical** | Subtle knowing smirk | Half-lidded, heavy with wisdom | Asymmetrical smile |
| **Excited** | Wide genuine grin | Wide bright sparkling | Highest energy, showing joy |
| **Compassionate** | Soft empathetic | Gentle, subtle concern | Relaxed mouth, emotion in eyes only |
| **Neutral** | Pleasant relaxed | Calm tranquil | "Resting pleasant face" — the control |

### Emotion Hierarchy (conflict resolution)
When multiple signals fire, highest priority wins:
1. Compassionate (hardship always acknowledged)
2. Serious (challenges deserve gravity)
3. Excited (great news celebrated)
4. Encouraging (good energy supported)
5. Mystical (spiritual themes honored)
6. Welcoming (app lifecycle)
7. Thoughtful (reflection default)
8. Neutral (fallback)

---

## 2. Architecture

### Approach: View-Local Mood (Pure Function)
**Chosen unanimously by Claude + Gemini.** Mood is derived state, not source of truth.

Each view computes mood locally via `CaelusMoodRouter.resolve(for:)` and passes it to `CaelusCharacterView` as a parameter. No shared state, no EnvironmentObject for mood.

**Rationale:**
- Mood is a deterministic transformation of existing LLM output — not new state
- Each reading view is self-contained — no risk of "state bleed" between views
- Pure functions are trivially testable
- Explicit parameter passing gives SwiftUI a clear dependency graph for transitions

### New Files

| File | Purpose |
|------|---------|
| `Celestia/Character/CaelusMood.swift` | `CaelusMood` enum + `CaelusMoodRouter` pure function namespace |
| `Celestia/Character/CaelusCharacterView.swift` | SwiftUI view rendering the character image with transitions |
| `Celestia/Character/CaelusImageCache.swift` | NSCache-based preloader for all character PNGs |

### Modified Files

| File | Change |
|------|--------|
| `DailyReadingView.swift` | Add computed `characterMood` property + `CaelusCharacterView` |
| `WeeklyReadingView.swift` | Add computed `characterMood` property + `CaelusCharacterView` |
| `TarotView.swift` | Add computed `characterMood` property + `CaelusCharacterView` |
| `CompatReportView.swift` | Add computed `characterMood` property + `CaelusCharacterView` |
| `ChatView.swift` | Add `CaelusCharacterView` in AI message bubbles |
| `CelestiaApp.swift` | Call `CaelusImageCache.shared.preloadAll()` on launch |
| `ContentView.swift` | Show welcoming character on home/landing screen |

---

## 3. Mood Routing Matrix

All routing is **deterministic post-processing** on existing LLM structured output. Zero additional LLM calls.

### Daily / Weekly Readings
Input: `energy.physical`, `energy.emotional`, `energy.mental`, `keyTheme`

| Condition | Mood |
|-----------|------|
| Any energy ≤ 3 | Compassionate |
| Avg ≥ 8.5 AND any = 10 | Excited |
| Avg ≥ 6.5 | Encouraging |
| keyTheme contains "transform"/"spiritual" | Mystical |
| keyTheme contains "challenge"/"tension" | Serious |
| Default | Thoughtful |

### Tarot Readings
Input: card names, reversed status, keyTheme

| Condition | Mood |
|-----------|------|
| Contains pain card (3 of Swords, 10 of Swords, Tower, 5 of Cups) | Compassionate |
| ≥ 50% cards reversed | Serious |
| Contains joy card (Sun, Star, World, Ace of Cups) | Excited |
| Default | Mystical |

### Compatibility
Input: `compatibilityScore` (0-100)

| Condition | Mood |
|-----------|------|
| Score < 40 | Compassionate |
| Score ≥ 90 | Excited |
| Score ≥ 70 | Encouraging |
| Default | Thoughtful |

### Chat
Input: AI response text (keyword matching)

| Keywords | Mood |
|----------|------|
| difficult, loss, grief, struggle, pain, sorry | Compassionate |
| amazing, wonderful, fantastic, incredible | Excited |
| destiny, karma, past life, spiritual, divine | Mystical |
| Default | Encouraging |

### App Lifecycle
| Event | Mood |
|-------|------|
| App launch / home screen | Welcoming |
| Settings / profile | Thoughtful |
| Loading state | Neutral (or keep previous) |
| Missing data / error | Neutral |

---

## 4. Art Pipeline

### Ideogram Base Prompt (Gemini-refined)

> A photorealistic medium close-up, chest up portrait of a beautiful 25-year-old modern Japanese woman with an elegant scholar aesthetic, captured on an 85mm lens. She has sleek, dark hair. [EMOTIONAL DESCRIPTION HERE]. She is wearing a minimalist dark charcoal high-neck linen top and a delicate silver crescent moon necklace. The background is a shallow depth of field, rendering a blurred, sophisticated dark wood study. The scene features soft cinematic lighting with deep, dramatic shadows. 4k, highly detailed.

### Emotional Description Slots

| Mood | Slot Text |
|------|-----------|
| Welcoming | "She has a warm, inviting smile and her head is slightly tilted in a welcoming gesture, maintaining a friendly gaze directly at the camera." |
| Thoughtful | "She has a contemplative, pensive expression with a slight furrow to her brow, her gaze directed subtly upward and away from the camera in deep thought." |
| Encouraging | "She is smiling broadly and brightly with a genuinely warm expression, her eyes full of encouragement as she maintains a direct, supportive gaze into the camera." |
| Serious | "She maintains a composed, serious expression with a steady, intense, and focused gaze looking directly at the camera, her facial features firm but empathetic." |
| Mystical | "She has a subtle, knowing smirk and mysterious expression. Her eyes are half-lidded, heavy with wisdom, looking knowingly at the camera." |
| Excited | "She is grinning with a wide, genuine smile of pure excitement. Her eyes are wide, bright, and sparkling with joy, looking directly at the camera." |
| Compassionate | "She has a soft, empathetic expression. Her eyes are gentle and show a subtle touch of concern and profound compassion, looking directly at the camera with kindness." |
| Neutral | "She has a pleasant, relaxed, and calm expression with a neutral mouth and tranquil eyes, looking directly and calmly at the camera." |

### Generation Workflow
1. **Golden Generation:** Generate Neutral first, pick THE face, save Seed Number, disable Magic Prompt
2. **Mood Variants:** Generate 4-8 per mood using seed, curate against baseline
3. **Consistency Patch:** Photoshop composite — baseline body + mood expression overlay
4. **Export:** Transparent PNG or dark bg, 3 scales (1x/2x/3x), optimize to ~150-250KB per @3x

### Asset Budget
- ~18 image sets (8 base moods + ~10 variants for high-frequency moods)
- ~6MB total in app bundle (<1% compared to 900MB MLX model)
- Preloaded into NSCache on app launch

### Asset Naming
```
Assets.xcassets/Character/
  caelus_welcoming.imageset/
  caelus_welcoming_2.imageset/
  caelus_thoughtful.imageset/
  caelus_thoughtful_2.imageset/
  caelus_thoughtful_3.imageset/
  caelus_encouraging.imageset/
  caelus_encouraging_2.imageset/
  caelus_encouraging_3.imageset/
  caelus_serious.imageset/
  caelus_mystical.imageset/
  caelus_mystical_2.imageset/
  caelus_mystical_3.imageset/
  caelus_excited.imageset/
  caelus_compassionate.imageset/
  caelus_neutral.imageset/
  caelus_neutral_2.imageset/
```

---

## 5. SwiftUI Integration Details

### CaelusCharacterView
- Accepts `mood: CaelusMood` and optional `size: CGFloat`
- Uses `.transition(.opacity.combined(with: .scale))` for mood changes
- `.animation(.easeInOut(duration: 0.4), value: mood)` for smooth cross-dissolve
- `.id(mood)` forces SwiftUI to animate between mood changes
- For moods with variants, `mood.randomImageName()` picks a random variant

### Image Preloading
- `CaelusImageCache.shared.preloadAll()` called in `CelestiaApp.init()`
- NSCache-based — system can evict under memory pressure
- All 18 images loaded on launch (~6MB in memory, negligible vs MLX model)

### Per-View Integration Pattern
Each view adds one computed property and one view call:
```swift
private var characterMood: CaelusMood {
    guard let reading else { return .neutral }
    return CaelusMoodRouter.resolve(/* view-specific params */)
}

// In body:
CaelusCharacterView(mood: characterMood)
```

---

## 6. Testing Strategy

### Unit Tests (CaelusMoodRouter)
- Test each reading type's routing logic exhaustively
- Test hierarchy: when Compassionate AND Excited signals both fire, Compassionate wins
- Test edge cases: missing data → Neutral, empty keyTheme → default
- Test boundary values: energy exactly 3.0, exactly 6.5, exactly 8.5

### UI Verification
- Preview each mood in Xcode previews
- Verify transitions animate smoothly between moods
- Verify image preloading completes before first view appears

---

## 7. Future Considerations (Not in Scope)

- Animated character (Lottie/Rive) — would replace static PNGs
- Character customization (user picks Caelus' outfit)
- Full-body character for tablet layouts
- Voice integration (character "speaks" the reading)
