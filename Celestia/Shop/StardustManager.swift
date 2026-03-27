import Foundation
import SwiftData

@MainActor
final class StardustManager: ObservableObject {

    @Published var balance: Int = 0
    @Published var streak: Int = 0
    @Published var dailyRewardClaimed: Bool = false

    private var modelContext: ModelContext?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadBalance()
        checkDailyReward()
    }

    // MARK: - Load

    private func loadBalance() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<StardustBalance>()
        if let existing = try? context.fetch(descriptor).first {
            balance = existing.currentStardust
            streak = existing.currentStreak
        } else {
            let initial = StardustBalance()
            context.insert(initial)
            balance = initial.currentStardust  // 10 welcome bonus
            streak = 0
        }
    }

    // MARK: - Daily Reward

    private func checkDailyReward() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<StardustBalance>()
        guard let sb = try? context.fetch(descriptor).first else { return }

        let calendar = Calendar.current
        dailyRewardClaimed = sb.lastDailyReward.map { calendar.isDate($0, inSameDayAs: Date()) } ?? false
    }

    /// Claim daily login reward. Returns amount earned (0 if already claimed).
    func claimDailyReward() -> Int {
        guard let context = modelContext else { return 0 }
        let descriptor = FetchDescriptor<StardustBalance>()
        guard let sb = try? context.fetch(descriptor).first else { return 0 }

        let earned = sb.claimDailyReward()
        if earned > 0 {
            balance = sb.currentStardust
            streak = sb.currentStreak
            dailyRewardClaimed = true
            try? context.save()
        }
        return earned
    }

    // MARK: - Spending

    func canAfford(_ cost: Int) -> Bool {
        balance >= cost
    }

    func spend(_ amount: Int) -> Bool {
        guard let context = modelContext else { return false }
        let descriptor = FetchDescriptor<StardustBalance>()
        guard let sb = try? context.fetch(descriptor).first else { return false }

        let success = sb.spend(amount)
        if success {
            balance = sb.currentStardust
            try? context.save()
        }
        return success
    }

    // MARK: - Earning (purchases)

    func addPurchased(_ amount: Int) {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<StardustBalance>()
        guard let sb = try? context.fetch(descriptor).first else { return }

        sb.addPurchased(amount)
        balance = sb.currentStardust
        try? context.save()
    }

    // MARK: - Earning (referrals)

    func addReferralReward(referralCode: String) {
        guard let context = modelContext else { return }

        // Check monthly cap
        guard ReferralEvent.referralsThisMonth(in: context) < ReferralEvent.monthlyCapacity else { return }

        let event = ReferralEvent(referralCode: referralCode)
        context.insert(event)

        let descriptor = FetchDescriptor<StardustBalance>()
        if let sb = try? context.fetch(descriptor).first {
            sb.addEarned(ReferralEvent.rewardPerReferral)
            balance = sb.currentStardust
        }
        try? context.save()
    }

    // MARK: - Stardust Costs

    static let costs: [String: Int] = [
        "chat": 1,
        "daily_detailed": 2,
        "tarot_single": 2,
        "tarot_3card": 5,
        "tarot_celtic": 10,
        "compatibility": 5,
        "monthly_forecast": 8,
        "weekly_deep": 3,
    ]

    func costFor(_ feature: String) -> Int {
        Self.costs[feature] ?? 0
    }
}
