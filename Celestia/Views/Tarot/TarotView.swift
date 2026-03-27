import SwiftUI
import SwiftData

struct TarotView: View {
    @EnvironmentObject var brain: CelestiaBrain
    @EnvironmentObject var stardustManager: StardustManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserProfile.createdAt, order: .reverse) private var profiles: [UserProfile]
    @Query(sort: \TarotReading.createdAt, order: .reverse) private var pastReadings: [TarotReading]

    @State private var selectedSpread: SpreadType = .threeCard
    @State private var drawnCards: [DrawnCardData] = []
    @State private var revealedIndices: Set<Int> = []
    @State private var hasDrawn = false
    @State private var interpretation: String = ""
    @State private var isInterpreting = false
    @State private var question: String = ""
    @State private var showPaywall = false

    private var profile: UserProfile? { profiles.first }

    private var readingGenerator: ReadingGenerator {
        ReadingGenerator(brain: brain)
    }

    private var allCardsRevealed: Bool {
        hasDrawn && revealedIndices.count >= drawnCards.count
    }

    // MARK: - Stardust Cost

    private var stardustCost: Int {
        switch selectedSpread {
        case .single: return StardustManager.costs["tarot_single"] ?? 2
        case .threeCard: return StardustManager.costs["tarot_3card"] ?? 5
        case .celticCross: return StardustManager.costs["tarot_celtic"] ?? 10
        }
    }

    private var canAfford: Bool {
        stardustManager.canAfford(stardustCost)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                spreadPicker
                stardustCostBanner
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
        .sheet(isPresented: $showPaywall) {
            PaywallView(trigger: "tarot_\(selectedSpread.rawValue)")
        }
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
        }
        .padding(.top, 8)
    }

    // MARK: - Spread Picker

    private var spreadPicker: some View {
        VStack(spacing: 12) {
            ForEach(SpreadType.allCases, id: \.rawValue) { spread in
                Button {
                    if !hasDrawn { selectedSpread = spread }
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
                                selectedSpread == spread ? CelestiaTheme.gold.opacity(0.5) : Color.clear,
                                lineWidth: 1
                            )
                    )
                }
                .disabled(hasDrawn)
            }
        }
    }

    private func costLabel(for spread: SpreadType) -> some View {
        let cost: Int = {
            switch spread {
            case .single: return StardustManager.costs["tarot_single"] ?? 2
            case .threeCard: return StardustManager.costs["tarot_3card"] ?? 5
            case .celticCross: return StardustManager.costs["tarot_celtic"] ?? 10
            }
        }()
        return Text("\(cost) \u{2726}")
            .font(CelestiaTheme.captionFont)
            .foregroundStyle(CelestiaTheme.gold)
    }

    // MARK: - Stardust Cost Banner

    private var stardustCostBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkle")
                .font(.system(size: 11))
                .foregroundStyle(CelestiaTheme.gold)
            Text("This reading costs \(stardustCost) ✦")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(CelestiaTheme.textSecondary)
            Spacer()
            Text("\(stardustManager.balance) ✦ available")
                .font(.system(size: 12))
                .foregroundStyle(canAfford ? CelestiaTheme.gold : .red)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
        )
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
                        Text(canAfford ? "Draw Cards (\(stardustCost) ✦)" : "Not Enough Stardust")
                            .fontWeight(.semibold)
                    }
                    .font(CelestiaTheme.bodyFont)
                    .foregroundStyle(canAfford ? CelestiaTheme.navy : CelestiaTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                canAfford
                                    ? LinearGradient(colors: [CelestiaTheme.gold, CelestiaTheme.gold.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
                            )
                    )
                }
                .disabled(!canAfford)
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
                        Capsule().strokeBorder(CelestiaTheme.textSecondary.opacity(0.3), lineWidth: 1)
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
                        onTap: { revealCard(at: index) }
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
                CosmicLoadingView(message: "The stars are aligning their wisdom...")
            } else if !interpretation.isEmpty {
                ReadingRevealView {
                    Text(interpretation)
                        .font(CelestiaTheme.bodyFont)
                        .foregroundStyle(CelestiaTheme.textPrimary)
                        .lineSpacing(4)
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

    // MARK: - Actions

    private func performDraw() {
        // Spend stardust
        if !stardustManager.spend(stardustCost) {
            showPaywall = true
            return
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
