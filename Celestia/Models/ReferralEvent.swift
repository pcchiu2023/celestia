import Foundation
import SwiftData

@Model
final class ReferralEvent {
    var id: UUID
    var referralCode: String
    var referredUserId: String?
    var rewardAmount: Int
    var createdAt: Date

    init(referralCode: String, referredUserId: String? = nil, rewardAmount: Int = 15) {
        self.id = UUID()
        self.referralCode = referralCode
        self.referredUserId = referredUserId
        self.rewardAmount = rewardAmount
        self.createdAt = Date()
    }

    /// Check if referral cap reached this month (5/month)
    static func referralsThisMonth(in context: ModelContext) -> Int {
        let calendar = Calendar.current
        guard let monthStart = calendar.dateInterval(of: .month, for: Date())?.start else { return 0 }
        let descriptor = FetchDescriptor<ReferralEvent>(
            predicate: #Predicate<ReferralEvent> { $0.createdAt >= monthStart }
        )
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    static let monthlyCapacity = 5
    static let rewardPerReferral = 15
}
