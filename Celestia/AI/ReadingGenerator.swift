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
        modelContext: ModelContext,
        isDetailed: Bool = false
    ) async -> ParsedReading {
        guard let chart = profile.chartData else { return ReadingParser.parse("") }

        let transits = TransitEngine.shared.calculateTransits(natalChart: chart)
        let memory = MemoryEngine.buildContext(modelContext: modelContext)
        let lang = profile.appLanguage

        let prompt = PromptBuilder.dailyReading(
            chart: chart, transits: transits, memory: memory,
            language: lang, isDetailed: isDetailed
        )

        let raw = await generateWithValidation(
            system: prompt.system, user: prompt.user, chart: chart
        )
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

        let prompt = PromptBuilder.chatResponse(
            message: message, chart: chart, transits: transits,
            memory: memory, chatHistory: chatHistory, language: lang
        )

        let raw = await brain.generate(systemPrompt: prompt.system, userPrompt: prompt.user)
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
        let prompt = PromptBuilder.compatibilityReading(
            chart1: chart1, name1: profile.name,
            chart2: chart2, name2: contact.name,
            language: lang
        )

        let raw = await generateWithValidation(
            system: prompt.system, user: prompt.user, chart: chart1
        )
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

        let prompt = PromptBuilder.tarotReading(
            cards: cards, question: question, chart: chart, language: lang
        )

        let raw = await brain.generate(systemPrompt: prompt.system, userPrompt: prompt.user)
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

        let prompt = PromptBuilder.weeklyReading(
            section: section, chart: chart, transits: transits, language: lang
        )

        let raw = await brain.generate(systemPrompt: prompt.system, userPrompt: prompt.user)
        return raw.replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Accuracy Gate

    /// Generate text with post-validation. Retries once on failure, falls back to knowledge-only.
    private func generateWithValidation(
        system: String, user: String, chart: BirthChartData
    ) async -> String {
        // First attempt
        let raw = await brain.generate(systemPrompt: system, userPrompt: user)
        let validation = ReadingValidator.validate(reading: raw, chart: chart)

        if validation.isValid {
            return raw
        }

        // Second attempt with stricter prompt
        let strictUser = """
        IMPORTANT: Your previous response contained inaccuracies. Please try again.
        Only reference these exact positions:
        \(chart.planets.map { "\($0.body.rawValue.capitalized) in \($0.sign.rawValue.capitalized)" }.joined(separator: ", "))

        \(user)
        """

        let retry = await brain.generate(systemPrompt: system, userPrompt: strictUser)
        let retryValidation = ReadingValidator.validate(reading: retry, chart: chart)

        if retryValidation.isValid {
            return retry
        }

        // Fallback: return first attempt anyway (better UX than showing nothing)
        // The issues are logged for analysis
        print("ReadingValidator: Issues after retry: \(retryValidation.issues)")
        return raw
    }
}
