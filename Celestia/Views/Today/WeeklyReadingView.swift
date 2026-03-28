import SwiftUI
import SwiftData

struct WeeklyReadingView: View {
    @EnvironmentObject var brain: CelestiaBrain
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserProfile.createdAt, order: .reverse) private var profiles: [UserProfile]

    @State private var sections: [(title: String, icon: String, content: String)] = []
    @State private var isGenerating = false
    @State private var currentSection = ""
    @State private var savedToJournal = false

    private var profile: UserProfile? { profiles.first }
    private var l: L10n { L10n(lang: profile?.appLanguage ?? .en) }

    private var sectionDefs: [(title: String, icon: String)] {[
        (l.loveRelationships, "heart.fill"),
        (l.careerFinances, "briefcase.fill"),
        (l.healthWellness, "leaf.fill"),
        (l.spiritualGrowth, "sparkles"),
        (l.weekAhead, "eye.fill")
    ]}

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                if sections.isEmpty && !isGenerating {
                    startButton
                } else {
                    progressSection
                    sectionsDisplay
                }

                if sections.count == sectionDefs.count && !isGenerating {
                    saveButton
                }
            }
            .padding()
        }
        .background(CelestiaTheme.darkBg.ignoresSafeArea())
        .navigationTitle(l.weeklyReading)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 36))
                .foregroundStyle(CelestiaTheme.gold)

            Text(l.weeklyDeepReading)
                .font(CelestiaTheme.headingFont)
                .foregroundStyle(CelestiaTheme.textPrimary)

            Text(l.weeklySubtitle)
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.textSecondary)
        }
        .padding(.top, 8)
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            Task { await generateAllSections() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                Text(l.generateWeekly)
                    .fontWeight(.semibold)
            }
            .font(CelestiaTheme.bodyFont)
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
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: 8) {
            if isGenerating {
                HStack(spacing: 12) {
                    ProgressView()
                        .tint(CelestiaTheme.gold)
                    Text("\(l.channeling) \(currentSection)...")
                        .font(CelestiaTheme.captionFont)
                        .foregroundStyle(CelestiaTheme.textSecondary)
                }
            }

            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<sectionDefs.count, id: \.self) { i in
                    Circle()
                        .fill(i < sections.count ? CelestiaTheme.gold : Color.white.opacity(0.15))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }

    // MARK: - Sections

    private var sectionsDisplay: some View {
        VStack(spacing: 16) {
            ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: section.icon)
                            .foregroundStyle(CelestiaTheme.gold)
                        Text(section.title)
                            .font(CelestiaTheme.subheadingFont)
                            .foregroundStyle(CelestiaTheme.textPrimary)
                    }

                    Text(section.content)
                        .font(CelestiaTheme.bodyFont)
                        .foregroundStyle(CelestiaTheme.textPrimary)
                        .lineSpacing(4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(CelestiaTheme.purple.opacity(0.15), lineWidth: 1)
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: sections.count)
    }

    // MARK: - Save

    private var saveButton: some View {
        Group {
            if savedToJournal {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(l.savedToJournal)
                        .font(CelestiaTheme.captionFont)
                        .foregroundStyle(CelestiaTheme.textSecondary)
                }
            } else {
                Button {
                    saveReading()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bookmark")
                        Text(l.saveToJournal)
                    }
                    .font(CelestiaTheme.captionFont)
                    .foregroundStyle(CelestiaTheme.gold)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule().strokeBorder(CelestiaTheme.gold.opacity(0.4), lineWidth: 1)
                    )
                }
            }
        }
        .padding(.bottom, 20)
    }

    // MARK: - Generation

    private func generateAllSections() async {
        guard let profile else { return }
        isGenerating = true
        let generator = ReadingGenerator(brain: brain)

        for def in sectionDefs {
            currentSection = def.title
            let content = await generator.generateWeeklyReading(
                section: def.title,
                profile: profile,
                modelContext: modelContext
            )

            let section = (title: def.title, icon: def.icon, content: content)
            sections.append(section)
        }

        isGenerating = false
    }

    private func saveReading() {
        let fullContent = sections.map { "**\($0.title)**\n\($0.content)" }.joined(separator: "\n\n")
        let reading = Reading(
            type: .weekly,
            content: fullContent,
            language: profile?.appLanguage ?? .en
        )
        modelContext.insert(reading)
        savedToJournal = true
    }
}
