import SwiftUI
import SwiftData

struct TodayView: View {
    @EnvironmentObject var brain: CelestiaBrain
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var todayReading: ParsedReading?
    @State private var isLoading = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ZStack {
            CelestiaTheme.darkBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    if let profile {
                        Text("☽ Good \(timeOfDay), \(profile.name)")
                            .font(CelestiaTheme.subheadingFont)
                            .foregroundColor(CelestiaTheme.textPrimary)

                        if let chart = profile.chartData {
                            Text("\(chart.sunSign.rawValue.capitalized) Sun \(chart.sunSign.symbol)")
                                .font(CelestiaTheme.captionFont)
                                .foregroundColor(CelestiaTheme.purple)
                        }
                    }

                    // Daily Reading Card
                    if isLoading {
                        ProgressView("Reading the stars...")
                            .foregroundColor(CelestiaTheme.textSecondary)
                            .padding(40)
                    } else if let reading = todayReading {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("TODAY'S READING")
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

                        // Energy Meters
                        VStack(spacing: 12) {
                            Text("COSMIC ENERGY")
                                .font(CelestiaTheme.captionFont)
                                .foregroundColor(CelestiaTheme.gold)

                            EnergyMeterView(label: "Love", value: reading.energyLove, color: .pink)
                            EnergyMeterView(label: "Career", value: reading.energyCareer, color: CelestiaTheme.gold)
                            EnergyMeterView(label: "Health", value: reading.energyHealth, color: .green)
                            EnergyMeterView(label: "Spiritual", value: reading.energySpiritual, color: CelestiaTheme.purple)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)

                        // Lucky Elements
                        HStack(spacing: 16) {
                            luckyItem(icon: "paintpalette", label: reading.luckyColor)
                            luckyItem(icon: "number", label: "\(reading.luckyNumber)")
                            luckyItem(icon: "sparkle", label: reading.luckyCrystal)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .task {
            await loadTodayReading()
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
        let parsed = await generator.generateDailyReading(profile: profile, modelContext: modelContext)

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
