import Foundation
import StoreKit
import SwiftData

@MainActor
final class SubscriptionManager: ObservableObject {

    @Published var isSubscribed = false
    @Published var currentTier: String = "free"  // "free", "weekly", "monthly", "yearly"
    @Published var products: [Product] = []
    @Published var tokenProducts: [Product] = []

    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
        Task { await checkSubscriptionStatus() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let allIds = ShopCatalog.subscriptionIds.union([
                ShopCatalog.tokenSmall, ShopCatalog.tokenLarge
            ])
            let storeProducts = try await Product.products(for: allIds)

            products = storeProducts
                .filter { ShopCatalog.subscriptionIds.contains($0.id) }
                .sorted { $0.price < $1.price }

            tokenProducts = storeProducts
                .filter { ShopCatalog.tokenProducts.keys.contains($0.id) }
                .sorted { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await checkSubscriptionStatus()
            return transaction
        case .userCancelled:
            return nil
        case .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    // MARK: - Check Subscription

    func checkSubscriptionStatus() async {
        var foundSubscription = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if ShopCatalog.subscriptionIds.contains(transaction.productID) {
                if transaction.revocationDate == nil {
                    foundSubscription = true
                    currentTier = tierFromProductId(transaction.productID)
                }
            }
        }

        if !foundSubscription {
            isSubscribed = false
            currentTier = "free"
        } else {
            isSubscribed = true
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await transaction.finish()
                await self?.checkSubscriptionStatus()
            }
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    private func tierFromProductId(_ productId: String) -> String {
        switch productId {
        case ShopCatalog.starPassWeekly: return "weekly"
        case ShopCatalog.starPassMonthly: return "monthly"
        case ShopCatalog.starPassYearly: return "yearly"
        default: return "free"
        }
    }

    enum StoreError: Error {
        case verificationFailed
    }
}
