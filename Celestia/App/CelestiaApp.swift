import SwiftUI
import SwiftData
import UserNotifications

@main
struct CelestiaApp: App {
    let modelContainer: ModelContainer
    @StateObject private var brain = CelestiaBrain()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        do {
            modelContainer = try ModelContainer(
                for: UserProfile.self,
                Reading.self,
                TarotReading.self,
                Contact.self,
                ChatMessage.self,
                TokenBalance.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(brain)
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhase(newPhase)
        }
    }

    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background:
            // Schedule transit alerts when app goes to background
            Task { @MainActor in
                let context = modelContainer.mainContext
                let descriptor = FetchDescriptor<UserProfile>(
                    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
                )
                if let profile = try? context.fetch(descriptor).first {
                    await TransitAlertManager.shared.scheduleAlerts(
                        profile: profile,
                        brain: brain,
                        modelContext: context
                    )
                }
            }
        case .active:
            // Clear badge when app becomes active
            UNUserNotificationCenter.current().setBadgeCount(0)
        default:
            break
        }
    }
}
