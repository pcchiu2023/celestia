import Foundation

/// Post-generation accuracy validator.
/// Checks AI output against computed chart data to catch hallucinations.
enum ReadingValidator {

    struct ValidationResult {
        let isValid: Bool
        let issues: [String]
    }

    /// Validate a reading against the birth chart data
    static func validate(reading: String, chart: BirthChartData) -> ValidationResult {
        var issues: [String] = []

        // 1. Check sign accuracy — if reading mentions a sign for a planet, it must match
        for placement in chart.planets {
            let planetName = placement.body.rawValue.lowercased()
            let correctSign = placement.sign.rawValue.lowercased()

            // Check if reading mentions this planet with a wrong sign
            for sign in ZodiacSign.allCases {
                let signName = sign.rawValue.lowercased()
                if signName == correctSign { continue }

                // Pattern: "sun in taurus" or "your sun is in taurus"
                let patterns = [
                    "\(planetName) in \(signName)",
                    "\(planetName) is in \(signName)",
                    "\(planetName) enters \(signName)",
                ]

                for pattern in patterns {
                    if reading.lowercased().contains(pattern) {
                        issues.append("Wrong sign: said \(planetName) in \(signName), actual is \(correctSign)")
                    }
                }
            }
        }

        // 2. Check retrograde accuracy
        for placement in chart.planets {
            let planetName = placement.body.rawValue.lowercased()
            if placement.isRetrograde {
                // If reading says "mercury direct" but mercury is retrograde
                if reading.lowercased().contains("\(planetName) direct") ||
                   reading.lowercased().contains("\(planetName) is direct") {
                    issues.append("Wrong retrograde: said \(planetName) direct, but it's retrograde")
                }
            } else {
                // If reading says "mercury retrograde" but mercury is NOT retrograde
                if reading.lowercased().contains("\(planetName) retrograde") ||
                   reading.lowercased().contains("\(planetName) is retrograde") {
                    // Exception: if it's talking about a transit, not natal
                    if !reading.lowercased().contains("transit") {
                        issues.append("Wrong retrograde: said \(planetName) retrograde, but it's direct")
                    }
                }
            }
        }

        // 3. Check aspect accuracy — if specific aspects are mentioned, they should exist
        let aspectPairs: Set<String> = Set(chart.aspects.map { aspect in
            let names = [aspect.body1.rawValue, aspect.body2.rawValue].sorted()
            return "\(names[0])_\(aspect.type.rawValue)_\(names[1])"
        })

        for aspect in AspectType.allCases {
            let aspectName = aspect.rawValue.lowercased()
            // Check if reading mentions a specific aspect between two planets
            for p1 in CelestialBody.allCases {
                for p2 in CelestialBody.allCases where p1 != p2 {
                    let pattern = "\(p1.rawValue.lowercased()) \(aspectName) \(p2.rawValue.lowercased())"
                    if reading.lowercased().contains(pattern) {
                        let names = [p1.rawValue, p2.rawValue].sorted()
                        let key = "\(names[0])_\(aspect.rawValue)_\(names[1])"
                        if !aspectPairs.contains(key) {
                            issues.append("Hallucinated aspect: \(p1.rawValue) \(aspectName) \(p2.rawValue) not found in chart")
                        }
                    }
                }
            }
        }

        return ValidationResult(isValid: issues.isEmpty, issues: issues)
    }
}
