import SwiftUI
import CoreLocation

struct BirthDataView: View {
    @Binding var name: String
    @Binding var birthDate: Date
    @Binding var birthTime: Date
    @Binding var birthCity: String
    @Binding var birthLatitude: Double
    @Binding var birthLongitude: Double
    let onComplete: () -> Void
    var language: AppLanguage = .en

    @State private var citySearchText = ""
    @State private var searchResults: [CLPlacemark] = []
    @State private var isSearching = false

    private let geocoder = CLGeocoder()

    private var l: L10n { L10n(lang: language) }

    var body: some View {
        ZStack {
            CelestiaTheme.darkBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text(l.tellMeAboutYou)
                        .font(CelestiaTheme.headingFont)
                        .foregroundColor(CelestiaTheme.gold)
                        .padding(.top, 40)

                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text(l.yourName)
                            .font(CelestiaTheme.captionFont)
                            .foregroundColor(CelestiaTheme.textSecondary)
                        TextField("", text: $name)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }

                    // Birth Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text(l.birthDate)
                            .font(CelestiaTheme.captionFont)
                            .foregroundColor(CelestiaTheme.textSecondary)
                        DatePicker("", selection: $birthDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .colorScheme(.dark)
                    }

                    // Birth Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text(l.birthTime)
                            .font(CelestiaTheme.captionFont)
                            .foregroundColor(CelestiaTheme.textSecondary)
                        DatePicker("", selection: $birthTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .colorScheme(.dark)
                    }

                    // Birth City
                    VStack(alignment: .leading, spacing: 8) {
                        Text(l.birthCity)
                            .font(CelestiaTheme.captionFont)
                            .foregroundColor(CelestiaTheme.textSecondary)
                        TextField(l.searchCity, text: $citySearchText)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .onChange(of: citySearchText) { _, newValue in
                                searchCity(newValue)
                            }

                        if !searchResults.isEmpty {
                            ForEach(searchResults, id: \.self) { placemark in
                                Button {
                                    selectCity(placemark)
                                } label: {
                                    HStack {
                                        Text(formatPlacemark(placemark))
                                            .foregroundColor(CelestiaTheme.textPrimary)
                                        Spacer()
                                    }
                                    .padding(8)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(6)
                                }
                            }
                        }

                        if !birthCity.isEmpty {
                            Text("\(l.selected) \(birthCity)")
                                .font(CelestiaTheme.captionFont)
                                .foregroundColor(CelestiaTheme.gold)
                        }
                    }

                    Spacer(minLength: 40)

                    Button {
                        onComplete()
                    } label: {
                        Text(l.revealChart)
                            .font(CelestiaTheme.bodyFont.bold())
                            .foregroundColor(CelestiaTheme.darkBg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canProceed ? CelestiaTheme.gold : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!canProceed)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var canProceed: Bool {
        !name.isEmpty && !birthCity.isEmpty
    }

    private func searchCity(_ query: String) {
        guard query.count >= 2 else {
            searchResults = []
            return
        }
        isSearching = true
        geocoder.geocodeAddressString(query) { placemarks, _ in
            isSearching = false
            searchResults = Array((placemarks ?? []).prefix(5))
        }
    }

    private func selectCity(_ placemark: CLPlacemark) {
        birthCity = formatPlacemark(placemark)
        birthLatitude = placemark.location?.coordinate.latitude ?? 0
        birthLongitude = placemark.location?.coordinate.longitude ?? 0
        searchResults = []
        citySearchText = birthCity
    }

    private func formatPlacemark(_ placemark: CLPlacemark) -> String {
        [placemark.locality, placemark.administrativeArea, placemark.country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
