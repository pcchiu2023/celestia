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
        // Match TarotCard enum rawValues (camelCase)
        let painCards: Set<String> = [
            "threeOfSwords", "tenOfSwords", "theTower",
            "fiveOfCups", "fiveOfPentacles", "nineOfSwords"
        ]
        let joyCards: Set<String> = [
            "theSun", "theStar", "theWorld",
            "aceOfCups", "tenOfCups", "theEmpress"
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
