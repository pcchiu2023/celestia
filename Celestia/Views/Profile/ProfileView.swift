import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query(sort: \UserProfile.createdAt, order: .reverse) private var profiles: [UserProfile]
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @State private var showPaywall = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ZStack {
                CelestiaTheme.darkBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if let profile, let chart = profile.chartData {
                            chartSection(chart)
                            bigThreeSection(chart)
                            planetListSection(chart)
                        }
                        subscriptionSection
                        settingsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showPaywall) {
                PaywallView(trigger: "profile")
                    .environmentObject(subscriptionManager)
            }
        }
    }

    // MARK: - Chart

    private func chartSection(_ chart: BirthChartData) -> some View {
        VStack(spacing: 8) {
            Text(profile?.name ?? "")
                .font(CelestiaTheme.headingFont)
                .foregroundStyle(CelestiaTheme.gold)

            ChartWheelView(chart: chart)
                .frame(height: 320)
        }
    }

    // MARK: - Big Three

    private func bigThreeSection(_ chart: BirthChartData) -> some View {
        HStack(spacing: 16) {
            bigThreeCard("Sun", sign: chart.sunSign, icon: "sun.max.fill")
            bigThreeCard("Moon", sign: chart.moonSign, icon: "moon.fill")
            bigThreeCard("Rising", sign: chart.ascendantSign, icon: "arrow.up.circle.fill")
        }
    }

    private func bigThreeCard(_ label: String, sign: ZodiacSign, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(CelestiaTheme.gold)

            Text(sign.symbol)
                .font(.title)

            Text(label)
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.textSecondary)

            Text(sign.rawValue.capitalized)
                .font(CelestiaTheme.bodyFont)
                .fontWeight(.medium)
                .foregroundStyle(CelestiaTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
        )
    }

    // MARK: - Planet List

    private func planetListSection(_ chart: BirthChartData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Planets")
                .font(CelestiaTheme.subheadingFont)
                .foregroundStyle(CelestiaTheme.gold)

            ForEach(chart.planets, id: \.body) { planet in
                HStack(spacing: 12) {
                    Text(planet.body.symbol)
                        .font(.title3)
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(planet.body.rawValue.capitalized)
                                .font(CelestiaTheme.bodyFont)
                                .foregroundStyle(CelestiaTheme.textPrimary)

                            if planet.isRetrograde {
                                Text("\u{212E}")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }

                        Text("\(planet.sign.rawValue.capitalized) \(planet.sign.symbol) \u{00B7} \(Int(planet.signDegree))\u{00B0} \u{00B7} House \(planet.house)")
                            .font(CelestiaTheme.captionFont)
                            .foregroundStyle(CelestiaTheme.textSecondary)
                    }

                    Spacer()

                    if planet.dignity != .peregrine {
                        Text(planet.dignity.rawValue.capitalized)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(CelestiaTheme.gold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(CelestiaTheme.gold.opacity(0.15))
                            )
                    }
                }
                .padding(.vertical, 4)

                if planet.body != chart.planets.last?.body {
                    Divider().background(Color.white.opacity(0.05))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }

    // MARK: - Subscription

    private var subscriptionSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: subscriptionManager.isSubscribed ? "star.fill" : "star")
                    .foregroundStyle(CelestiaTheme.gold)
                Text(subscriptionManager.isSubscribed ? "Star Pass Active" : "Free Tier")
                    .font(CelestiaTheme.bodyFont)
                    .fontWeight(.medium)
                    .foregroundStyle(CelestiaTheme.textPrimary)
                Spacer()

                if subscriptionManager.isSubscribed {
                    Text(subscriptionManager.currentTier.capitalized)
                        .font(CelestiaTheme.captionFont)
                        .foregroundStyle(CelestiaTheme.gold)
                } else {
                    Button {
                        showPaywall = true
                    } label: {
                        Text("Upgrade")
                            .font(CelestiaTheme.captionFont)
                            .fontWeight(.medium)
                            .foregroundStyle(CelestiaTheme.navy)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(CelestiaTheme.gold))
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(CelestiaTheme.subheadingFont)
                .foregroundStyle(CelestiaTheme.gold)

            if let profile {
                HStack {
                    Image(systemName: "globe")
                        .foregroundStyle(CelestiaTheme.textSecondary)
                    Text("Language")
                        .font(CelestiaTheme.bodyFont)
                        .foregroundStyle(CelestiaTheme.textPrimary)
                    Spacer()
                    Text(profile.appLanguage.rawValue.uppercased())
                        .font(CelestiaTheme.captionFont)
                        .foregroundStyle(CelestiaTheme.textSecondary)
                }

                Divider().background(Color.white.opacity(0.05))

                HStack {
                    Image(systemName: "mappin.circle")
                        .foregroundStyle(CelestiaTheme.textSecondary)
                    Text("Birth City")
                        .font(CelestiaTheme.bodyFont)
                        .foregroundStyle(CelestiaTheme.textPrimary)
                    Spacer()
                    Text(profile.birthCity)
                        .font(CelestiaTheme.captionFont)
                        .foregroundStyle(CelestiaTheme.textSecondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}
