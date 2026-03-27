import Foundation
import SwiftData

@Model
final class StardustBalance {
    var currentStardust: Int
    var totalEarned: Int
    var totalPurchased: Int
    var totalSpent: Int
    var lastDailyReward: Date?
    var currentStreak: Int
    var longestStreak: Int

    init() {
        self.currentStardust = 10  // Welcome bonus
        self.totalEarned = 10
        self.totalPurchased = 0
        self.totalSpent = 0
        self.lastDailyReward = nil
        self.currentStreak = 0
        self.longestStreak = 0
    }

    // MARK: - Spending

    func canAfford(_ cost: Int) -> Bool {
        currentStardust >= cost
    }

    @discardableResult
    func spend(_ amount: Int) -> Bool {
        guard currentStardust >= amount else { return false }
        currentStardust -= amount
        totalSpent += amount
        return true
    }

    // MARK: - Earning

    func addPurchased(_ amount: Int) {
        currentStardust += amount
        totalPurchased += amount
    }

    func addEarned(_ amount: Int) {
        currentStardust += amount
        totalEarned += amount
    }

    // MARK: - Daily Login Reward

    /// Returns stardust earned (0 if already claimed today)
    @discardableResult
    func claimDailyReward() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Already claimed today?
        if let last = lastDailyReward, calendar.isDate(last, inSameDayAs: Date()) {
            return 0
        }

        // Check streak continuity
        if let last = lastDailyReward {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            if calendar.isDate(last, inSameDayAs: yesterday) {
                currentStreak += 1
            } else {
                currentStreak = 1  // Streak broken
            }
        } else {
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
        lastDailyReward = Date()

        // Daily reward: +2
        var earned = 2
        addEarned(2)

        // 7-day streak bonus: +5
        if currentStreak > 0 && currentStreak % 7 == 0 {
            addEarned(5)
            earned += 5
        }

        return earned
    }
}
