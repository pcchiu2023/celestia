import Foundation
import SwiftData

@Model
final class TokenBalance {
    var currentTokens: Int
    var totalPurchased: Int
    var totalSpent: Int

    init() {
        self.currentTokens = 0
        self.totalPurchased = 0
        self.totalSpent = 0
    }

    func spend(_ amount: Int) -> Bool {
        guard currentTokens >= amount else { return false }
        currentTokens -= amount
        totalSpent += amount
        return true
    }

    func add(_ amount: Int) {
        currentTokens += amount
        totalPurchased += amount
    }
}
