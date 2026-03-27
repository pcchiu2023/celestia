import Foundation

enum ShopCatalog {
    // Auto-renewable subscriptions (v2.0 pricing)
    static let starPassMonthly = "com.pcchiu2023.celestia.starpass.monthly"   // $2.99/month
    static let starPassAnnual = "com.pcchiu2023.celestia.starpass.annual"     // $19.99/year

    static let subscriptionIds: Set<String> = [
        starPassMonthly, starPassAnnual
    ]

    // Consumable stardust packs
    static let stardustStarter = "com.pcchiu2023.celestia.stardust.starter"   // $1.99 → 30✦
    static let stardustPopular = "com.pcchiu2023.celestia.stardust.popular"   // $4.99 → 100✦
    static let stardustCosmic = "com.pcchiu2023.celestia.stardust.cosmic"     // $9.99 → 250✦

    static let stardustProducts: [String: Int] = [
        stardustStarter: 30,
        stardustPopular: 100,
        stardustCosmic: 250
    ]

    // Subscription includes 80✦/month
    static let monthlyStardustAllowance = 80

    // Subscription group ID
    static let subscriptionGroupId = "celestia_star_pass"
}
