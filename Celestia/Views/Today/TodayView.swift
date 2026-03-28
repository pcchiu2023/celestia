import SwiftUI
import SwiftData

struct TodayView: View {
    @EnvironmentObject var brain: CelestiaBrain
    @EnvironmentObject var stardustManager: StardustManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var todayReading: ParsedReading?
    @State private var isLoading = false
    @State private var dailyRewardEarned: Int = 0
    @State private var showRewardBanner = false

    private var profile: UserProfile? { profiles.first }

    private var characterMood: CaelusMood {
        guard let reading = todayReading else { return .welcoming }
        return CaelusMoodRouter.resolve(
            energyLove: reading.energyLove,
            energyCareer: reading.energyCareer,
            energyHealth: reading.energyHealth,
            energySpiritual: reading.energySpiritual,
            keyTheme: reading.keyTheme
        )
    }
    private var l: L10n { L10n(lang: profile?.appLanguage ?? .en) }
    private var isSubscriber: Bool { subscriptionManager.isSubscribed }

    var body: some View {
        ZStack {
            CelestiaTheme.darkBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Stardust balance bar
                    stardustBar

                    // Header
                    if let profile {
                        Text(l.goodGreeting(timeOfDay, profile.name))
                            .font(CelestiaTheme.subheadingFont)
                            .foregroundColor(CelestiaTheme.textPrimary)

                        if let chart = profile.chartData {
                            Text("\(chart.sunSign.rawValue.capitalized) Sun \(chart.sunSign.symbol)")
                                .font(CelestiaTheme.captionFont)
                                .foregroundColor(CelestiaTheme.purple)
                        }
                    }

                    // Daily reward banner
                    if showRewardBanner {
                        dailyRewardBanner
                    }

                    // Caelus character
                    CaelusCharacterView(mood: characterMood)

                    // Daily Reading Card
                    if isLoading {
                        CosmicLoadingView(message: l.readingStars)
                    } else if let reading = todayReading {
                        ReadingRevealView {
                            VStack(spacing: 16) {
                                readingCard(reading)
                                energyMeters(reading)
                                luckyElements(reading)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .task {
            claimDailyReward()
            await loadTodayReading()
        }
    }

    // MARK: - Stardust Bar

    private var stardustBar: some View {
        HStack {
            Image(systemName: "sparkle")
                .foregroundStyle(CelestiaTheme.gold)
            Text("\(stardustManager.balance)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(CelestiaTheme.gold)
            Text(l.stardust)
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.textSecondary)

            Spacer()

            if stardustManager.streak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                        .font(.system(size: 12))
                    Text("\(stardustManager.streak) \(l.dayStreak)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(CelestiaTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Daily Reward Banner

    private var dailyRewardBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "gift.fill")
                .foregroundStyle(CelestiaTheme.gold)
            VStack(alignment: .leading, spacing: 2) {
                Text(l.dailyStardust)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CelestiaTheme.textPrimary)
                Text("+\(dailyRewardEarned) ✦ earned")
                    .font(.system(size: 12))
                    .foregroundStyle(CelestiaTheme.gold)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CelestiaTheme.gold.opacity(0.08))
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Reading Card

    private func readingCard(_ reading: ParsedReading) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(l.todaysReading)
                .font(CelestiaTheme.captionFont)
                .foregroundColor(CelestiaTheme.gold)

            Text(reading.reading)
                .font(CelestiaTheme.bodyFont)
                .foregroundColor(CelestiaTheme.textPrimary)
                .lineSpacing(4)

            if !reading.actionAdvice.isEmpty {
                Text("✧ \(reading.actionAdvice)")
                    .font(CelestiaTheme.captionFont)
                    .foregroundColor(CelestiaTheme.gold)
                    .italic()
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Energy Meters

    private func energyMeters(_ reading: ParsedReading) -> some View {
        VStack(spacing: 12) {
            Text(l.cosmicEnergy)
                .font(CelestiaTheme.captionFont)
                .foregroundColor(CelestiaTheme.gold)

            EnergyMeterView(label: l.love, value: reading.energyLove, color: .pink)
            EnergyMeterView(label: l.career, value: reading.energyCareer, color: CelestiaTheme.gold)
            EnergyMeterView(label: l.health, value: reading.energyHealth, color: .green)
            EnergyMeterView(label: l.spiritual, value: reading.energySpiritual, color: CelestiaTheme.purple)
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Lucky Elements

    private func luckyElements(_ reading: ParsedReading) -> some View {
        HStack(spacing: 16) {
            luckyItem(icon: "paintpalette", label: reading.luckyColor)
            luckyItem(icon: "number", label: "\(reading.luckyNumber)")
            luckyItem(icon: "sparkle", label: reading.luckyCrystal)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Actions

    private func claimDailyReward() {
        let earned = stardustManager.claimDailyReward()
        if earned > 0 {
            dailyRewardEarned = earned
            withAnimation(.spring()) {
                showRewardBanner = true
            }
            // Auto-hide after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation { showRewardBanner = false }
            }
        }
    }

    private func loadTodayReading() async {
        guard let profile, brain.isModelLoaded else { return }

        // Check if we already have today's reading
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<Reading>(
            predicate: #Predicate<Reading> { $0.type == "daily" && $0.createdAt >= today }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            todayReading = ParsedReading(
                reading: existing.content,
                energyLove: existing.energyLove,
                energyCareer: existing.energyCareer,
                energyHealth: existing.energyHealth,
                energySpiritual: existing.energySpiritual,
                keyTheme: existing.keyTheme,
                actionAdvice: existing.actionAdvice,
                luckyColor: "gold", luckyNumber: 7, luckyCrystal: "amethyst"
            )
            return
        }

        // Generate new reading
        isLoading = true
        let generator = ReadingGenerator(brain: brain)
        let parsed = await generator.generateDailyReading(
            profile: profile, modelContext: modelContext,
            isDetailed: isSubscriber
        )

        // Save to SwiftData
        let reading = Reading(
            type: .daily,
            content: parsed.reading,
            energy: (parsed.energyLove, parsed.energyCareer, parsed.energyHealth, parsed.energySpiritual),
            keyTheme: parsed.keyTheme,
            actionAdvice: parsed.actionAdvice,
            language: profile.appLanguage
        )
        modelContext.insert(reading)
        try? modelContext.save()

        todayReading = parsed
        isLoading = false
    }

    private var timeOfDay: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        default: return "evening"
        }
    }

    private func luckyItem(icon: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(CelestiaTheme.gold)
            Text(label.capitalized)
                .font(CelestiaTheme.captionFont)
                .foregroundColor(CelestiaTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
