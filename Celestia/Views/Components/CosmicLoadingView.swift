import SwiftUI

/// Mystical loading animation for batch AI generation.
/// Shows cosmic visuals while the reading generates in the background.
struct CosmicLoadingView: View {
    let message: String
    @State private var rotation: Double = 0
    @State private var pulse: Bool = false
    @State private var starOpacity: [Double] = (0..<12).map { _ in Double.random(in: 0.2...0.8) }

    var body: some View {
        VStack(spacing: 24) {
            // Cosmic orb animation
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                CelestiaTheme.purple.opacity(0.3),
                                CelestiaTheme.gold.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(pulse ? 1.1 : 0.9)

                // Rotating star ring
                ForEach(0..<12, id: \.self) { i in
                    Image(systemName: "sparkle")
                        .font(.system(size: 10))
                        .foregroundStyle(CelestiaTheme.gold.opacity(starOpacity[i]))
                        .offset(y: -50)
                        .rotationEffect(.degrees(Double(i) * 30 + rotation))
                }

                // Center symbol
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [CelestiaTheme.gold, CelestiaTheme.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(pulse ? 1.15 : 1.0)
            }

            // Message
            Text(message)
                .font(CelestiaTheme.bodyFont)
                .foregroundStyle(CelestiaTheme.textSecondary)
                .opacity(pulse ? 1.0 : 0.7)

            // Subtle progress dots
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(CelestiaTheme.gold)
                        .frame(width: 6, height: 6)
                        .opacity(pulse && i == Int(rotation / 120) % 3 ? 1.0 : 0.3)
                }
            }
        }
        .padding(40)
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                pulse = true
            }
            // Twinkle effect
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                let index = Int.random(in: 0..<12)
                withAnimation(.easeInOut(duration: 0.3)) {
                    starOpacity[index] = Double.random(in: 0.2...1.0)
                }
            }
        }
    }
}

/// Animated reveal container for completed readings
struct ReadingRevealView<Content: View>: View {
    let content: Content
    @State private var revealed = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .opacity(revealed ? 1 : 0)
            .scaleEffect(revealed ? 1 : 0.95)
            .offset(y: revealed ? 0 : 10)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                    revealed = true
                }
            }
    }
}
