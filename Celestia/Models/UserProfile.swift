import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var name: String
    var birthDate: Date
    var birthTime: Date
    var birthCity: String
    var birthLatitude: Double
    var birthLongitude: Double
    var language: String          // AppLanguage.rawValue
    var chartDataJSON: Data?      // Encoded BirthChartData
    var createdAt: Date
    var subscriptionTier: String  // "free", "weekly", "monthly", "yearly"
    var onboardingComplete: Bool

    init(
        name: String,
        birthDate: Date,
        birthTime: Date,
        birthCity: String,
        birthLatitude: Double,
        birthLongitude: Double,
        language: AppLanguage = .en
    ) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.birthCity = birthCity
        self.birthLatitude = birthLatitude
        self.birthLongitude = birthLongitude
        self.language = language.rawValue
        self.createdAt = Date()
        self.subscriptionTier = "free"
        self.onboardingComplete = false
    }

    var appLanguage: AppLanguage {
        AppLanguage(rawValue: language) ?? .en
    }

    var chartData: BirthChartData? {
        get {
            guard let data = chartDataJSON else { return nil }
            return try? JSONDecoder().decode(BirthChartData.self, from: data)
        }
        set {
            chartDataJSON = try? JSONEncoder().encode(newValue)
        }
    }
}
