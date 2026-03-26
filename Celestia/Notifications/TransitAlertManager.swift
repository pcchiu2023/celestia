import Foundation
import UserNotifications
import SwiftData

@MainActor
final class TransitAlertManager: ObservableObject {

    static let shared = TransitAlertManager()
    private init() {}

    private let maxAlertsPerDay = 2
    private let quietHoursStart = 22  // 10 PM
    private let quietHoursEnd = 8     // 8 AM

    /// Request notification permission
    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Schedule transit alerts for significant planetary events
    func scheduleAlerts(
        profile: UserProfile,
        brain: CelestiaBrain,
        modelContext: ModelContext
    ) async {
        guard let chart = profile.chartData else { return }

        // Check if subscribed (Star Pass only feature)
        guard profile.subscriptionTier != "free" else { return }

        // Remove pending alerts
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // Get significant transits
        let transits = TransitEngine.shared.significantTransitsToday(natalChart: chart)
        guard !transits.isEmpty else { return }

        // Generate mini-readings for top transits
        let topTransits = Array(transits.prefix(maxAlertsPerDay))

        for (index, transit) in topTransits.enumerated() {
            let description = transit.description
            let lang = profile.appLanguage

            // Generate a short AI interpretation
            let prompt = """
            Write a 1-sentence transit alert for: \(description)
            \(lang.promptInstruction)
            Be specific, mystical, and encouraging. Max 100 characters.
            """

            let miniReading = await brain.generate(
                systemPrompt: "You are Celestia, a mystical astrologer writing brief transit alerts.",
                userPrompt: prompt
            )

            let cleanReading = miniReading
                .replacingOccurrences(of: "```", with: "")
                .replacingOccurrences(of: "\"", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            // Schedule notification outside quiet hours
            let content = UNMutableNotificationContent()
            content.title = "Transit Alert ✨"
            content.body = cleanReading.isEmpty ? description : String(cleanReading.prefix(150))
            content.sound = .default
            content.categoryIdentifier = "TRANSIT_ALERT"

            // Schedule for next non-quiet hour
            var triggerDate = DateComponents()
            let hour = max(quietHoursEnd + index, Calendar.current.component(.hour, from: Date()))

            // If current hour is past quiet start, schedule for tomorrow morning
            if hour >= quietHoursStart {
                triggerDate.hour = quietHoursEnd + index
                triggerDate.minute = 0
                // Tomorrow
                if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                    let comps = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
                    triggerDate.year = comps.year
                    triggerDate.month = comps.month
                    triggerDate.day = comps.day
                }
            } else {
                triggerDate.hour = max(hour, quietHoursEnd)
                triggerDate.minute = index * 30  // Stagger by 30 min
            }

            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(
                identifier: "transit_\(index)_\(Date().timeIntervalSince1970)",
                content: content,
                trigger: trigger
            )

            try? await UNUserNotificationCenter.current().add(request)
        }
    }

    /// Cancel all pending transit alerts
    func cancelAlerts() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
