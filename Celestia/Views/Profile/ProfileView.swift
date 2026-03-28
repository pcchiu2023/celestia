import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query(sort: \UserProfile.createdAt, order: .reverse) private var profiles: [UserProfile]
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var stardustManager: StardustManager
    @Environment(\.modelContext) private var modelContext

    @State private var showPaywall = false
    @State private var showLanguagePicker = false

    private var profile: UserProfile? { profiles.first }
    private var l: L10n { L10n(lang: profile?.appLanguage ?? .en) }

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
                        stardustSection
                        subscriptionSection
                        referralSection
                        settingsSection
                    }
                    .padding()
                }
            }
            .navigationTitle(l.profile)
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showPaywall) {
                PaywallView(trigger: "profile")
                    .environmentObject(subscriptionManager)
                    .environmentObject(stardustManager)
            }
            .sheet(isPresented: $showLanguagePicker) {
                languagePickerSheet
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
            Text(l.yourPlanets)
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

    // MARK: - Stardust Balance

    private var stardustSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "sparkle")
                    .foregroundStyle(CelestiaTheme.gold)
                Text(l.stardust)
                    .font(CelestiaTheme.bodyFont)
                    .fontWeight(.medium)
                    .foregroundStyle(CelestiaTheme.textPrimary)
                Spacer()
                Text("\(stardustManager.balance) \u{2726}")
                    .font(CelestiaTheme.bodyFont)
                    .fontWeight(.bold)
                    .foregroundStyle(CelestiaTheme.gold)
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(l.streak)
                        .font(CelestiaTheme.captionFont)
                        .foregroundStyle(CelestiaTheme.textSecondary)
                    Text("\(stardustManager.streak) \(l.dayStreak)")
                        .font(CelestiaTheme.bodyFont)
                        .foregroundStyle(CelestiaTheme.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(l.balance)
                        .font(CelestiaTheme.captionFont)
                        .foregroundStyle(CelestiaTheme.textSecondary)
                    Text("\(stardustManager.balance) \u{2726}")
                        .font(CelestiaTheme.bodyFont)
                        .foregroundStyle(CelestiaTheme.textPrimary)
                }
            }

            if !stardustManager.dailyRewardClaimed {
                Button {
                    _ = stardustManager.claimDailyReward()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "gift.fill")
                        Text(l.claimDaily)
                    }
                    .font(CelestiaTheme.captionFont)
                    .fontWeight(.medium)
                    .foregroundStyle(CelestiaTheme.navy)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(CelestiaTheme.gold)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
        )
    }

    // MARK: - Subscription

    private var subscriptionSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: subscriptionManager.isSubscribed ? "star.fill" : "star")
                    .foregroundStyle(CelestiaTheme.gold)
                Text(subscriptionManager.isSubscribed ? l.starPassActive : l.freeTier)
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
                        Text(l.upgrade)
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

    // MARK: - Referral

    private var referralSection: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(CelestiaTheme.gold)
                Text(l.referFriend)
                    .font(CelestiaTheme.bodyFont)
                    .fontWeight(.medium)
                    .foregroundStyle(CelestiaTheme.textPrimary)
                Spacer()
                Text("15 \u{2726}")
                    .font(CelestiaTheme.captionFont)
                    .foregroundStyle(CelestiaTheme.gold)
            }

            if let code = profile?.referralCode {
                HStack {
                    Text(code)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(CelestiaTheme.gold)
                    Spacer()
                    Button {
                        UIPasteboard.general.string = code
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                            .foregroundStyle(CelestiaTheme.textSecondary)
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.03))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
        )
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(l.settings)
                .font(CelestiaTheme.subheadingFont)
                .foregroundStyle(CelestiaTheme.gold)

            if let profile {
                Button {
                    showLanguagePicker = true
                } label: {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundStyle(CelestiaTheme.textSecondary)
                        Text(l.language)
                            .font(CelestiaTheme.bodyFont)
                            .foregroundStyle(CelestiaTheme.textPrimary)
                        Spacer()
                        Text(profile.appLanguage.displayName)
                            .font(CelestiaTheme.captionFont)
                            .foregroundStyle(CelestiaTheme.textSecondary)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(CelestiaTheme.textSecondary)
                    }
                }

                Divider().background(Color.white.opacity(0.05))

                HStack {
                    Image(systemName: "mappin.circle")
                        .foregroundStyle(CelestiaTheme.textSecondary)
                    Text(l.birthCity)
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

    // MARK: - Language Picker Sheet

    private var languagePickerSheet: some View {
        NavigationStack {
            ZStack {
                CelestiaTheme.darkBg.ignoresSafeArea()

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Button {
                                profile?.language = lang.rawValue
                                try? modelContext.save()
                                showLanguagePicker = false
                            } label: {
                                Text(lang.displayName)
                                    .font(CelestiaTheme.bodyFont)
                                    .fontWeight(.medium)
                                    .foregroundStyle(profile?.appLanguage == lang ? CelestiaTheme.darkBg : CelestiaTheme.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(profile?.appLanguage == lang ? CelestiaTheme.gold : Color.white.opacity(0.1))
                                    )
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(l.chooseLanguage)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(l.cancel) {
                        showLanguagePicker = false
                    }
                    .foregroundStyle(CelestiaTheme.gold)
                }
            }
        }
    }
}
