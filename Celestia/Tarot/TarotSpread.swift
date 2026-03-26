import Foundation

enum SpreadType: String, Codable, CaseIterable {
    case single = "single"
    case threeCard = "three_card"
    case celticCross = "celtic_cross"

    var cardCount: Int {
        switch self {
        case .single: return 1
        case .threeCard: return 3
        case .celticCross: return 10
        }
    }

    var displayName: String {
        switch self {
        case .single: return "Single Card"
        case .threeCard: return "Past \u{00B7} Present \u{00B7} Future"
        case .celticCross: return "Celtic Cross"
        }
    }

    var positionMeanings: [String] {
        switch self {
        case .single: return ["The Message"]
        case .threeCard: return ["Past", "Present", "Future"]
        case .celticCross: return [
            "Present Situation", "Challenge", "Distant Past",
            "Recent Past", "Best Outcome", "Near Future",
            "Your Approach", "External Influences",
            "Hopes & Fears", "Final Outcome"
        ]
        }
    }

    var tokenCost: Int {
        switch self {
        case .single: return 0  // free once per day
        case .threeCard: return 2
        case .celticCross: return 3
        }
    }
}
