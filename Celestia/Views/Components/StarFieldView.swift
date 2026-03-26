import SwiftUI

struct StarFieldView: View {

    private let starCount = 80
    @State private var stars: [Star] = []

    struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat        // 0-1 normalized
        let y: CGFloat        // 0-1 normalized
        let size: CGFloat     // 1-3
        let baseOpacity: Double
        let twinkleSpeed: Double  // seconds per cycle
        let phase: Double     // 0-2π starting phase
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                for star in stars {
                    let x = star.x * size.width
                    let y = star.y * size.height

                    // Twinkling: sinusoidal opacity
                    let twinkle = sin(time / star.twinkleSpeed + star.phase)
                    let opacity = star.baseOpacity * (0.5 + 0.5 * twinkle)

                    let rect = CGRect(
                        x: x - star.size / 2,
                        y: y - star.size / 2,
                        width: star.size,
                        height: star.size
                    )

                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(.white.opacity(opacity))
                    )
                }
            }
        }
        .onAppear {
            generateStars()
        }
        .allowsHitTesting(false)
    }

    private func generateStars() {
        stars = (0..<starCount).map { _ in
            Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...3),
                baseOpacity: Double.random(in: 0.3...0.8),
                twinkleSpeed: Double.random(in: 1.5...4.0),
                phase: Double.random(in: 0...(2 * .pi))
            )
        }
    }
}

#Preview {
    ZStack {
        CelestiaTheme.darkBg.ignoresSafeArea()
        StarFieldView()
    }
}
