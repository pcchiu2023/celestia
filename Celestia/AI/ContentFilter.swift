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
