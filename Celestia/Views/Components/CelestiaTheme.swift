import SwiftUI

enum CelestiaTheme {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let purple = Color(red: 0.608, green: 0.447, blue: 0.812)
    static let navy = Color(red: 0.05, green: 0.05, blue: 0.15)
    static let darkBg = Color(red: 0.02, green: 0.02, blue: 0.08)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)

    static let headingFont = Font.custom("Georgia", size: 24)
    static let subheadingFont = Font.custom("Georgia", size: 18)
    static let bodyFont = Font.system(size: 16)
    static let captionFont = Font.system(size: 13, design: .rounded)
}
