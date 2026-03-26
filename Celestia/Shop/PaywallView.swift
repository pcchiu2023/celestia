import SwiftUI
import StoreKit

struct PaywallView: View {
    let trigger: String  // e.g. "weekly_deep", "tarot_celtic", "compatibility"
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    private var triggerMessage: String {
        switch trigger {
        case "weekly_deep": return "Weekly Deep Readings require Star Pass"
        case "tarot_celtic": return "Celtic Cross spreads require Star Pass or tokens"
        case "tarot_3card": return "Extra tarot readings require Star Pass or tokens"
        case "compatibility": return "Compatibility readings require Star Pass or tokens"
        case "transit_alerts": return "Transit alerts require Star Pass"
        default: return "Unlock the full power of the stars"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
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
                        tokenSection
                        termsSection
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
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
            Image(systemName: "star.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [CelestiaTheme.gold, CelestiaTheme.gold.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text("Star Pass")
                .font(.custom("Georgia", size: 32))
                .foregroundStyle(CelestiaTheme.gold)

            Text(triggerMessage)
                .font(CelestiaTheme.bodyFont)
                .foregroundStyle(CelestiaTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow("Unlimited daily readings", icon: "sun.max.fill")
            featureRow("Weekly deep forecasts", icon: "calendar")
            featureRow("Unlimited tarot spreads", icon: "sparkles")
            featureRow("Compatibility readings", icon: "heart.fill")
            featureRow("Transit alert notifications", icon: "bell.fill")
            featureRow("Reading journal history", icon: "book.fill")
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
        let isPopular = product.id == ShopCatalog.starPassYearly

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

                        if isPopular {
                            Text("BEST VALUE")
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
                        isSelected ? CelestiaTheme.gold : (isPopular ? CelestiaTheme.gold.opacity(0.3) : Color.clear),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            Task { await purchaseSelected() }
        } label: {
            HStack(spacing: 8) {
                if isPurchasing {
                    ProgressView()
                        .tint(CelestiaTheme.navy)
                } else {
                    Image(systemName: "star.fill")
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
    }

    // MARK: - Token Section

    private var tokenSection: some View {
        VStack(spacing: 12) {
            Text("Or pay per reading")
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.textSecondary)

            HStack(spacing: 12) {
                ForEach(subscriptionManager.tokenProducts, id: \.id) { product in
                    Button {
                        Task { await purchaseToken(product) }
                    } label: {
                        VStack(spacing: 6) {
                            let count = ShopCatalog.tokenProducts[product.id] ?? 0
                            Text("\(count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(CelestiaTheme.gold)
                            Text("tokens")
                                .font(CelestiaTheme.captionFont)
                                .foregroundStyle(CelestiaTheme.textSecondary)
                            Text(product.displayPrice)
                                .font(CelestiaTheme.bodyFont)
                                .fontWeight(.medium)
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
            purchaseButton

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

    private func purchaseToken(_ product: Product) async {
        do {
            if let _ = try await subscriptionManager.purchase(product) {
                // Token delivery handled by transaction listener
            }
        } catch {
            errorMessage = "Purchase failed. Please try again."
        }
    }
}
