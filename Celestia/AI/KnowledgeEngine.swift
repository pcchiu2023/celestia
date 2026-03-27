import Foundation

/// Loads and queries curated astrology knowledge for accuracy gating.
/// The AI never invents facts — it only writes prose grounded in these snippets.
final class KnowledgeEngine {

    static let shared = KnowledgeEngine()

    private var planetInSign: [String: String] = [:]   // "sun_aries" → snippet
    private var aspectMeanings: [String: String] = [:]  // "conjunction" → snippet
    private var houseMeanings: [String: String] = [:]   // "1" → snippet
    private var transitMeanings: [String: String] = [:] // "saturn_return" → snippet

    private init() {
        loadKnowledgeBase()
    }

    // MARK: - Load Knowledge

    private func loadKnowledgeBase() {
        // Planet-in-Sign knowledge (120 combos: 10 planets × 12 signs)
        for planet in CelestialBody.allCases {
            guard planet != .northNode && planet != .southNode else { continue }
            for sign in ZodiacSign.allCases {
                let key = "\(planet.rawValue)_\(sign.rawValue)"
                planetInSign[key] = Self.defaultPlanetInSign(planet: planet, sign: sign)
            }
        }

        // Aspect meanings
        for aspect in AspectType.allCases {
            aspectMeanings[aspect.rawValue] = Self.defaultAspectMeaning(aspect)
        }

        // House meanings
        for house in 1...12 {
            houseMeanings["\(house)"] = Self.defaultHouseMeaning(house)
        }
    }

    // MARK: - Query

    /// Get relevant knowledge snippets for a birth chart
    func snippets(for chart: BirthChartData, transits: [TransitData] = []) -> String {
        var result: [String] = []

        // Top 5 most significant placements
        let keyPlanets: [CelestialBody] = [.sun, .moon, .mercury, .venus, .mars]
        for placement in chart.planets where keyPlanets.contains(placement.body) {
            let key = "\(placement.body.rawValue)_\(placement.sign.rawValue)"
            if let snippet = planetInSign[key] {
                let retro = placement.isRetrograde ? " (retrograde)" : ""
                result.append("\(placement.body.rawValue.capitalized) in \(placement.sign.rawValue.capitalized)\(retro): \(snippet)")
            }
        }

        // Key aspects (up to 3 tightest)
        let tightAspects = chart.aspects.sorted { $0.orb < $1.orb }.prefix(3)
        for aspect in tightAspects {
            if let meaning = aspectMeanings[aspect.type.rawValue] {
                result.append("\(aspect.body1.rawValue.capitalized) \(aspect.type.rawValue) \(aspect.body2.rawValue.capitalized): \(meaning)")
            }
        }

        // Ascendant house
        if let houseMeaning = houseMeanings["1"] {
            result.append("Ascendant in \(chart.ascendantSign.rawValue.capitalized): \(houseMeaning)")
        }

        // Current transits (up to 3)
        for transit in transits.prefix(3) {
            result.append("Transit: \(transit.description)")
        }

        return result.joined(separator: "\n")
    }

    // MARK: - Default Knowledge (embedded, no JSON file needed for v1.1)

    private static func defaultPlanetInSign(planet: CelestialBody, sign: ZodiacSign) -> String {
        let element = sign.element
        let modality = sign.modality
        let dignity = Dignity.calculate(body: planet, sign: sign)

        var traits: [String] = []

        // Element influence
        switch element {
        case .fire: traits.append("passionate, dynamic energy")
        case .earth: traits.append("grounded, practical approach")
        case .air: traits.append("intellectual, communicative nature")
        case .water: traits.append("emotional, intuitive depth")
        }

        // Modality influence
        switch modality {
        case .cardinal: traits.append("initiating, leadership-oriented")
        case .fixed: traits.append("determined, persistent")
        case .mutable: traits.append("adaptable, flexible")
        }

        // Dignity influence
        switch dignity {
        case .domicile: traits.append("powerfully placed in its home sign — expresses naturally and strongly")
        case .exaltation: traits.append("elevated and dignified — operates at its highest potential")
        case .detriment: traits.append("challenged in this position — must work harder to express positively")
        case .fall: traits.append("weakened — requires conscious effort to channel constructively")
        case .peregrine: traits.append("neutral placement — colored by the sign's qualities")
        }

        return traits.joined(separator: "; ")
    }

    private static func defaultAspectMeaning(_ aspect: AspectType) -> String {
        switch aspect {
        case .conjunction: return "Fusion of energies — intensified expression, powerful focus, new beginnings"
        case .sextile: return "Harmonious opportunity — natural talent, easy flow that requires activation"
        case .square: return "Dynamic tension — growth through challenge, internal conflict driving action"
        case .trine: return "Natural harmony — effortless flow, innate gifts, ease and grace"
        case .opposition: return "Polarity awareness — seeking balance between opposing forces, relationship dynamics"
        }
    }

    private static func defaultHouseMeaning(_ house: Int) -> String {
        switch house {
        case 1: return "Self-identity, appearance, personal initiative, how others first perceive you"
        case 2: return "Personal resources, values, self-worth, material security"
        case 3: return "Communication, siblings, short journeys, learning, daily environment"
        case 4: return "Home, family roots, emotional foundation, private self, endings"
        case 5: return "Creativity, romance, children, pleasure, self-expression, joy"
        case 6: return "Daily routines, health, service, work environment, self-improvement"
        case 7: return "Partnerships, marriage, one-on-one relationships, open negotiations"
        case 8: return "Transformation, shared resources, intimacy, rebirth, deep psychology"
        case 9: return "Higher learning, philosophy, long journeys, beliefs, expansion"
        case 10: return "Career, public reputation, authority, life purpose, achievements"
        case 11: return "Community, friendships, hopes, humanitarian ideals, collective goals"
        case 12: return "Spirituality, the unconscious, solitude, hidden strengths, transcendence"
        default: return ""
        }
    }
}

// Make AspectType CaseIterable for iteration
extension AspectType: CaseIterable {
    static var allCases: [AspectType] {
        [.conjunction, .sextile, .square, .trine, .opposition]
    }
}
