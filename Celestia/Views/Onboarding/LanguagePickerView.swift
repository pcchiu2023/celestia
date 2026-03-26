import SwiftUI

struct LanguagePickerView: View {
    @Binding var selectedLanguage: AppLanguage
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            CelestiaTheme.darkBg.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                Text("✧")
                    .font(.system(size: 60))

                Text("Choose Your Language")
                    .font(CelestiaTheme.headingFont)
                    .foregroundColor(CelestiaTheme.gold)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Button {
                            selectedLanguage = lang
                        } label: {
                            Text(lang.displayName)
                                .font(CelestiaTheme.bodyFont)
                                .foregroundColor(selectedLanguage == lang ? CelestiaTheme.darkBg : CelestiaTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedLanguage == lang ? CelestiaTheme.gold : Color.white.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                Button {
                    onContinue()
                } label: {
                    Text("Continue")
                        .font(CelestiaTheme.bodyFont.bold())
                        .foregroundColor(CelestiaTheme.darkBg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(CelestiaTheme.gold)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
