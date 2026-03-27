import Foundation

// MARK: - Zodiac Signs

enum ZodiacSign: String, Codable, CaseIterable {
    case aries, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces

    var symbol: String {
        switch self {
        case .aries: return "♈"
        case .taurus: return "♉"
        case .gemini: return "♊"
        case .cancer: return "♋"
        case .leo: return "♌"
        case .virgo: return "♍"
        case .libra: return "♎"
        case .scorpio: return "♏"
        case .sagittarius: return "♐"
        case .capricorn: return "♑"
        case .aquarius: return "♒"
        case .pisces: return "♓"
        }
    }

    var element: Element {
        switch self {
        case .aries, .leo, .sagittarius: return .fire
        case .taurus, .virgo, .capricorn: return .earth
        case .gemini, .libra, .aquarius: return .air
        case .cancer, .scorpio, .pisces: return .water
        }
    }

    var modality: Modality {
        switch self {
        case .aries, .cancer, .libra, .capricorn: return .cardinal
        case .taurus, .leo, .scorpio, .aquarius: return .fixed
        case .gemini, .virgo, .sagittarius, .pisces: return .mutable
        }
    }

    static func from(longitude: Double) -> ZodiacSign {
        let normalized = longitude.truncatingRemainder(dividingBy: 360.0)
        let index = Int(normalized / 30.0)
        return ZodiacSign.allCases[index]
    }
}

enum Element: String, Codable {
    case fire, earth, air, water
}

enum Modality: String, Codable {
    case cardinal, fixed, mutable
}

// MARK: - Planets

enum CelestialBody: String, Codable, CaseIterable {
    case sun, moon, mercury, venus, mars
    case jupiter, saturn, uranus, neptune, pluto
    case northNode, southNode

    var symbol: String {
        switch self {
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .uranus: return "♅"
        case .neptune: return "♆"
        case .pluto: return "♇"
        case .northNode: return "☊"
        case .southNode: return "☋"
        }
    }
}

// MARK: - Aspects

enum AspectType: String, Codable {
    case conjunction  // 0°
    case sextile      // 60°
    case square        // 90°
    case trine         // 120°
    case opposition    // 180°

    var angle: Double {
        switch self {
        case .conjunction: return 0
        case .sextile: return 60
        case .square: return 90
        case .trine: return 120
        case .opposition: return 180
        }
    }

    var orb: Double {
        switch self {
        case .conjunction: return 8
        case .sextile: return 6
        case .square: return 7
        case .trine: return 8
        case .opposition: return 8
        }
    }

    var nature: String {
        switch self {
        case .conjunction: return "neutral"
        case .sextile, .trine: return "harmonious"
        case .square, .opposition: return "challenging"
        }
    }
}

// MARK: - Dignity

enum Dignity: String, Codable {
    case domicile     // planet rules this sign
    case exaltation   // planet is exalted here
    case detriment    // opposite of domicile
    case fall          // opposite of exaltation
    case peregrine    // no special dignity

    static func calculate(body: CelestialBody, sign: ZodiacSign) -> Dignity {
        switch (body, sign) {
        case (.sun, .leo): return .domicile
        case (.sun, .aries): return .exaltation
        case (.sun, .aquarius): return .detriment
        case (.sun, .libra): return .fall
        case (.moon, .cancer): return .domicile
        case (.moon, .taurus): return .exaltation
        case (.moon, .capricorn): return .detriment
        case (.moon, .scorpio): return .fall
        case (.mercury, .gemini), (.mercury, .virgo): return .domicile
        case (.mercury, .virgo): return .exaltation
        case (.mercury, .sagittarius), (.mercury, .pisces): return .detriment
        case (.mercury, .pisces): return .fall
        case (.venus, .taurus), (.venus, .libra): return .domicile
        case (.venus, .pisces): return .exaltation
        case (.venus, .aries), (.venus, .scorpio): return .detriment
        case (.venus, .virgo): return .fall
        case (.mars, .aries), (.mars, .scorpio): return .domicile
        case (.mars, .capricorn): return .exaltation
        case (.mars, .taurus), (.mars, .libra): return .detriment
        case (.mars, .cancer): return .fall
        case (.jupiter, .sagittarius), (.jupiter, .pisces): return .domicile
        case (.jupiter, .cancer): return .exaltation
        case (.jupiter, .gemini), (.jupiter, .virgo): return .detriment
        case (.jupiter, .capricorn): return .fall
        case (.saturn, .capricorn), (.saturn, .aquarius): return .domicile
        case (.saturn, .libra): return .exaltation
        case (.saturn, .cancer), (.saturn, .leo): return .detriment
        case (.saturn, .aries): return .fall
        default: return .peregrine
        }
    }
}

// MARK: - Placement

struct PlanetPlacement: Codable {
    let body: CelestialBody
    let sign: ZodiacSign
    let house: Int           // 1-12
    let degree: Double       // 0-359.99
    let signDegree: Double   // 0-29.99 within the sign
    let isRetrograde: Bool
    let dignity: Dignity
}

struct HouseCuspData: Codable {
    let house: Int           // 1-12
    let sign: ZodiacSign
    let degree: Double
}

struct AspectData: Codable {
    let body1: CelestialBody
    let body2: CelestialBody
    let type: AspectType
    let orb: Double          // actual orb in degrees
    let isApplying: Bool     // getting closer or separating
}

struct BirthChartData: Codable {
    let planets: [PlanetPlacement]
    let houses: [HouseCuspData]
    let aspects: [AspectData]
    let ascendantSign: ZodiacSign
    let mcSign: ZodiacSign   // Midheaven
    let calculatedAt: Date

    var sunSign: ZodiacSign {
        planets.first(where: { $0.body == .sun })?.sign ?? .aries
    }
    var moonSign: ZodiacSign {
        planets.first(where: { $0.body == .moon })?.sign ?? .aries
    }
    var risingSign: ZodiacSign {
        ascendantSign
    }
}

// MARK: - Transit

struct TransitData: Codable {
    let transiting: CelestialBody
    let natalTarget: CelestialBody?
    let aspectType: AspectType?
    let houseEntering: Int?
    let sign: ZodiacSign
    let description: String
}

// MARK: - Reading Types

enum ReadingType: String, Codable {
    case daily
    case tarot
    case compatibility
    case weekly
    case chat
    case placement   // detailed planet placement reading
}

// MARK: - Language

enum AppLanguage: String, Codable, CaseIterable {
    case en, es, pt, ja, ko, fr, hi, de

    var displayName: String {
        switch self {
        case .en: return "English"
        case .es: return "Español"
        case .pt: return "Português"
        case .ja: return "日本語"
        case .ko: return "한국어"
        case .fr: return "Français"
        case .hi: return "हिन्दी"
        case .de: return "Deutsch"
        }
    }

    var promptInstruction: String {
        switch self {
        case .en: return "Respond in English."
        case .es: return "Responde en español."
        case .pt: return "Responda em português."
        case .ja: return "日本語で回答してください。"
        case .ko: return "한국어로 답변해 주세요."
        case .fr: return "Répondez en français."
        case .hi: return "हिन्दी में उत्तर दें।"
        case .de: return "Antworten Sie auf Deutsch."
        }
    }
}
