import Foundation

enum ShopCatalog {
    // Auto-renewable subscriptions
    static let starPassWeekly = "celestia_starpass_weekly"     // $6.99/week
    static let starPassMonthly = "celestia_starpass_monthly"   // $19.99/month
    static let starPassYearly = "celestia_starpass_yearly"     // $99.99/year

    static let subscriptionIds: Set<String> = [
        starPassWeekly, starPassMonthly, starPassYearly
    ]

    // Consumables
    static let tokenSmall = "celestia_tokens_5"    // $1.99 → 5 tokens
    static let tokenLarge = "celestia_tokens_30"   // $9.99 → 30 tokens

    static let tokenProducts: [String: Int] = [
        tokenSmall: 5,
        tokenLarge: 30
    ]

    // Token costs per feature
    static let tokenCost: [String: Int] = [
        "daily_refresh": 1,
        "tarot_3card": 2,
        "tarot_celtic": 3,
        "compatibility": 3,
        "placement_detail": 2,
        "weekly_deep": 5
    ]

    // Subscription group ID
    static let subscriptionGroupId = "celestia_star_pass"
}
