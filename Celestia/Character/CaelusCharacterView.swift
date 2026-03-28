import SwiftUI

/// Displays the Caelus character with mood-reactive image and smooth transitions.
struct CaelusCharacterView: View {
    let mood: CaelusMood
    var size: CGFloat = 200
    var showShadow: Bool = true

    @State private var currentImageName: String = ""

    var body: some View {
        Group {
            if let uiImage = CaelusImageCache.shared.image(for: currentImageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                // Placeholder while assets are missing (development)
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(CelestiaTheme.purple.opacity(0.3))
            }
        }
        .frame(height: size)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(CelestiaTheme.gold.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: CelestiaTheme.purple.opacity(showShadow ? 0.2 : 0), radius: 12, y: 4)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .animation(.easeInOut(duration: 0.4), value: currentImageName)
        .id(currentImageName)
        .onAppear { currentImageName = mood.randomImageName() }
        .onChange(of: mood) { _, newMood in
            withAnimation(.easeInOut(duration: 0.4)) {
                currentImageName = newMood.randomImageName()
            }
        }
    }
}

// MARK: - Previews

#Preview("Welcoming") {
    CaelusCharacterView(mood: .welcoming)
        .padding()
        .background(CelestiaTheme.darkBg)
}

#Preview("Mystical") {
    CaelusCharacterView(mood: .mystical, size: 160)
        .padding()
        .background(CelestiaTheme.darkBg)
}
