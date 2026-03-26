import Foundation
import SwiftData

@Model
final class Reading {
    var id: UUID
    var type: String              // ReadingType.rawValue
    var content: String
    var transitDataJSON: Data?    // Encoded [TransitData]
    var energyLove: Double
    var energyCareer: Double
    var energyHealth: Double
    var energySpiritual: Double
    var keyTheme: String
    var actionAdvice: String
    var createdAt: Date
    var language: String

    init(
        type: ReadingType,
        content: String,
        transits: [TransitData] = [],
        energy: (love: Double, career: Double, health: Double, spiritual: Double) = (0.5, 0.5, 0.5, 0.5),
        keyTheme: String = "",
        actionAdvice: String = "",
        language: AppLanguage = .en
    ) {
        self.id = UUID()
        self.type = type.rawValue
        self.content = content
        self.transitDataJSON = try? JSONEncoder().encode(transits)
        self.energyLove = energy.love
        self.energyCareer = energy.career
        self.energyHealth = energy.health
        self.energySpiritual = energy.spiritual
        self.keyTheme = keyTheme
        self.actionAdvice = actionAdvice
        self.createdAt = Date()
        self.language = language.rawValue
    }
}
