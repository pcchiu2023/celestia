import SwiftUI

struct TarotCardView: View {
    let drawnCard: DrawnCardData
    let isRevealed: Bool
    let onTap: () -> Void

    private var card: TarotCard? {
        TarotCard(rawValue: drawnCard.cardId)
    }

    var body: some View {
        ZStack {
            // Back of card
            cardBack
                .opacity(isRevealed ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isRevealed ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )

            // Front of card
            cardFront
                .opacity(isRevealed ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isRevealed ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .frame(width: 150, height: 240)
        .onTapGesture {
            if !isRevealed {
                onTap()
            }
        }
    }

    // MARK: - Card Back

    private var cardBack: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.25, green: 0.1, blue: 0.4),
                            Color(red: 0.1, green: 0.05, blue: 0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    LinearGradient(
                        colors: [CelestiaTheme.gold, CelestiaTheme.gold.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2
                )

            VStack(spacing: 8) {
                Image(systemName: "sparkle")
                    .font(.system(size: 32))
                    .foregroundStyle(CelestiaTheme.gold)

                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(CelestiaTheme.gold.opacity(0.6))

                Image(systemName: "sparkle")
                    .font(.system(size: 32))
                    .foregroundStyle(CelestiaTheme.gold)
            }
        }
        .frame(width: 150, height: 240)
    }

    // MARK: - Card Front

    private var cardFront: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(CelestiaTheme.navy)

            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    drawnCard.isReversed
                        ? Color.red.opacity(0.6)
                        : CelestiaTheme.gold,
                    lineWidth: 2
                )

            VStack(spacing: 6) {
                // Position label
                Text(drawnCard.positionMeaning)
                    .font(CelestiaTheme.captionFont)
                    .foregroundStyle(CelestiaTheme.gold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Divider()
                    .background(CelestiaTheme.gold.opacity(0.3))

                // Card name
                Text(card?.name ?? drawnCard.cardId)
                    .font(.custom("Georgia", size: 14))
                    .fontWeight(.bold)
                    .foregroundStyle(CelestiaTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .rotationEffect(drawnCard.isReversed ? .degrees(180) : .zero)

                if drawnCard.isReversed {
                    Text("REVERSED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.red.opacity(0.8))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(.red.opacity(0.15))
                        )
                }

                Divider()
                    .background(CelestiaTheme.gold.opacity(0.3))

                // Meaning
                Text(meaningText)
                    .font(.system(size: 10))
                    .foregroundStyle(CelestiaTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(5)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 4)

                // Major Arcana badge
                if card?.isMajor == true {
                    Text("Major Arcana")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(CelestiaTheme.purple)
                }
            }
            .padding(10)
        }
        .frame(width: 150, height: 240)
    }

    private var meaningText: String {
        guard let card else { return "" }
        return drawnCard.isReversed ? card.reversedMeaning : card.uprightMeaning
    }
}

#Preview {
    TarotCardView(
        drawnCard: DrawnCardData(
            cardId: "theFool",
            position: 1,
            isReversed: false,
            positionMeaning: "Present"
        ),
        isRevealed: false,
        onTap: {}
    )
    .preferredColorScheme(.dark)
}
