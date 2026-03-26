import SwiftUI

struct ChartWheelView: View {
    let chart: BirthChartData

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 20

            drawOuterRing(context: context, center: center, radius: radius)
            drawHouses(context: context, center: center, radius: radius)
            drawZodiacSymbols(context: context, center: center, radius: radius)
            drawAspectLines(context: context, center: center, radius: radius * 0.55)
            drawPlanets(context: context, center: center, radius: radius * 0.7)
        }
        .frame(minHeight: 300)
    }

    // MARK: - Outer Ring

    private func drawOuterRing(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        // Outer circle
        let outerPath = Path(ellipseIn: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))
        context.stroke(outerPath, with: .color(CelestiaTheme.gold.opacity(0.6)), lineWidth: 1.5)

        // Inner circle (planet track)
        let innerRadius = radius * 0.8
        let innerPath = Path(ellipseIn: CGRect(
            x: center.x - innerRadius,
            y: center.y - innerRadius,
            width: innerRadius * 2,
            height: innerRadius * 2
        ))
        context.stroke(innerPath, with: .color(CelestiaTheme.gold.opacity(0.3)), lineWidth: 0.5)

        // Center circle
        let centerRadius = radius * 0.4
        let centerPath = Path(ellipseIn: CGRect(
            x: center.x - centerRadius,
            y: center.y - centerRadius,
            width: centerRadius * 2,
            height: centerRadius * 2
        ))
        context.stroke(centerPath, with: .color(CelestiaTheme.purple.opacity(0.3)), lineWidth: 0.5)
    }

    // MARK: - Houses

    private func drawHouses(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        for cusp in chart.houses {
            let angle = degreesToAngle(cusp.longitude)
            let outerPoint = pointOnCircle(center: center, radius: radius, angle: angle)
            let innerPoint = pointOnCircle(center: center, radius: radius * 0.4, angle: angle)

            var path = Path()
            path.move(to: innerPoint)
            path.addLine(to: outerPoint)
            context.stroke(path, with: .color(CelestiaTheme.gold.opacity(0.2)), lineWidth: 0.5)
        }
    }

    // MARK: - Zodiac Symbols

    private func drawZodiacSymbols(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let symbolRadius = radius * 0.9
        for (index, sign) in ZodiacSign.allCases.enumerated() {
            let midDegree = Double(index) * 30.0 + 15.0
            let angle = degreesToAngle(midDegree)
            let point = pointOnCircle(center: center, radius: symbolRadius, angle: angle)

            let text = Text(sign.symbol).font(.system(size: 14))
            context.draw(context.resolve(text), at: point)
        }
    }

    // MARK: - Aspect Lines

    private func drawAspectLines(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let significantAspects = chart.aspects.filter { $0.orb < 5 }.prefix(12)

        for aspect in significantAspects {
            guard let p1 = chart.planets.first(where: { $0.body == aspect.body1 }),
                  let p2 = chart.planets.first(where: { $0.body == aspect.body2 }) else { continue }

            let angle1 = degreesToAngle(p1.longitude)
            let angle2 = degreesToAngle(p2.longitude)
            let point1 = pointOnCircle(center: center, radius: radius, angle: angle1)
            let point2 = pointOnCircle(center: center, radius: radius, angle: angle2)

            var path = Path()
            path.move(to: point1)
            path.addLine(to: point2)

            let color: Color = switch aspect.type {
            case .conjunction: CelestiaTheme.gold
            case .trine, .sextile: .green
            case .square, .opposition: .red.opacity(0.7)
            }

            context.stroke(path, with: .color(color.opacity(0.4)), lineWidth: 0.8)
        }
    }

    // MARK: - Planets

    private func drawPlanets(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        for planet in chart.planets {
            let angle = degreesToAngle(planet.longitude)
            let point = pointOnCircle(center: center, radius: radius, angle: angle)

            let text = Text(planet.body.symbol).font(.system(size: 16, weight: .bold))
            context.draw(context.resolve(text), at: point)
        }
    }

    // MARK: - Math Helpers

    private func degreesToAngle(_ degrees: Double) -> Double {
        // Astrological charts: 0° Aries = left (9 o'clock), counterclockwise
        return -(degrees - 180) * .pi / 180
    }

    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        CGPoint(
            x: center.x + radius * CGFloat(cos(angle)),
            y: center.y + radius * CGFloat(sin(angle))
        )
    }
}
