import Foundation
import SwissEphemeris

final class TransitEngine {

    static let shared = TransitEngine()
    private init() {}

    /// Calculate current transits relative to a natal chart
    func calculateTransits(
        natalChart: BirthChartData,
        transitDate: Date = Date()
    ) -> [TransitData] {
        var transits: [TransitData] = []

        // Get current planetary positions
        let currentPlanets = currentPositions(date: transitDate)

        // Check transits to natal planets
        for current in currentPlanets {
            for natal in natalChart.planets {
                let angle = angleBetween(current.degree, natal.degree)

                for aspectType in AspectType.allCases {
                    let diff = abs(angle - aspectType.angle)
                    if diff <= aspectType.orb * 0.75 { // tighter orbs for transits
                        transits.append(TransitData(
                            transiting: current.body,
                            natalTarget: natal.body,
                            aspectType: aspectType,
                            houseEntering: nil,
                            sign: current.sign,
                            description: "\(current.body.symbol) \(current.body.rawValue.capitalized) \(aspectType.rawValue) natal \(natal.body.symbol) \(natal.body.rawValue.capitalized)"
                        ))
                    }
                }
            }

            // Check house ingress (planet entering a new house)
            let house = houseForTransit(current.degree, natalHouses: natalChart.houses)
            let natalHouseSign = natalChart.houses.first(where: { $0.house == house })?.sign
            if current.sign == natalHouseSign {
                transits.append(TransitData(
                    transiting: current.body,
                    natalTarget: nil,
                    aspectType: nil,
                    houseEntering: house,
                    sign: current.sign,
                    description: "\(current.body.symbol) \(current.body.rawValue.capitalized) entering house \(house)"
                ))
            }
        }

        // Deduplicate and sort by importance (outer planets first)
        return Array(Set(transits.map { $0.description }).compactMap { desc in
            transits.first(where: { $0.description == desc })
        }).sorted { importance($0) > importance($1) }
    }

    /// Check for significant upcoming transits (for notifications)
    func significantTransitsToday(natalChart: BirthChartData) -> [TransitData] {
        let all = calculateTransits(natalChart: natalChart)
        return all.filter { importance($0) >= 5 }
    }

    // MARK: - Private

    private func currentPositions(date: Date) -> [PlanetPlacement] {
        let bodies: [(CelestialBody, Planet)] = [
            (.sun, .sun), (.moon, .moon), (.mercury, .mercury),
            (.venus, .venus), (.mars, .mars), (.jupiter, .jupiter),
            (.saturn, .saturn), (.uranus, .uranus), (.neptune, .neptune),
            (.pluto, .pluto)
        ]

        return bodies.map { body, planet in
            let coord = Coordinate<Planet>(planet: planet, date: date)
            let lng = coord.longitude
            let sign = ZodiacSign.from(longitude: lng)
            return PlanetPlacement(
                body: body, sign: sign, house: 0,
                degree: lng,
                signDegree: lng.truncatingRemainder(dividingBy: 30.0),
                isRetrograde: coord.speedLongitude < 0,
                dignity: Dignity.calculate(body: body, sign: sign)
            )
        }
    }

    private func importance(_ transit: TransitData) -> Int {
        var score = 0
        // Outer planets = more significant
        switch transit.transiting {
        case .pluto: score += 10
        case .neptune: score += 9
        case .uranus: score += 8
        case .saturn: score += 7
        case .jupiter: score += 6
        case .mars: score += 4
        case .venus: score += 3
        case .sun: score += 3
        case .mercury: score += 2
        case .moon: score += 1
        default: score += 1
        }
        // Conjunctions and oppositions most impactful
        switch transit.aspectType {
        case .conjunction: score += 3
        case .opposition: score += 2
        case .square: score += 2
        case .trine: score += 1
        case .sextile: score += 1
        case .none: break
        }
        return score
    }

    private func angleBetween(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b)
        return diff > 180 ? 360 - diff : diff
    }

    private func houseForTransit(_ degree: Double, natalHouses: [HouseCuspData]) -> Int {
        let cusps = natalHouses.sorted(by: { $0.house < $1.house }).map { $0.degree }
        for i in 0..<12 {
            let start = cusps[i]
            let end = cusps[(i + 1) % 12]
            if start < end {
                if degree >= start && degree < end { return i + 1 }
            } else {
                if degree >= start || degree < end { return i + 1 }
            }
        }
        return 1
    }
}
