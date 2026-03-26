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
