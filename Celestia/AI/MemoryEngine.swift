import Foundation
import SwiftData

enum MemoryEngine {

    /// Build memory context from recent readings for prompt injection
    static func buildContext(modelContext: ModelContext, limit: Int = 5) -> String {
        let descriptor = FetchDescriptor<Reading>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        guard let readings = try? modelContext.fetch(descriptor) else {
            return "No previous readings."
        }

        let recent = readings.prefix(limit)
        guard !recent.isEmpty else { return "This is the user's first reading." }

        var lines = ["MEMORY (recent readings):"]
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        for reading in recent {
            let timeAgo = formatter.localizedString(for: reading.createdAt, relativeTo: Date())
            let preview = String(reading.content.prefix(80))
            lines.append("• \(timeAgo): [\(reading.type)] \(preview)...")
        }

        return lines.joined(separator: "\n")
    }

    /// Build chat history context
    static func buildChatContext(modelContext: ModelContext, limit: Int = 10) -> String {
        let descriptor = FetchDescriptor<ChatMessage>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        guard let messages = try? modelContext.fetch(descriptor) else {
            return ""
        }

        let recent = Array(messages.prefix(limit).reversed())
        guard !recent.isEmpty else { return "" }

        var lines = ["RECENT CONVERSATION:"]
        for msg in recent {
            let role = msg.role == "user" ? "User" : "Caelus"
            lines.append("\(role): \(String(msg.content.prefix(100)))")
        }
        return lines.joined(separator: "\n")
    }
}
