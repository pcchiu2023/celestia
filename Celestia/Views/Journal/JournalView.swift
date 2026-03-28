import SwiftUI
import SwiftData

struct JournalView: View {
    @Query(sort: \Reading.createdAt, order: .reverse) private var readings: [Reading]

    @Query(sort: \UserProfile.createdAt, order: .reverse) private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }
    private var l: L10n { L10n(lang: profile?.appLanguage ?? .en) }

    @State private var expandedId: UUID?

    var body: some View {
        NavigationStack {
            ZStack {
                CelestiaTheme.darkBg.ignoresSafeArea()

                if readings.isEmpty {
                    emptyState
                } else {
                    journalList
                }
            }
            .navigationTitle(l.journal)
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundStyle(CelestiaTheme.purple.opacity(0.5))

            Text(l.journalAwaits)
                .font(CelestiaTheme.subheadingFont)
                .foregroundStyle(CelestiaTheme.textPrimary)

            Text(l.journalEmpty)
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Journal List

    private var journalList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(groupedByDate, id: \.key) { date, dayReadings in
                    Section {
                        ForEach(dayReadings) { reading in
                            readingCard(reading)
                        }
                    } header: {
                        Text(formatDate(date))
                            .font(CelestiaTheme.captionFont)
                            .foregroundStyle(CelestiaTheme.gold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Reading Card

    private func readingCard(_ reading: Reading) -> some View {
        let isExpanded = expandedId == reading.id

        return Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                expandedId = isExpanded ? nil : reading.id
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header row
                HStack(spacing: 10) {
                    Image(systemName: iconForType(reading.type))
                        .font(.title3)
                        .foregroundStyle(CelestiaTheme.gold)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(labelForType(reading.type))
                            .font(CelestiaTheme.bodyFont)
                            .fontWeight(.medium)
                            .foregroundStyle(CelestiaTheme.textPrimary)

                        Text(formatTime(reading.createdAt))
                            .font(CelestiaTheme.captionFont)
                            .foregroundStyle(CelestiaTheme.textSecondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(CelestiaTheme.textSecondary)
                }

                // Preview or full content
                if isExpanded {
                    // Energy meters
                    VStack(spacing: 6) {
                        miniMeter(l.love, value: reading.energyLove, color: .pink)
                        miniMeter(l.career, value: reading.energyCareer, color: CelestiaTheme.gold)
                        miniMeter(l.health, value: reading.energyHealth, color: .green)
                        miniMeter(l.spiritual, value: reading.energySpiritual, color: CelestiaTheme.purple)
                    }
                    .padding(.vertical, 4)

                    // Full content
                    Text(reading.content)
                        .font(CelestiaTheme.bodyFont)
                        .foregroundStyle(CelestiaTheme.textPrimary)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Key theme & advice
                    if !reading.keyTheme.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkle")
                                .foregroundStyle(CelestiaTheme.gold)
                            Text(reading.keyTheme)
                                .font(CelestiaTheme.captionFont)
                                .fontWeight(.medium)
                                .foregroundStyle(CelestiaTheme.textPrimary)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(CelestiaTheme.purple.opacity(0.1))
                        )
                    }

                    if !reading.actionAdvice.isEmpty {
                        Text(reading.actionAdvice)
                            .font(CelestiaTheme.captionFont)
                            .foregroundStyle(CelestiaTheme.textSecondary)
                            .italic()
                    }
                } else {
                    // Preview text (first 80 chars)
                    Text(String(reading.content.prefix(80)) + (reading.content.count > 80 ? "..." : ""))
                        .font(CelestiaTheme.captionFont)
                        .foregroundStyle(CelestiaTheme.textSecondary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isExpanded ? CelestiaTheme.purple.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Mini Energy Meter

    private func miniMeter(_ label: String, value: Double, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(CelestiaTheme.textSecondary)
                .frame(width: 55, alignment: .trailing)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.08))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.7))
                        .frame(width: geo.size.width * CGFloat(value))
                }
            }
            .frame(height: 6)

            Text("\(Int(value * 100))%")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(CelestiaTheme.textSecondary)
                .frame(width: 35, alignment: .leading)
        }
    }

    // MARK: - Helpers

    private var groupedByDate: [(key: Date, value: [Reading])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: readings) { reading in
            calendar.startOfDay(for: reading.createdAt)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    private func iconForType(_ type: String) -> String {
        switch type {
        case "daily": return "sun.max.fill"
        case "weekly": return "calendar"
        case "compatibility": return "heart.fill"
        case "tarot": return "sparkles"
        case "chat": return "bubble.left.fill"
        default: return "star.fill"
        }
    }

    private func labelForType(_ type: String) -> String {
        switch type {
        case "daily": return l.dailyHoroscope
        case "weekly": return l.weeklyReading
        case "compatibility": return l.compatibility
        case "tarot": return l.tarotReading
        case "chat": return l.tabChat
        default: return l.reading
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
