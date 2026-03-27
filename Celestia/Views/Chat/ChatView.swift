import SwiftUI
import SwiftData

struct ChatView: View {
    @EnvironmentObject var brain: CelestiaBrain
    @EnvironmentObject var stardustManager: StardustManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.createdAt) private var messages: [ChatMessage]
    @Query private var profiles: [UserProfile]
    @State private var inputText = ""
    @State private var isGenerating = false
    @State private var showPaywall = false

    private var profile: UserProfile? { profiles.first }
    private var isSubscriber: Bool { subscriptionManager.isSubscribed }

    // Daily free message count
    private var todayMessageCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return messages.filter { $0.role == "user" && $0.createdAt >= today }.count
    }

    // Free users get 1/day, subscribers get unlimited (0 cost)
    private var canSendFree: Bool {
        isSubscriber || todayMessageCount < 1
    }

    // Can send if free message available OR has stardust
    private var canSendMessage: Bool {
        canSendFree || stardustManager.canAfford(StardustManager.costs["chat"] ?? 1)
    }

    private var messageStatusText: String {
        if isSubscriber { return "Unlimited ✧" }
        if todayMessageCount < 1 { return "1 free today" }
        return "\(stardustManager.balance) ✦ available"
    }

    var body: some View {
        ZStack {
            CelestiaTheme.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("✧ Celestia")
                        .font(CelestiaTheme.subheadingFont)
                        .foregroundColor(CelestiaTheme.gold)
                    Spacer()

                    Text(messageStatusText)
                        .font(CelestiaTheme.captionFont)
                        .foregroundColor(canSendMessage ? CelestiaTheme.textSecondary : .red)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                            if isGenerating {
                                HStack {
                                    CosmicLoadingView(message: "Consulting the cosmos...")
                                        .scaleEffect(0.5)
                                        .frame(height: 80)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                // Input
                HStack(spacing: 12) {
                    TextField("Ask Celestia...", text: $inputText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                        .lineLimit(1...4)

                    Button {
                        Task { await sendMessage() }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(
                                inputText.isEmpty || !canSendMessage
                                ? Color.gray
                                : CelestiaTheme.gold
                            )
                    }
                    .disabled(inputText.isEmpty || !canSendMessage)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(CelestiaTheme.navy)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(trigger: "chat")
        }
    }

    private func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let profile else { return }

        // Content filter
        switch ContentFilter.filter(text) {
        case .blocked(let reason):
            let blocked = ChatMessage(role: "celestia", content: reason)
            modelContext.insert(blocked)
            try? modelContext.save()
            inputText = ""
            return
        case .allowed(let filtered):
            // Charge stardust if not free
            if !canSendFree {
                let cost = StardustManager.costs["chat"] ?? 1
                if !stardustManager.spend(cost) {
                    showPaywall = true
                    return
                }
            }

            inputText = ""

            // Save user message
            let userMsg = ChatMessage(role: "user", content: filtered)
            modelContext.insert(userMsg)
            try? modelContext.save()

            // Generate response
            isGenerating = true
            let generator = ReadingGenerator(brain: brain)
            let response = await generator.generateChatResponse(
                message: filtered, profile: profile, modelContext: modelContext
            )
            isGenerating = false

            let celestiaMsg = ChatMessage(role: "celestia", content: response)
            modelContext.insert(celestiaMsg)
            try? modelContext.save()
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var isUser: Bool { message.role == "user" }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            Text(message.content)
                .font(CelestiaTheme.bodyFont)
                .foregroundColor(isUser ? CelestiaTheme.darkBg : CelestiaTheme.textPrimary)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isUser ? CelestiaTheme.gold : Color.white.opacity(0.1))
                )

            if !isUser { Spacer(minLength: 60) }
        }
    }
}
