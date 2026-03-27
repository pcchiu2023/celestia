import Foundation
import SwissEphemeris

final class ChartEngine {

    static let shared = ChartEngine()

    private init() {
        JPLFileManager.setEphemerisPath()
    }

    // MARK: - Full Birth Chart

    func calculateBirthChart(
        date: Date,
        latitude: Double,
        longitude: Double
    ) -> BirthChartData {
        let planets = calculatePlanets(date: date, latitude: latitude, longitude: longitude)
        let houses = calculateHouses(date: date, latitude: latitude, longitude: longitude)
        let aspects = calculateAspects(planets: planets)

        let ascSign = houses.first(where: { $0.house == 1 })?.sign ?? .aries
        let mcSign = houses.first(where: { $0.house == 10 })?.sign ?? .capricorn

        return BirthChartData(
            planets: planets,
            houses: houses,
            aspects: aspects,
            ascendantSign: ascSign,
            mcSign: mcSign,
            calculatedAt: Date()
        )
    }

    // MARK: - Planet Positions

    private func calculatePlanets(
        date: Date,
        latitude: Double,
        longitude: Double
    ) -> [PlanetPlacement] {
        let houseCusps = HouseCusps(
            date: date,
            latitude: latitude,
            longitude: longitude,
            houseSystem: .placidus
        )
        let cuspDegrees = extractCuspDegrees(houseCusps)

        let swissPlanets: [(CelestialBody, Planet)] = [
            (.sun, .sun), (.moon, .moon), (.mercury, .mercury),
            (.venus, .venus), (.mars, .mars), (.jupiter, .jupiter),
            (.saturn, .saturn), (.uranus, .uranus), (.neptune, .neptune),
            (.pluto, .pluto)
        ]

        var placements: [PlanetPlacement] = []

        for (body, planet) in swissPlanets {
            let coord = Coordinate<Planet>(body: planet, date: date)
            let lng = coord.longitude
            let sign = ZodiacSign.from(longitude: lng)
            let signDeg = lng.truncatingRemainder(dividingBy: 30.0)
            let house = houseForDegree(lng, cusps: cuspDegrees)
            let retrograde = coord.speedLongitude < 0

            placements.append(PlanetPlacement(
                body: body,
                sign: sign,
                house: house,
                degree: lng,
                signDegree: signDeg,
                isRetrograde: retrograde,
                dignity: Dignity.calculate(body: body, sign: sign)
            ))
        }

        // Lunar nodes
        let northNode = Coordinate<LunarNorthNode>(body: .meanNode, date: date)
        let nnLng = northNode.longitude
        let nnSign = ZodiacSign.from(longitude: nnLng)
        placements.append(PlanetPlacement(
            body: .northNode, sign: nnSign,
            house: houseForDegree(nnLng, cusps: cuspDegrees),
            degree: nnLng, signDegree: nnLng.truncatingRemainder(dividingBy: 30.0),
            isRetrograde: true, dignity: .peregrine
        ))

        let snLng = (nnLng + 180).truncatingRemainder(dividingBy: 360)
        let snSign = ZodiacSign.from(longitude: snLng)
        placements.append(PlanetPlacement(
            body: .southNode, sign: snSign,
            house: houseForDegree(snLng, cusps: cuspDegrees),
            degree: snLng, signDegree: snLng.truncatingRemainder(dividingBy: 30.0),
            isRetrograde: true, dignity: .peregrine
        ))

        return placements
    }

    // MARK: - House Cusps

    private func calculateHouses(
        date: Date,
        latitude: Double,
        longitude: Double
    ) -> [HouseCuspData] {
        let cusps = HouseCusps(
            date: date,
            latitude: latitude,
            longitude: longitude,
            houseSystem: .placidus
        )

        let cuspProperties: [KeyPath<HouseCusps, Cusp>] = [
            \.first, \.second, \.third, \.fourth, \.fifth, \.sixth,
            \.seventh, \.eighth, \.ninth, \.tenth, \.eleventh, \.twelfth
        ]

        return cuspProperties.enumerated().map { index, keyPath in
            let cusp = cusps[keyPath: keyPath]
            let lng = cusp.tropical.value
            return HouseCuspData(
                house: index + 1,
                sign: ZodiacSign.from(longitude: lng),
                degree: lng
            )
        }
    }

    // MARK: - Aspects

    private func calculateAspects(planets: [PlanetPlacement]) -> [AspectData] {
        var aspects: [AspectData] = []
        let mainPlanets = planets.filter {
            $0.body != .northNode && $0.body != .southNode
        }

        for i in 0..<mainPlanets.count {
            for j in (i+1)..<mainPlanets.count {
                let p1 = mainPlanets[i]
                let p2 = mainPlanets[j]
                let angle = angleBetween(p1.degree, p2.degree)

                for aspectType in AspectType.allCases {
                    let diff = abs(angle - aspectType.angle)
                    if diff <= aspectType.orb {
                        aspects.append(AspectData(
                            body1: p1.body,
                            body2: p2.body,
                            type: aspectType,
                            orb: diff,
                            isApplying: p1.isRetrograde != p2.isRetrograde
                        ))
                    }
                }
            }
        }

        return aspects.sorted { $0.orb < $1.orb }
    }

    // MARK: - Helpers

    private func angleBetween(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b)
        return diff > 180 ? 360 - diff : diff
    }

    private func houseForDegree(_ degree: Double, cusps: [Double]) -> Int {
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

    private func extractCuspDegrees(_ cusps: HouseCusps) -> [Double] {
        let keyPaths: [KeyPath<HouseCusps, Cusp>] = [
            \.first, \.second, \.third, \.fourth, \.fifth, \.sixth,
            \.seventh, \.eighth, \.ninth, \.tenth, \.eleventh, \.twelfth
        ]
        return keyPaths.map { cusps[keyPath: $0].tropical.value }
    }
}

extension AspectType: CaseIterable {
    static var allCases: [AspectType] {
        [.conjunction, .sextile, .square, .trine, .opposition]
    }
}
