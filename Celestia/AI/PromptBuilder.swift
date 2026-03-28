import Foundation

/// Constructs grounded prompts with knowledge injection for accuracy gating.
/// The AI only writes interpretive prose — never invents astrology facts.
enum PromptBuilder {

    // MARK: - Daily Reading

    static func dailyReading(
        chart: BirthChartData,
        transits: [TransitData],
        memory: String,
        language: AppLanguage,
        isDetailed: Bool = false
    ) -> (system: String, user: String) {
        let knowledge = KnowledgeEngine.shared.snippets(for: chart, transits: transits)
        let wordCount = isDetailed ? "150-200" : "80-120"

        let system = """
        You are Caelus, a wise and mystical AI astrologer.
        \(language.promptInstruction)
        Tone: warm, insightful, specific, empowering — never vague or generic.

        IMPORTANT: Only reference planetary positions and aspects from the VERIFIED DATA below.
        Do NOT invent any positions, degrees, or aspects not listed here.
        Your role is to INTERPRET the data poetically, not to state astronomical facts.

        === VERIFIED BIRTH CHART ===
        \(AstrologyFormatter.formatChartForPrompt(chart))

        === CURRENT TRANSITS ===
        \(AstrologyFormatter.formatTransitsForPrompt(transits))

        === ASTROLOGICAL KNOWLEDGE ===
        \(knowledge)

        \(memory)
        """

        let user = """
        Write today's personalized horoscope. \(wordCount) words.
        Focus on the most significant transits and how they interact with the natal chart.
        Ground every statement in the verified data above.
        Respond in valid JSON:
        {"reading":"...","energy":{"love":0.0-1.0,"career":0.0-1.0,"health":0.0-1.0,"spiritual":0.0-1.0},"keyTheme":"...","actionAdvice":"...","luckyElements":{"color":"...","number":N,"crystal":"..."}}
        """

        return (system, user)
    }

    // MARK: - Chat Response

    static func chatResponse(
        message: String,
        chart: BirthChartData,
        transits: [TransitData],
        memory: String,
        chatHistory: String,
        language: AppLanguage
    ) -> (system: String, user: String) {
        let knowledge = KnowledgeEngine.shared.snippets(for: chart, transits: transits)

        let system = """
        You are Caelus, a wise and mystical AI astrologer having a conversation.
        \(language.promptInstruction)
        Be warm, personal, and reference the user's chart.
        Keep responses under 150 words.

        IMPORTANT: Only reference verified positions from the data below.

        === VERIFIED BIRTH CHART ===
        \(AstrologyFormatter.formatChartForPrompt(chart))

        === CURRENT TRANSITS ===
        \(AstrologyFormatter.formatTransitsForPrompt(transits))

        === ASTROLOGICAL KNOWLEDGE ===
        \(knowledge)

        \(memory)

        \(chatHistory)
        """

        return (system, message)
    }

    // MARK: - Compatibility

    static func compatibilityReading(
        chart1: BirthChartData, name1: String,
        chart2: BirthChartData, name2: String,
        language: AppLanguage
    ) -> (system: String, user: String) {
        let compatData = AstrologyFormatter.formatCompatibility(
            chart1: chart1, name1: name1,
            chart2: chart2, name2: name2
        )
        let knowledge1 = KnowledgeEngine.shared.snippets(for: chart1)
        let knowledge2 = KnowledgeEngine.shared.snippets(for: chart2)

        let system = """
        You are Caelus, a wise AI astrologer specializing in relationship compatibility.
        \(language.promptInstruction)
        Be honest but encouraging. Highlight strengths AND challenges.

        IMPORTANT: Only reference verified positions from the data below.

        \(compatData)

        === \(name1)'s KEY ENERGIES ===
        \(knowledge1)

        === \(name2)'s KEY ENERGIES ===
        \(knowledge2)
        """

        let user = """
        Write a compatibility reading for \(name1) and \(name2).
        Cover: emotional connection, communication style, love language, challenges, advice.
        150-200 words.
        Respond in valid JSON:
        {"reading":"...","energy":{"love":0.0-1.0,"career":0.0-1.0,"health":0.0-1.0,"spiritual":0.0-1.0},"keyTheme":"...","actionAdvice":"...","luckyElements":{"color":"...","number":N,"crystal":"..."}}
        """

        return (system, user)
    }

    // MARK: - Tarot

    static func tarotReading(
        cards: [DrawnCardData],
        question: String?,
        chart: BirthChartData,
        language: AppLanguage
    ) -> (system: String, user: String) {
        var cardDescriptions = "CARDS DRAWN:\n"
        for card in cards {
            let reversed = card.isReversed ? " (REVERSED)" : ""
            cardDescriptions += "Position \(card.position) (\(card.positionMeaning)): \(card.cardId)\(reversed)\n"
        }

        let knowledge = KnowledgeEngine.shared.snippets(for: chart)

        let system = """
        You are Caelus, interpreting a tarot spread.
        \(language.promptInstruction)
        Connect the cards to the user's birth chart for a deeply personal reading.
        Be specific and insightful, not generic.

        === VERIFIED BIRTH CHART ===
        \(AstrologyFormatter.formatChartForPrompt(chart))

        === ASTROLOGICAL KNOWLEDGE ===
        \(knowledge)

        \(cardDescriptions)
        """

        let questionText = question ?? "General guidance"
        let user = """
        The user's question: "\(questionText)"
        Interpret each card in its position, then synthesize an overall message.
        100-200 words total.
        """

        return (system, user)
    }

    // MARK: - Weekly

    static func weeklyReading(
        section: String,
        chart: BirthChartData,
        transits: [TransitData],
        language: AppLanguage
    ) -> (system: String, user: String) {
        let knowledge = KnowledgeEngine.shared.snippets(for: chart, transits: transits)

        let system = """
        You are Caelus, writing the \(section) section of a weekly forecast.
        \(language.promptInstruction)
        Be specific to this week's transits and the user's chart.

        IMPORTANT: Only reference verified positions from the data below.

        \(AstrologyFormatter.formatChartForPrompt(chart))
        \(AstrologyFormatter.formatTransitsForPrompt(transits))

        === ASTROLOGICAL KNOWLEDGE ===
        \(knowledge)
        """

        let user = """
        Write the \(section) forecast for this week. 80-100 words.
        Be specific and actionable. Reference exact transits.
        """

        return (system, user)
    }
}
