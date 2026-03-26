import Foundation
import SwiftData

@Model
final class Contact {
    var id: UUID
    var name: String
    var birthDate: Date
    var birthTime: Date?
    var birthCity: String?
    var birthLatitude: Double?
    var birthLongitude: Double?
    var relationship: String      // "partner", "friend", "family", "crush"
    var chartDataJSON: Data?
    var createdAt: Date

    init(
        name: String,
        birthDate: Date,
        birthTime: Date? = nil,
        birthCity: String? = nil,
        birthLatitude: Double? = nil,
        birthLongitude: Double? = nil,
        relationship: String = "friend"
    ) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.birthCity = birthCity
        self.birthLatitude = birthLatitude
        self.birthLongitude = birthLongitude
        self.relationship = relationship
        self.createdAt = Date()
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
