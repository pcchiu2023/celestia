import SwiftUI

/// Animated birth chart reveal shown after onboarding completes.
/// The chart wheel fades in with a cosmic rotation animation.
struct ChartRevealView: View {
    let profile: UserProfile
    let onContinue: () -> Void

    @State private var showChart = false
    @State private var showDetails = false
    @State private var rotation: Double = -180
    @State private var scale: CGFloat = 0.3

    var body: some View {
        ZStack {
            CelestiaTheme.darkBg.ignoresSafeArea()
            StarFieldView()

            VStack(spacing: 32) {
                Spacer()

                // Chart wheel with entrance animation
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [CelestiaTheme.purple.opacity(0.4), .clear],
                                center: .center,
                                startRadius: 80,
                                endRadius: 200
                            )
                        )
                        .frame(width: 300, height: 300)
                        .opacity(showChart ? 1 : 0)

                    // Chart wheel
                    if let chart = profile.chartData {
                        ChartWheelView(chart: chart)
                            .frame(width: 240, height: 240)
                            .rotationEffect(.degrees(rotation))
                            .scaleEffect(scale)
                            .opacity(showChart ? 1 : 0)
                    }
                }

                // Sign + details
                if showDetails {
                    VStack(spacing: 12) {
                        if let chart = profile.chartData,
                           let sunPlacement = chart.planets.first(where: { $0.body == .sun }) {
                            Text("☉ Sun in \(sunPlacement.sign.rawValue.capitalized)")
                                .font(.title2.bold())
                                .foregroundStyle(CelestiaTheme.gold)
                        }

                        Text("Your cosmic blueprint is ready")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))

                        if let chart = profile.chartData {
                            let moonSign = chart.planets.first(where: { $0.body == .moon })?.sign.rawValue.capitalized ?? ""
                            let rising = chart.planets.first(where: { $0.body == .sun })?.sign.rawValue.capitalized ?? "" // Approximate
                            Text("☽ Moon in \(moonSign)")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()

                // Continue button
                if showDetails {
                    Button(action: onContinue) {
                        Text("Explore Your Stars")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [CelestiaTheme.purple, CelestiaTheme.gold.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 32)
                    .transition(.opacity)
                }

                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            // Stage 1: Chart wheel appears with rotation
            withAnimation(.easeOut(duration: 1.5)) {
                showChart = true
                rotation = 0
                scale = 1.0
            }

            // Stage 2: Details fade in
            withAnimation(.easeOut(duration: 0.8).delay(1.8)) {
                showDetails = true
            }
        }
    }
}
