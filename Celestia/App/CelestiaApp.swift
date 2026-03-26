import SwiftUI
import SwiftData

@main
struct CelestiaApp: App {
    let modelContainer: ModelContainer

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
        }
        .modelContainer(modelContainer)
    }
}
