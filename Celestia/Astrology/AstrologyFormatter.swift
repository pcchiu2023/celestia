import Foundation

enum AstrologyFormatter {

    /// Format a full birth chart for the AI system prompt
    static func formatChartForPrompt(_ chart: BirthChartData) -> String {
        var lines: [String] = ["USER'S BIRTH CHART:"]

        // Key placements
        for p in chart.planets {
            let retro = p.isRetrograde ? " (retrograde)" : ""
            let dignityStr = p.dignity != .peregrine ? " [\(p.dignity.rawValue)]" : ""
            lines.append("\(p.body.symbol) \(p.body.rawValue.capitalized): \(p.sign.rawValue.capitalized) \(Int(p.signDegree))° (House \(p.house))\(retro)\(dignityStr)")
        }

        // Ascendant and Midheaven
        lines.append("")
        lines.append("Ascendant (Rising): \(chart.ascendantSign.rawValue.capitalized) \(chart.ascendantSign.symbol)")
        lines.append("Midheaven (MC): \(chart.mcSign.rawValue.capitalized) \(chart.mcSign.symbol)")

        // Key aspects
        let significantAspects = chart.aspects.filter { $0.orb < 5 }.prefix(10)
        if !significantAspects.isEmpty {
            lines.append("")
            lines.append("KEY ASPECTS:")
            for a in significantAspects {
                lines.append("\(a.body1.symbol) \(a.body1.rawValue.capitalized) \(a.type.rawValue) \(a.body2.symbol) \(a.body2.rawValue.capitalized) (orb: \(String(format: "%.1f", a.orb))°, \(a.type.nature))")
            }
        }

        return lines.joined(separator: "\n")
    }

    /// Format current transits for the AI prompt
    static func formatTransitsForPrompt(_ transits: [TransitData]) -> String {
        guard !transits.isEmpty else { return "No significant transits today." }

        var lines = ["TODAY'S TRANSITS:"]
        for t in transits.prefix(8) {
            lines.append("• \(t.description)")
        }
        return lines.joined(separator: "\n")
    }

    /// Format compatibility data for two charts
    static func formatCompatibility(chart1: BirthChartData, name1: String, chart2: BirthChartData, name2: String) -> String {
        var lines = [
            "COMPATIBILITY ANALYSIS:",
            "",
            "\(name1)'s Sun: \(chart1.sunSign.rawValue.capitalized) \(chart1.sunSign.symbol)",
            "\(name1)'s Moon: \(chart1.moonSign.rawValue.capitalized)",
            "\(name1)'s Rising: \(chart1.risingSign.rawValue.capitalized)",
            "",
            "\(name2)'s Sun: \(chart2.sunSign.rawValue.capitalized) \(chart2.sunSign.symbol)",
            "\(name2)'s Moon: \(chart2.moonSign.rawValue.capitalized)",
            "\(name2)'s Rising: \(chart2.risingSign.rawValue.capitalized)",
            "",
            "ELEMENT COMPATIBILITY:"
        ]

        let el1 = chart1.sunSign.element
        let el2 = chart2.sunSign.element
        let compatibility = elementCompatibility(el1, el2)
        lines.append("\(el1.rawValue.capitalized) + \(el2.rawValue.capitalized) = \(compatibility)")

        // Cross-aspects between charts
        lines.append("")
        lines.append("KEY CROSS-ASPECTS:")
        let crossAspects = calculateCrossAspects(chart1: chart1, chart2: chart2)
        for a in crossAspects.prefix(8) {
            lines.append("• \(name1)'s \(a.body1.rawValue.capitalized) \(a.type.rawValue) \(name2)'s \(a.body2.rawValue.capitalized) (\(a.type.nature))")
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Private

    private static func elementCompatibility(_ e1: Element, _ e2: Element) -> String {
        if e1 == e2 { return "Very harmonious — same element, deep understanding" }
        switch (e1, e2) {
        case (.fire, .air), (.air, .fire): return "Exciting and stimulating — fire and air fuel each other"
        case (.earth, .water), (.water, .earth): return "Nurturing and stable — earth and water complement naturally"
        case (.fire, .earth), (.earth, .fire): return "Challenging but grounding — different paces, mutual growth"
        case (.fire, .water), (.water, .fire): return "Intense and transformative — steam when combined"
        case (.air, .earth), (.earth, .air): return "Contrasting perspectives — mind meets matter"
        case (.air, .water), (.water, .air): return "Cerebral meets emotional — requires patience and understanding"
        default: return "Unique dynamic"
        }
    }

    private static func calculateCrossAspects(chart1: BirthChartData, chart2: BirthChartData) -> [AspectData] {
        var aspects: [AspectData] = []
        let main1 = chart1.planets.filter { [.sun, .moon, .venus, .mars, .mercury].contains($0.body) }
        let main2 = chart2.planets.filter { [.sun, .moon, .venus, .mars, .mercury].contains($0.body) }

        for p1 in main1 {
            for p2 in main2 {
                let angle = abs(p1.degree - p2.degree)
                let normalized = angle > 180 ? 360 - angle : angle

                for aspectType in AspectType.allCases {
                    let diff = abs(normalized - aspectType.angle)
                    if diff <= aspectType.orb {
                        aspects.append(AspectData(
                            body1: p1.body, body2: p2.body,
                            type: aspectType, orb: diff, isApplying: false
                        ))
                    }
                }
            }
        }
        return aspects.sorted { $0.orb < $1.orb }
    }
}
