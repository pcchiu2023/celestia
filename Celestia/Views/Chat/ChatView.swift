import SwiftUI
import SwiftData

struct ChatView: View {
    @EnvironmentObject var brain: CelestiaBrain
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.createdAt) private var messages: [ChatMessage]
    @Query private var profiles: [UserProfile]
    @State private var inputText = ""
    @State private var isGenerating = false

    private var profile: UserProfile? { profiles.first }

    // Daily message limit for free users
    private var todayMessageCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return messages.filter { $0.role == "user" && $0.createdAt >= today }.count
    }

    private var canSendMessage: Bool {
        let isSubscribed = profile?.subscriptionTier != "free"
        return isSubscribed || todayMessageCount < 5
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
                    if !canSendMessage {
                        Text("5/5 today")
                            .font(CelestiaTheme.captionFont)
                            .foregroundColor(.red)
                    } else if profile?.subscriptionTier == "free" {
                        Text("\(todayMessageCount)/5 today")
                            .font(CelestiaTheme.captionFont)
                            .foregroundColor(CelestiaTheme.textSecondary)
                    }
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
                                    ProgressView()
                                        .tint(CelestiaTheme.purple)
                                    Text("Reading the stars...")
                                        .font(CelestiaTheme.captionFont)
                                        .foregroundColor(CelestiaTheme.textSecondary)
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
