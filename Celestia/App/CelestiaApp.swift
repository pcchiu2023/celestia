import SwiftUI
import SwiftData
import UserNotifications

@main
struct CelestiaApp: App {
    let modelContainer: ModelContainer
    @StateObject private var brain = CelestiaBrain()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var stardustManager = StardustManager()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        do {
            modelContainer = try ModelContainer(
                for: UserProfile.self,
                Reading.self,
                TarotReading.self,
                Contact.self,
                ChatMessage.self,
                StardustBalance.self,
                ReferralEvent.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(brain)
                .environmentObject(subscriptionManager)
                .environmentObject(stardustManager)
                .onAppear {
                    stardustManager.configure(modelContext: modelContainer.mainContext)
                }
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhase(newPhase)
        }
    }

    /// Pre-generate daily (and weekly on Mondays) readings in the background.
    /// Cached in SwiftData so TodayView loads instantly.
    @MainActor
    private func preGenerateReadings() async {
        guard brain.isModelLoaded else { return }
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        guard let profile = try? context.fetch(descriptor).first,
              profile.onboardingComplete else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Check if we already have a daily reading for today
        let dailyType = ReadingType.daily.rawValue
        let dailyDescriptor = FetchDescriptor<Reading>(
            predicate: #Predicate<Reading> { $0.type == dailyType && $0.createdAt >= today }
        )
        let hasTodaysReading = ((try? context.fetchCount(dailyDescriptor)) ?? 0) > 0

        if !hasTodaysReading {
            let generator = ReadingGenerator(brain: brain)
            let parsed = await generator.generateDailyReading(
                profile: profile, modelContext: context
            )
            if !parsed.reading.isEmpty {
                let reading = Reading(
                    type: .daily,
                    content: parsed.reading,
                    energy: (parsed.energyLove, parsed.energyCareer, parsed.energyHealth, parsed.energySpiritual),
                    keyTheme: parsed.keyTheme,
                    actionAdvice: parsed.actionAdvice,
                    language: profile.appLanguage
                )
                context.insert(reading)
                try? context.save()
            }
        }

        // Weekly reading on Mondays
        if calendar.component(.weekday, from: Date()) == 2 { // Monday
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? today
            let weeklyType = ReadingType.weekly.rawValue
            let weeklyDescriptor = FetchDescriptor<Reading>(
                predicate: #Predicate<Reading> { $0.type == weeklyType && $0.createdAt >= weekStart }
            )
            let hasWeeklyReading = ((try? context.fetchCount(weeklyDescriptor)) ?? 0) > 0

            if !hasWeeklyReading {
                let generator = ReadingGenerator(brain: brain)
                let raw = await generator.generateWeeklyReading(
                    section: "overview", profile: profile, modelContext: context
                )
                if !raw.isEmpty {
                    let reading = Reading(type: .weekly, content: raw, language: profile.appLanguage)
                    context.insert(reading)
                    try? context.save()
                }
            }
        }
    }

    /// Handle referral deep links: celestia://refer/{code} or https://celestia.app/refer/{code}
    private func handleDeepLink(_ url: URL) {
        let path = url.pathComponents
        // Match: /refer/{code}
        if let referIndex = path.firstIndex(of: "refer"),
           referIndex + 1 < path.count {
            let code = path[referIndex + 1]
            guard code.count == 8 else { return }

            let context = modelContainer.mainContext
            let descriptor = FetchDescriptor<UserProfile>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            if let profile = try? context.fetch(descriptor).first {
                // Don't apply own referral code
                guard profile.referralCode != code else { return }

                // Check if already referred
                let existingDescriptor = FetchDescriptor<ReferralEvent>(
                    predicate: #Predicate<ReferralEvent> { $0.referralCode == code }
                )
                let alreadyReferred = ((try? context.fetchCount(existingDescriptor)) ?? 0) > 0
                guard !alreadyReferred else { return }

                // Only reward after onboarding complete
                if profile.onboardingComplete {
                    // Record referral and reward stardust
                    stardustManager.addReferralReward(referralCode: code)
                }
            }
        }
    }

    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background:
            Task { @MainActor in
                let context = modelContainer.mainContext
                let descriptor = FetchDescriptor<UserProfile>(
                    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
                )
                if let profile = try? context.fetch(descriptor).first {
                    await TransitAlertManager.shared.scheduleAlerts(
                        profile: profile,
                        brain: brain,
                        modelContext: context
                    )
                }
            }
        case .active:
            UNUserNotificationCenter.current().setBadgeCount(0)
            Task { await subscriptionManager.checkSubscriptionStatus() }
            // Claim daily stardust reward on app open
            _ = stardustManager.claimDailyReward()
            // Pre-generate daily reading in background (cached for 24h)
            Task { @MainActor in
                await preGenerateReadings()
            }
        default:
            break
        }
    }
}
