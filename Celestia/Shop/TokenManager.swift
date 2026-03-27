import Foundation
import SwiftData

@MainActor
final class TokenManager: ObservableObject {

    @Published var balance: Int = 0

    private var modelContext: ModelContext?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadBalance()
    }

    // MARK: - Load Balance

    private func loadBalance() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<TokenBalance>(
            sortBy: [SortDescriptor(\.currentTokens)]
        )
        if let existing = try? context.fetch(descriptor).first {
            balance = existing.currentTokens
        } else {
            // Create initial balance (0 tokens)
            let initial = TokenBalance()
            context.insert(initial)
            balance = 0
        }
    }

    // MARK: - Check & Spend

    func canAfford(feature: String) -> Bool {
        guard let cost = ShopCatalog.tokenCost[feature] else { return false }
        return balance >= cost
    }

    func spend(feature: String) -> Bool {
        guard let context = modelContext,
              let cost = ShopCatalog.tokenCost[feature] else { return false }

        let descriptor = FetchDescriptor<TokenBalance>()
        guard let tokenBalance = try? context.fetch(descriptor).first else { return false }

        let success = tokenBalance.spend(cost)
        if success {
            balance = tokenBalance.currentTokens
        }
        return success
    }

    // MARK: - Add Tokens (from purchase)

    func addTokens(productId: String) {
        guard let context = modelContext,
              let amount = ShopCatalog.tokenProducts[productId] else { return }

        let descriptor = FetchDescriptor<TokenBalance>()
        if let tokenBalance = try? context.fetch(descriptor).first {
            tokenBalance.add(amount)
            balance = tokenBalance.currentTokens
        } else {
            let newBalance = TokenBalance()
            newBalance.add(amount)
            context.insert(newBalance)
            balance = newBalance.currentTokens
        }
    }

    // MARK: - Cost Info

    func costFor(feature: String) -> Int {
        ShopCatalog.tokenCost[feature] ?? 0
    }
}
