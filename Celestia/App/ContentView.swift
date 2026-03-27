import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var brain: CelestiaBrain
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var stardustManager: StardustManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserProfile.createdAt, order: .reverse) private var profiles: [UserProfile]

    @State private var showOnboarding = false
    @State private var onboardingName = ""
    @State private var onboardingBirthDate = Date()
    @State private var onboardingBirthTime = Date()
    @State private var onboardingBirthCity = ""
    @State private var onboardingLatitude: Double = 0
    @State private var onboardingLongitude: Double = 0
    @State private var onboardingLanguage: AppLanguage = .en
    @State private var onboardingStep = 0

    private var hasProfile: Bool {
        profiles.first?.onboardingComplete == true
    }

    var body: some View {
        ZStack {
            if hasProfile {
                mainTabView
            } else {
                onboardingView
            }
        }
        .onAppear {
            if !hasProfile {
                showOnboarding = true
            }
        }
    }

    // MARK: - Main Tab View

    private var mainTabView: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max.fill") }

            TarotView()
                .tabItem { Label("Tarot", systemImage: "sparkles") }

            ChatView()
                .tabItem { Label("Chat", systemImage: "bubble.left.fill") }

            CompatibilityView()
                .tabItem { Label("Match", systemImage: "heart.fill") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .tint(CelestiaTheme.gold)
    }

    // MARK: - Onboarding

    private var onboardingView: some View {
        ZStack {
            CelestiaTheme.darkBg.ignoresSafeArea()
            StarFieldView()

            VStack {
                switch onboardingStep {
                case 0:
                    welcomeStep
                case 1:
                    LanguagePickerView(selectedLanguage: $onboardingLanguage) {
                        withAnimation { onboardingStep = 2 }
                    }
                case 2:
                    BirthDataView(
                        name: $onboardingName,
                        birthDate: $onboardingBirthDate,
                        birthTime: $onboardingBirthTime,
                        birthCity: $onboardingBirthCity,
                        birthLatitude: $onboardingLatitude,
                        birthLongitude: $onboardingLongitude
                    ) {
                        completeOnboarding()
                    }
                default:
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Welcome Step

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [CelestiaTheme.gold, CelestiaTheme.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Celestia")
                .font(.custom("Georgia", size: 42))
                .foregroundStyle(CelestiaTheme.gold)

            Text("Your Personal AI Astrologer")
                .font(CelestiaTheme.subheadingFont)
                .foregroundStyle(CelestiaTheme.textSecondary)

            Text("100% on-device · Your data never leaves your phone")
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.textSecondary.opacity(0.7))

            Spacer()

            Button {
                withAnimation { onboardingStep = 1 }
            } label: {
                Text("Begin Your Journey")
                    .font(CelestiaTheme.bodyFont)
                    .fontWeight(.semibold)
                    .foregroundStyle(CelestiaTheme.navy)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [CelestiaTheme.gold, CelestiaTheme.gold.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Complete Onboarding

    private func completeOnboarding() {
        let calendar = Calendar.current
        let dateComps = calendar.dateComponents([.year, .month, .day], from: onboardingBirthDate)
        let timeComps = calendar.dateComponents([.hour, .minute], from: onboardingBirthTime)
        var merged = DateComponents()
        merged.year = dateComps.year
        merged.month = dateComps.month
        merged.day = dateComps.day
        merged.hour = timeComps.hour
        merged.minute = timeComps.minute

        guard let fullDate = calendar.date(from: merged) else { return }

        let profile = UserProfile(
            name: onboardingName,
            birthDate: onboardingBirthDate,
            birthTime: onboardingBirthTime,
            birthCity: onboardingBirthCity,
            birthLatitude: onboardingLatitude,
            birthLongitude: onboardingLongitude,
            language: onboardingLanguage
        )

        // Calculate birth chart
        let chart = ChartEngine.shared.calculateBirthChart(
            date: fullDate,
            latitude: onboardingLatitude,
            longitude: onboardingLongitude
        )
        profile.chartData = chart
        profile.onboardingComplete = true

        modelContext.insert(profile)

        // Request notification permission
        Task {
            await TransitAlertManager.shared.requestPermission()
        }
    }
}
