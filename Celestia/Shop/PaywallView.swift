import SwiftUI
import StoreKit

struct PaywallView: View {
    let trigger: String
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var stardustManager: StardustManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    private var triggerMessage: String {
        switch trigger {
        case "chat": return "Chat messages cost 1 ✦ each"
        case "weekly_deep": return "Weekly deep readings cost 3 ✦"
        case "tarot_celtic": return "Celtic Cross spreads cost 10 ✦"
        case "tarot_3card": return "Three card spreads cost 5 ✦"
        case "tarot_single": return "Single card readings cost 2 ✦"
        case "compatibility": return "Compatibility readings cost 5 ✦"
        case "daily_detailed": return "Detailed readings are for Star Pass subscribers"
        default: return "Unlock the full power of the stars"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [CelestiaTheme.darkBg, CelestiaTheme.navy, CelestiaTheme.purple.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        headerSection
                        featuresSection
                        subscriptionSection
                        stardustSection
                        termsSection
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(CelestiaTheme.textSecondary)
                    }
                }
            }
            .alert("Purchase Error", isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkle")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [CelestiaTheme.gold, CelestiaTheme.gold.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text("Stardust & Star Pass")
                .font(.custom("Georgia", size: 28))
                .foregroundStyle(CelestiaTheme.gold)

            Text(triggerMessage)
                .font(CelestiaTheme.bodyFont)
                .foregroundStyle(CelestiaTheme.textSecondary)
                .multilineTextAlignment(.center)

            // Current balance
            HStack(spacing: 6) {
                Image(systemName: "sparkle")
                    .foregroundStyle(CelestiaTheme.gold)
                    .font(.system(size: 14))
                Text("You have \(stardustManager.balance) ✦")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(CelestiaTheme.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.white.opacity(0.08)))
        }
        .padding(.top, 20)
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STAR PASS INCLUDES")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(CelestiaTheme.gold)

            featureRow("80 ✦ Stardust every month", icon: "sparkle")
            featureRow("Unlimited chat messages", icon: "bubble.left.fill")
            featureRow("Detailed daily horoscope", icon: "sun.max.fill")
            featureRow("Priority reading generation", icon: "bolt.fill")
            featureRow("Exclusive chart themes", icon: "paintpalette.fill")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }

    private func featureRow(_ text: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(CelestiaTheme.gold)
                .frame(width: 24)
            Text(text)
                .font(CelestiaTheme.bodyFont)
                .foregroundStyle(CelestiaTheme.textPrimary)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
                .font(.caption)
        }
    }

    // MARK: - Subscriptions

    private var subscriptionSection: some View {
        VStack(spacing: 12) {
            ForEach(subscriptionManager.products, id: \.id) { product in
                subscriptionTile(product)
            }
        }
    }

    private func subscriptionTile(_ product: Product) -> some View {
        let isSelected = selectedProduct?.id == product.id
        let isAnnual = product.id == ShopCatalog.starPassAnnual

        return Button {
            selectedProduct = product
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(product.displayName)
                            .font(CelestiaTheme.bodyFont)
                            .fontWeight(.medium)
                            .foregroundStyle(CelestiaTheme.textPrimary)

                        if isAnnual {
                            Text("SAVE 44%")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(CelestiaTheme.navy)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(CelestiaTheme.gold))
                        }
                    }

                    Text(product.description)
                        .font(CelestiaTheme.captionFont)
                        .foregroundStyle(CelestiaTheme.textSecondary)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(CelestiaTheme.bodyFont)
                    .fontWeight(.semibold)
                    .foregroundStyle(CelestiaTheme.gold)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? CelestiaTheme.purple.opacity(0.15) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isSelected ? CelestiaTheme.gold : (isAnnual ? CelestiaTheme.gold.opacity(0.3) : Color.clear),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
    }

    // MARK: - Stardust Packs

    private var stardustSection: some View {
        VStack(spacing: 12) {
            Text("Or buy Stardust")
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.textSecondary)

            HStack(spacing: 10) {
                ForEach(subscriptionManager.stardustProducts, id: \.id) { product in
                    Button {
                        Task { await purchaseStardust(product) }
                    } label: {
                        VStack(spacing: 6) {
                            let count = ShopCatalog.stardustProducts[product.id] ?? 0
                            Text("\(count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(CelestiaTheme.gold)
                            Text("✦")
                                .font(CelestiaTheme.captionFont)
                                .foregroundStyle(CelestiaTheme.textSecondary)
                            Text(product.displayPrice)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(CelestiaTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(CelestiaTheme.purple.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Terms

    private var termsSection: some View {
        VStack(spacing: 4) {
            // Subscribe button
            Button {
                Task { await purchaseSelected() }
            } label: {
                HStack(spacing: 8) {
                    if isPurchasing {
                        ProgressView().tint(CelestiaTheme.navy)
                    } else {
                        Image(systemName: "sparkle")
                        Text("Subscribe")
                            .fontWeight(.bold)
                    }
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
            .disabled(selectedProduct == nil || isPurchasing)
            .opacity(selectedProduct == nil ? 0.5 : 1.0)

            Text("Subscriptions auto-renew. Cancel anytime in Settings.")
                .font(.system(size: 11))
                .foregroundStyle(CelestiaTheme.textSecondary.opacity(0.6))
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button("Terms of Use") {}
                    .font(.system(size: 11))
                    .foregroundStyle(CelestiaTheme.textSecondary.opacity(0.6))
                Button("Privacy Policy") {}
                    .font(.system(size: 11))
                    .foregroundStyle(CelestiaTheme.textSecondary.opacity(0.6))
                Button("Restore Purchases") {
                    Task { await subscriptionManager.checkSubscriptionStatus() }
                }
                .font(.system(size: 11))
                .foregroundStyle(CelestiaTheme.gold.opacity(0.6))
            }
        }
        .padding(.bottom, 20)
    }

    // MARK: - Purchase Actions

    private func purchaseSelected() async {
        guard let product = selectedProduct else { return }
        isPurchasing = true
        do {
            if let _ = try await subscriptionManager.purchase(product) {
                dismiss()
            }
        } catch {
            errorMessage = "Purchase failed. Please try again."
        }
        isPurchasing = false
    }

    private func purchaseStardust(_ product: Product) async {
        do {
            if let _ = try await subscriptionManager.purchase(product) {
                if let amount = ShopCatalog.stardustProducts[product.id] {
                    stardustManager.addPurchased(amount)
                }
            }
        } catch {
            errorMessage = "Purchase failed. Please try again."
        }
    }
}
