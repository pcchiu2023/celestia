import Foundation

/// Vedic astrology calculations: Nakshatras (27 lunar mansions) and Dasha periods.
/// Used when user selects Hindi/Vedic mode. Complements the Western ChartEngine.
enum VedicEngine {

    // MARK: - Ayanamsa (Tropical → Sidereal conversion)

    /// Lahiri ayanamsa approximation for a given year.
    /// Accurate to ~1 arcminute for 2000-2030 range.
    static func lahiriAyanamsa(year: Int) -> Double {
        // Base: 23°51' at J2000.0 (year 2000), precessing ~50.3" per year
        let base = 23.856111 // 23°51'22" in decimal degrees
        let yearDiff = Double(year - 2000)
        let precession = yearDiff * (50.3 / 3600.0) // arcseconds → degrees
        return base + precession
    }

    /// Convert tropical longitude to sidereal (Lahiri)
    static func toSidereal(tropicalLongitude: Double, year: Int) -> Double {
        let sidereal = tropicalLongitude - lahiriAyanamsa(year: year)
        return sidereal < 0 ? sidereal + 360.0 : sidereal
    }

    // MARK: - Nakshatras

    /// The 27 Nakshatras (lunar mansions), each spanning 13°20' of the zodiac.
    enum Nakshatra: Int, CaseIterable {
        case ashwini = 0, bharani, krittika, rohini, mrigashirsha
        case ardra, punarvasu, pushya, ashlesha
        case magha, purvaPhalguni, uttaraPhalguni, hasta, chitra
        case swati, vishakha, anuradha, jyeshtha
        case moola, purvaAshadha, uttaraAshadha, shravana, dhanishta
        case shatabhisha, purvaBhadrapada, uttaraBhadrapada, revati

        var name: String {
            switch self {
            case .ashwini: return "Ashwini"
            case .bharani: return "Bharani"
            case .krittika: return "Krittika"
            case .rohini: return "Rohini"
            case .mrigashirsha: return "Mrigashirsha"
            case .ardra: return "Ardra"
            case .punarvasu: return "Punarvasu"
            case .pushya: return "Pushya"
            case .ashlesha: return "Ashlesha"
            case .magha: return "Magha"
            case .purvaPhalguni: return "Purva Phalguni"
            case .uttaraPhalguni: return "Uttara Phalguni"
            case .hasta: return "Hasta"
            case .chitra: return "Chitra"
            case .swati: return "Swati"
            case .vishakha: return "Vishakha"
            case .anuradha: return "Anuradha"
            case .jyeshtha: return "Jyeshtha"
            case .moola: return "Moola"
            case .purvaAshadha: return "Purva Ashadha"
            case .uttaraAshadha: return "Uttara Ashadha"
            case .shravana: return "Shravana"
            case .dhanishta: return "Dhanishta"
            case .shatabhisha: return "Shatabhisha"
            case .purvaBhadrapada: return "Purva Bhadrapada"
            case .uttaraBhadrapada: return "Uttara Bhadrapada"
            case .revati: return "Revati"
            }
        }

        /// Hindi name (Devanagari)
        var hindiName: String {
            switch self {
            case .ashwini: return "अश्विनी"
            case .bharani: return "भरणी"
            case .krittika: return "कृत्तिका"
            case .rohini: return "रोहिणी"
            case .mrigashirsha: return "मृगशिरा"
            case .ardra: return "आर्द्रा"
            case .punarvasu: return "पुनर्वसु"
            case .pushya: return "पुष्य"
            case .ashlesha: return "आश्लेषा"
            case .magha: return "मघा"
            case .purvaPhalguni: return "पूर्वा फाल्गुनी"
            case .uttaraPhalguni: return "उत्तरा फाल्गुनी"
            case .hasta: return "हस्त"
            case .chitra: return "चित्रा"
            case .swati: return "स्वाति"
            case .vishakha: return "विशाखा"
            case .anuradha: return "अनुराधा"
            case .jyeshtha: return "ज्येष्ठा"
            case .moola: return "मूल"
            case .purvaAshadha: return "पूर्वाषाढ़ा"
            case .uttaraAshadha: return "उत्तराषाढ़ा"
            case .shravana: return "श्रवण"
            case .dhanishta: return "धनिष्ठा"
            case .shatabhisha: return "शतभिषा"
            case .purvaBhadrapada: return "पूर्वभाद्रपद"
            case .uttaraBhadrapada: return "उत्तरभाद्रपद"
            case .revati: return "रेवती"
            }
        }

        /// Ruling planet for Vimshottari Dasha system
        var dashaRuler: CelestialBody {
            switch self {
            case .ashwini, .magha, .moola: return .southNode       // Ketu
            case .bharani, .purvaPhalguni, .purvaAshadha: return .venus
            case .krittika, .uttaraPhalguni, .uttaraAshadha: return .sun
            case .rohini, .hasta, .shravana: return .moon
            case .mrigashirsha, .chitra, .dhanishta: return .mars
            case .ardra, .swati, .shatabhisha: return .northNode   // Rahu
            case .punarvasu, .vishakha, .purvaBhadrapada: return .jupiter
            case .pushya, .anuradha, .uttaraBhadrapada: return .saturn
            case .ashlesha, .jyeshtha, .revati: return .mercury
            }
        }

        /// Brief meaning/quality of this Nakshatra
        var meaning: String {
            switch self {
            case .ashwini: return "Swift healing, new beginnings"
            case .bharani: return "Transformation, bearing life's burdens"
            case .krittika: return "Purification, cutting through illusion"
            case .rohini: return "Growth, fertility, material abundance"
            case .mrigashirsha: return "Seeking, curiosity, gentle nature"
            case .ardra: return "Storms of change, emotional intensity"
            case .punarvasu: return "Renewal, return of light, restoration"
            case .pushya: return "Nourishment, devotion, spiritual growth"
            case .ashlesha: return "Mystical wisdom, hidden knowledge"
            case .magha: return "Royal authority, ancestral power"
            case .purvaPhalguni: return "Creative joy, romance, relaxation"
            case .uttaraPhalguni: return "Patronage, friendship, generosity"
            case .hasta: return "Skillful hands, craftsmanship, healing"
            case .chitra: return "Brilliant creation, artistry, beauty"
            case .swati: return "Independence, flexibility, scattered energy"
            case .vishakha: return "Determination, single-pointed focus"
            case .anuradha: return "Devotion, friendship, cosmic harmony"
            case .jyeshtha: return "Seniority, protective authority"
            case .moola: return "Root investigation, destruction of illusion"
            case .purvaAshadha: return "Invincibility, purification by water"
            case .uttaraAshadha: return "Final victory, universal leadership"
            case .shravana: return "Listening, learning, cosmic sound"
            case .dhanishta: return "Wealth, music, cosmic rhythm"
            case .shatabhisha: return "Hundred healers, mystical healing"
            case .purvaBhadrapada: return "Scorching intensity, spiritual fire"
            case .uttaraBhadrapada: return "Deep meditation, cosmic serpent"
            case .revati: return "Nourishing journey, safe passage"
            }
        }
    }

    /// Calculate Nakshatra from Moon's sidereal longitude
    static func nakshatra(moonSiderealLongitude: Double) -> Nakshatra {
        let normalized = moonSiderealLongitude.truncatingRemainder(dividingBy: 360.0)
        let adjusted = normalized < 0 ? normalized + 360.0 : normalized
        // Each Nakshatra spans 13°20' = 13.3333°
        let index = Int(adjusted / (360.0 / 27.0))
        return Nakshatra(rawValue: min(index, 26)) ?? .ashwini
    }

    /// Calculate Nakshatra pada (quarter, 1-4)
    static func nakshatraPada(moonSiderealLongitude: Double) -> Int {
        let normalized = moonSiderealLongitude.truncatingRemainder(dividingBy: 360.0)
        let adjusted = normalized < 0 ? normalized + 360.0 : normalized
        let nakshatraSpan = 360.0 / 27.0 // 13.333°
        let positionInNakshatra = adjusted.truncatingRemainder(dividingBy: nakshatraSpan)
        let padaSpan = nakshatraSpan / 4.0 // 3.333°
        return min(Int(positionInNakshatra / padaSpan) + 1, 4)
    }

    // MARK: - Vimshottari Dasha

    /// Dasha period lengths in years for each planet (Vimshottari system, total = 120 years)
    static func dashaPeriod(for planet: CelestialBody) -> Double {
        switch planet {
        case .sun: return 6
        case .moon: return 10
        case .mars: return 7
        case .northNode: return 18   // Rahu
        case .jupiter: return 16
        case .saturn: return 19
        case .mercury: return 17
        case .southNode: return 7    // Ketu
        case .venus: return 20
        default: return 0
        }
    }

    /// Dasha sequence order (Vimshottari)
    static let dashaSequence: [CelestialBody] = [
        .southNode, .venus, .sun, .moon, .mars,
        .northNode, .jupiter, .saturn, .mercury
    ]

    /// Calculate current Maha Dasha (major planetary period) from birth Moon position
    static func currentMahaDasha(
        moonSiderealLongitude: Double,
        birthDate: Date,
        currentDate: Date = Date()
    ) -> DashaResult {
        let birthNakshatra = nakshatra(moonSiderealLongitude: moonSiderealLongitude)
        let ruler = birthNakshatra.dashaRuler

        // Calculate how far into the first dasha the person was born
        let nakshatraSpan = 360.0 / 27.0
        let posInNakshatra = moonSiderealLongitude.truncatingRemainder(dividingBy: nakshatraSpan)
        let fractionElapsed = posInNakshatra / nakshatraSpan
        let firstDashaTotal = dashaPeriod(for: ruler)
        let firstDashaRemaining = firstDashaTotal * (1.0 - fractionElapsed)

        // Walk through dasha sequence from birth
        let ageYears = currentDate.timeIntervalSince(birthDate) / (365.25 * 24 * 3600)
        var accumulated = firstDashaRemaining

        // Find starting index in dasha sequence
        guard let startIndex = dashaSequence.firstIndex(of: ruler) else {
            return DashaResult(planet: ruler, yearsRemaining: 0, totalYears: firstDashaTotal)
        }

        if ageYears < accumulated {
            return DashaResult(
                planet: ruler,
                yearsRemaining: accumulated - ageYears,
                totalYears: firstDashaTotal
            )
        }

        var currentIndex = (startIndex + 1) % dashaSequence.count
        while true {
            let planet = dashaSequence[currentIndex]
            let period = dashaPeriod(for: planet)
            if ageYears < accumulated + period {
                return DashaResult(
                    planet: planet,
                    yearsRemaining: (accumulated + period) - ageYears,
                    totalYears: period
                )
            }
            accumulated += period
            currentIndex = (currentIndex + 1) % dashaSequence.count

            // Safety: after 120 years (full cycle), wrap around
            if accumulated > 120 { accumulated -= 120 }
        }
    }

    struct DashaResult {
        let planet: CelestialBody
        let yearsRemaining: Double
        let totalYears: Double

        var planetName: String { planet.rawValue.capitalized }

        var formattedRemaining: String {
            let years = Int(yearsRemaining)
            let months = Int((yearsRemaining - Double(years)) * 12)
            if years > 0 {
                return "\(years)y \(months)m remaining"
            }
            return "\(months) months remaining"
        }
    }

    // MARK: - Vedic Chart Summary

    /// Generate a complete Vedic summary for prompt injection
    static func vedicSummary(
        moonTropicalLongitude: Double,
        birthDate: Date,
        birthYear: Int
    ) -> String {
        let siderealMoon = toSidereal(tropicalLongitude: moonTropicalLongitude, year: birthYear)
        let nak = nakshatra(moonSiderealLongitude: siderealMoon)
        let pada = nakshatraPada(moonSiderealLongitude: siderealMoon)
        let dasha = currentMahaDasha(
            moonSiderealLongitude: siderealMoon,
            birthDate: birthDate
        )

        return """
        === VEDIC ASTROLOGY ===
        Moon Nakshatra: \(nak.name) (\(nak.hindiName)), Pada \(pada)
        Nakshatra meaning: \(nak.meaning)
        Nakshatra ruler: \(nak.dashaRuler.rawValue.capitalized)
        Current Maha Dasha: \(dasha.planetName) (\(dasha.formattedRemaining))
        """
    }
}
