import SwiftUI

enum CelestiaTheme {

    // MARK: - Colors

    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let goldLight = Color(red: 1.0, green: 0.91, blue: 0.45)
    static let purple = Color(red: 0.608, green: 0.447, blue: 0.812)
    static let purpleDeep = Color(red: 0.35, green: 0.2, blue: 0.55)
    static let navy = Color(red: 0.05, green: 0.05, blue: 0.15)
    static let darkBg = Color(red: 0.02, green: 0.02, blue: 0.08)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let cardBg = Color.white.opacity(0.05)

    // MARK: - Gradients

    static let goldGradient = LinearGradient(
        colors: [gold, goldLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cosmicGradient = LinearGradient(
        colors: [purpleDeep, navy, darkBg],
        startPoint: .top,
        endPoint: .bottom
    )

    static let goldPurpleGradient = LinearGradient(
        colors: [gold, purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Scalable Fonts

    static let headingFont = Font.custom("Georgia", size: 24)
    static let subheadingFont = Font.custom("Georgia", size: 18)
    static let bodyFont = Font.system(size: 16)
    static let captionFont = Font.system(size: 13, design: .rounded)

    static func heading(_ size: CGFloat) -> Font {
        .custom("Georgia", size: size)
    }

    static func body(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular)
    }

    static func caption(_ size: CGFloat) -> Font {
        .system(size: size, design: .rounded)
    }

    // MARK: - Layout Constants

    static let cardCorner: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
    static let contentPadding: CGFloat = 20
}
