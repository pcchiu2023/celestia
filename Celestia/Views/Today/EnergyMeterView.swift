import SwiftUI

struct EnergyMeterView: View {
    let label: String
    let value: Double  // 0.0 - 1.0
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(CelestiaTheme.captionFont)
                    .foregroundColor(CelestiaTheme.textSecondary)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(CelestiaTheme.captionFont)
                    .foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * value)
                }
            }
            .frame(height: 8)
        }
    }
}
