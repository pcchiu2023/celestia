import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("Today")
                .tabItem { Label("Today", systemImage: "sun.max.fill") }
            Text("Tarot")
                .tabItem { Label("Tarot", systemImage: "sparkles") }
            Text("Chat")
                .tabItem { Label("Chat", systemImage: "bubble.left.fill") }
            Text("Compatibility")
                .tabItem { Label("Match", systemImage: "heart.fill") }
            Text("Profile")
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .tint(CelestiaTheme.gold)
    }
}
