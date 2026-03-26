import SwiftUI
import SwiftData

struct CompatReportView: View {
    let contact: Contact
    @EnvironmentObject var brain: CelestiaBrain
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserProfile.createdAt, order: .reverse) private var profiles: [UserProfile]

    @State private var reading: ParsedReading?
    @State private var isLoading = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                chartComparison

                if isLoading {
                    loadingSection
                } else if let reading {
                    readingSection(reading)
                }
            }
            .padding()
        }
        .background(CelestiaTheme.darkBg.ignoresSafeArea())
        .navigationTitle("Compatibility")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await generateReading()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(CelestiaTheme.gold)
                    Text(profile?.name ?? "You")
                        .font(CelestiaTheme.bodyFont)
                        .foregroundStyle(CelestiaTheme.textPrimary)
                }

                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundStyle(CelestiaTheme.purple)

                VStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundStyle(CelestiaTheme.gold)
                    Text(contact.name)
                        .font(CelestiaTheme.bodyFont)
                        .foregroundStyle(CelestiaTheme.textPrimary)
                }
            }

            Text(contact.relationship.capitalized)
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.textSecondary)
        }
        .padding(.top, 8)
    }

    // MARK: - Chart Comparison

    private var chartComparison: some View {
        VStack(spacing: 12) {
            Text("Sun · Moon · Rising")
                .font(CelestiaTheme.subheadingFont)
                .foregroundStyle(CelestiaTheme.gold)

            if let userChart = profile?.chartData, let contactChart = contact.chartData {
                HStack {
                    VStack(spacing: 8) {
                        signRow("Sun", sign: userChart.sunSign)
                        signRow("Moon", sign: userChart.moonSign)
                        signRow("Rising", sign: userChart.ascendantSign)
                    }

                    Spacer()

                    VStack(spacing: 8) {
                        signRow("Sun", sign: contactChart.sunSign)
                        signRow("Moon", sign: contactChart.moonSign)
                        signRow("Rising", sign: contactChart.ascendantSign)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
            } else {
                Text("Full chart comparison requires birth time and city for both people")
                    .font(CelestiaTheme.captionFont)
                    .foregroundStyle(CelestiaTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }

    private func signRow(_ label: String, sign: ZodiacSign) -> some View {
        HStack(spacing: 6) {
            Text(sign.symbol)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(CelestiaTheme.captionFont)
                    .foregroundStyle(CelestiaTheme.textSecondary)
                Text(sign.rawValue.capitalized)
                    .font(CelestiaTheme.bodyFont)
                    .foregroundStyle(CelestiaTheme.textPrimary)
            }
        }
    }

    // MARK: - Loading

    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(CelestiaTheme.gold)
            Text("Reading your stars together...")
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.textSecondary)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Reading Display

    private func readingSection(_ reading: ParsedReading) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Celestia's Reading")
                .font(CelestiaTheme.subheadingFont)
                .foregroundStyle(CelestiaTheme.gold)

            Text(reading.reading)
                .font(CelestiaTheme.bodyFont)
                .foregroundStyle(CelestiaTheme.textPrimary)
                .lineSpacing(4)

            if !reading.keyTheme.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "sparkle")
                        .foregroundStyle(CelestiaTheme.gold)
                    Text(reading.keyTheme)
                        .font(CelestiaTheme.bodyFont)
                        .fontWeight(.medium)
                        .foregroundStyle(CelestiaTheme.textPrimary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(CelestiaTheme.purple.opacity(0.1))
                )
            }

            if !reading.actionAdvice.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Advice")
                        .font(CelestiaTheme.captionFont)
                        .foregroundStyle(CelestiaTheme.textSecondary)
                    Text(reading.actionAdvice)
                        .font(CelestiaTheme.bodyFont)
                        .foregroundStyle(CelestiaTheme.textPrimary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(CelestiaTheme.purple.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Generate

    private func generateReading() async {
        guard let profile, contact.chartData != nil else { return }
        isLoading = true
        let generator = ReadingGenerator(brain: brain)
        reading = await generator.generateCompatibilityReading(
            profile: profile,
            contact: contact,
            modelContext: modelContext
        )
        isLoading = false
    }
}
