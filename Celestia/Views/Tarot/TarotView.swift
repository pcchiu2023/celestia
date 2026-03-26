import SwiftUI
import SwiftData

struct TarotView: View {
    @EnvironmentObject var brain: CelestiaBrain
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserProfile.createdAt, order: .reverse) private var profiles: [UserProfile]
    @Query(sort: \TarotReading.createdAt, order: .reverse) private var pastReadings: [TarotReading]
    @Query private var tokenBalances: [TokenBalance]

    @State private var selectedSpread: SpreadType = .threeCard
    @State private var drawnCards: [DrawnCardData] = []
    @State private var revealedIndices: Set<Int> = []
    @State private var hasDrawn = false
    @State private var interpretation: String = ""
    @State private var isInterpreting = false
    @State private var question: String = ""
    @State private var showPaywall = false

    private var profile: UserProfile? { profiles.first }

    private var tokenBalance: TokenBalance? { tokenBalances.first }

    private var readingGenerator: ReadingGenerator {
        ReadingGenerator(brain: brain)
    }

    private var allCardsRevealed: Bool {
        hasDrawn && revealedIndices.count >= drawnCards.count
    }

    // MARK: - Free Tier Logic

    /// Check if the user has used their free weekly reading
    private var freeReadingUsedThisWeek: Bool {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else {
            return false
        }
        return pastReadings.contains { $0.createdAt >= weekStart }
    }

    /// Whether the selected spread requires tokens (not free, or free limit exhausted)
    private var requiresTokens: Bool {
        if selectedSpread.tokenCost == 0 {
            // Single card is free once per day; but we gate weekly for free tier
            return freeReadingUsedThisWeek
        }
        return true
    }

    /// The effective token cost considering free tier
    private var effectiveTokenCost: Int {
        if !freeReadingUsedThisWeek && selectedSpread == .single {
            return 0
        }
        // If free reading used, single card costs 1 token
        if selectedSpread == .single {
            return 1
        }
        return selectedSpread.tokenCost
    }

    /// Whether the user can afford the current spread
    private var canAfford: Bool {
        let cost = effectiveTokenCost
        if cost == 0 { return true }
        guard let balance = tokenBalance else { return false }
        return balance.currentTokens >= cost
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                spreadPicker

                if requiresTokens {
                    tokenCostBanner
                }

                questionField
                drawButton

                if hasDrawn {
                    cardsSection
                }
                if allCardsRevealed {
                    interpretationSection
                }
            }
            .padding()
        }
        .background(CelestiaTheme.darkBg.ignoresSafeArea())
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundStyle(CelestiaTheme.gold)

            Text("Tarot Reading")
                .font(CelestiaTheme.headingFont)
                .foregroundStyle(CelestiaTheme.textPrimary)

            Text("Let the cards reveal what the stars whisper")
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.textSecondary)

            if !freeReadingUsedThisWeek {
                Text("1 free reading this week")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.green.opacity(0.12))
                    )
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Spread Picker

    private var spreadPicker: some View {
        VStack(spacing: 12) {
            ForEach(SpreadType.allCases, id: \.rawValue) { spread in
                Button {
                    if !hasDrawn {
                        selectedSpread = spread
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(spread.displayName)
                                .font(CelestiaTheme.bodyFont)
                                .fontWeight(.medium)
                                .foregroundStyle(CelestiaTheme.textPrimary)

                            Text("\(spread.cardCount) card\(spread.cardCount == 1 ? "" : "s")")
                                .font(CelestiaTheme.captionFont)
                                .foregroundStyle(CelestiaTheme.textSecondary)
                        }

                        Spacer()

                        costLabel(for: spread)

                        Image(systemName: selectedSpread == spread ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedSpread == spread ? CelestiaTheme.gold : CelestiaTheme.textSecondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedSpread == spread
                                  ? CelestiaTheme.purple.opacity(0.15)
                                  : Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                selectedSpread == spread
                                    ? CelestiaTheme.gold.opacity(0.5)
                                    : Color.clear,
                                lineWidth: 1
                            )
                    )
                }
                .disabled(hasDrawn)
            }
        }
    }

    @ViewBuilder
    private func costLabel(for spread: SpreadType) -> some View {
        if spread == .single && !freeReadingUsedThisWeek {
            Text("Free")
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(.green)
        } else if spread == .single && freeReadingUsedThisWeek {
            Text("1 token")
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.gold)
        } else {
            Text("\(spread.tokenCost) tokens")
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.gold)
        }
    }

    // MARK: - Token Cost Banner

    private var tokenCostBanner: some View {
        VStack(spacing: 8) {
            if !canAfford {
                HStack(spacing: 8) {
                    Image(systemName: "star.circle")
                        .foregroundStyle(CelestiaTheme.gold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("You've used your free weekly reading")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(CelestiaTheme.textPrimary)
                        Text("Get Star Pass for unlimited readings, or use \(effectiveTokenCost) token\(effectiveTokenCost == 1 ? "" : "s")")
                            .font(.system(size: 12))
                            .foregroundStyle(CelestiaTheme.textSecondary)
                    }
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(CelestiaTheme.gold.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(CelestiaTheme.gold.opacity(0.25), lineWidth: 1)
                )
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 11))
                        .foregroundStyle(CelestiaTheme.gold)
                    Text("This reading costs \(effectiveTokenCost) token\(effectiveTokenCost == 1 ? "" : "s")")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(CelestiaTheme.textSecondary)
                    Spacer()
                    Text("\(tokenBalance?.currentTokens ?? 0) available")
                        .font(.system(size: 12))
                        .foregroundStyle(CelestiaTheme.gold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.03))
                )
            }
        }
    }

    // MARK: - Question Field

    private var questionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Question (optional)")
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.textSecondary)

            TextField("What weighs on your mind?", text: $question)
                .textFieldStyle(.plain)
                .font(CelestiaTheme.bodyFont)
                .foregroundStyle(CelestiaTheme.textPrimary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(CelestiaTheme.purple.opacity(0.3), lineWidth: 1)
                )
                .disabled(hasDrawn)
        }
    }

    // MARK: - Draw Button

    private var drawButton: some View {
        Group {
            if !hasDrawn {
                Button {
                    performDraw()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                        Text(requiresTokens && !canAfford ? "Not Enough Tokens" : "Draw Cards")
                            .fontWeight(.semibold)
                    }
                    .font(CelestiaTheme.bodyFont)
                    .foregroundStyle(requiresTokens && !canAfford ? CelestiaTheme.textSecondary : CelestiaTheme.navy)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                requiresTokens && !canAfford
                                    ? LinearGradient(
                                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        colors: [CelestiaTheme.gold, CelestiaTheme.gold.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                            )
                    )
                }
                .disabled(requiresTokens && !canAfford)
            } else if !allCardsRevealed {
                Text("Tap each card to reveal")
                    .font(CelestiaTheme.captionFont)
                    .foregroundStyle(CelestiaTheme.gold)
                    .transition(.opacity)
            } else {
                Button {
                    resetReading()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("New Reading")
                    }
                    .font(CelestiaTheme.captionFont)
                    .foregroundStyle(CelestiaTheme.textSecondary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .strokeBorder(CelestiaTheme.textSecondary.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
    }

    // MARK: - Cards Section

    private var cardsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(drawnCards.enumerated()), id: \.element.cardId) { index, card in
                    let isNextToReveal = index == revealedIndices.count
                    TarotCardView(
                        drawnCard: card,
                        isRevealed: revealedIndices.contains(index),
                        onTap: {
                            revealCard(at: index)
                        }
                    )
                    .opacity(isNextToReveal || revealedIndices.contains(index) ? 1.0 : 0.5)
                    .allowsHitTesting(isNextToReveal)
                    .animation(.easeInOut(duration: 0.6), value: revealedIndices)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Interpretation Section

    private var interpretationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.book.closed")
                    .foregroundStyle(CelestiaTheme.gold)
                Text("Celestia's Interpretation")
                    .font(CelestiaTheme.subheadingFont)
                    .foregroundStyle(CelestiaTheme.textPrimary)
            }

            if isInterpreting {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(CelestiaTheme.gold)
                        .scaleEffect(1.2)
                    Text("The stars are aligning their wisdom...")
                        .font(CelestiaTheme.captionFont)
                        .foregroundStyle(CelestiaTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 32)
            } else if !interpretation.isEmpty {
                Text(interpretation)
                    .font(CelestiaTheme.bodyFont)
                    .foregroundStyle(CelestiaTheme.textPrimary)
                    .lineSpacing(4)
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

    // MARK: - Actions

    private func performDraw() {
        // Spend tokens if required
        let cost = effectiveTokenCost
        if cost > 0 {
            guard let balance = tokenBalance, balance.spend(cost) else { return }
        }

        let cards = TarotDrawEngine.drawCards(spread: selectedSpread)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            drawnCards = cards
            hasDrawn = true
            revealedIndices = []
        }
    }

    private func revealCard(at index: Int) {
        withAnimation(.easeInOut(duration: 0.6)) {
            revealedIndices.insert(index)
        }

        // Check if all cards are now revealed — trigger interpretation
        if revealedIndices.count >= drawnCards.count {
            generateInterpretation()
        }
    }

    private func generateInterpretation() {
        guard let profile else { return }
        isInterpreting = true

        Task {
            let result = await readingGenerator.generateTarotReading(
                cards: drawnCards,
                question: question.isEmpty ? nil : question,
                profile: profile,
                modelContext: modelContext
            )

            interpretation = result

            // Save completed reading to SwiftData
            let reading = TarotReading(
                spreadType: selectedSpread.rawValue,
                cards: drawnCards,
                question: question.isEmpty ? nil : question,
                interpretation: result
            )
            modelContext.insert(reading)

            isInterpreting = false
        }
    }

    private func resetReading() {
        withAnimation {
            drawnCards = []
            hasDrawn = false
            interpretation = ""
            revealedIndices = []
            question = ""
        }
    }
}

#Preview {
    TarotView()
        .environmentObject(CelestiaBrain())
        .preferredColorScheme(.dark)
}
