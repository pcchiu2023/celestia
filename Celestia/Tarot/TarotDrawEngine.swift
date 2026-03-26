import Foundation

enum TarotDrawEngine {
    static func drawCards(spread: SpreadType) -> [DrawnCardData] {
        var deck = TarotCard.allCases.shuffled()
        var drawn: [DrawnCardData] = []

        for i in 0..<spread.cardCount {
            let card = deck.removeFirst()
            let isReversed = Double.random(in: 0...1) < 0.3  // 30% reversal chance
            drawn.append(DrawnCardData(
                cardId: card.rawValue,
                position: i + 1,
                isReversed: isReversed,
                positionMeaning: spread.positionMeanings[i]
            ))
        }

        return drawn
    }
}
