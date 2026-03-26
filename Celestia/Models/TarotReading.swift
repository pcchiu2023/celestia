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
