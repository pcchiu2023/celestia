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
