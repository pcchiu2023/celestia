import SwiftUI
import CoreLocation
import SwiftData

struct AddContactView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var birthDate = Date()
    @State private var birthTime = Date()
    @State private var includeBirthTime = false
    @State private var birthCity = ""
    @State private var birthLatitude: Double = 0
    @State private var birthLongitude: Double = 0
    @State private var relationship = "friend"
    @State private var citySearchText = ""
    @State private var searchResults: [CLPlacemark] = []
    @State private var isSearching = false

    private let geocoder = CLGeocoder()
    private let relationships = ["partner", "friend", "family", "crush"]

    var body: some View {
        NavigationStack {
            ZStack {
                CelestiaTheme.darkBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(CelestiaTheme.captionFont)
                                .foregroundStyle(CelestiaTheme.textSecondary)
                            TextField("Their name", text: $name)
                                .textFieldStyle(.plain)
                                .font(CelestiaTheme.bodyFont)
                                .foregroundStyle(CelestiaTheme.textPrimary)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                        }

                        // Relationship
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Relationship")
                                .font(CelestiaTheme.captionFont)
                                .foregroundStyle(CelestiaTheme.textSecondary)
                            HStack(spacing: 8) {
                                ForEach(relationships, id: \.self) { rel in
                                    Button {
                                        relationship = rel
                                    } label: {
                                        Text(rel.capitalized)
                                            .font(CelestiaTheme.captionFont)
                                            .foregroundStyle(relationship == rel ? CelestiaTheme.navy : CelestiaTheme.textPrimary)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule().fill(relationship == rel ? CelestiaTheme.gold : Color.white.opacity(0.05))
                                            )
                                    }
                                }
                            }
                        }

                        // Birth Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Birth Date")
                                .font(CelestiaTheme.captionFont)
                                .foregroundStyle(CelestiaTheme.textSecondary)
                            DatePicker("", selection: $birthDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .tint(CelestiaTheme.gold)
                        }

                        // Optional Birth Time
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $includeBirthTime) {
                                Text("Include Birth Time")
                                    .font(CelestiaTheme.captionFont)
                                    .foregroundStyle(CelestiaTheme.textSecondary)
                            }
                            .tint(CelestiaTheme.gold)

                            if includeBirthTime {
                                DatePicker("", selection: $birthTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                                    .tint(CelestiaTheme.gold)
                            }
                        }

                        // Optional Birth City
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Birth City (optional)")
                                .font(CelestiaTheme.captionFont)
                                .foregroundStyle(CelestiaTheme.textSecondary)

                            TextField("Search city...", text: $citySearchText)
                                .textFieldStyle(.plain)
                                .font(CelestiaTheme.bodyFont)
                                .foregroundStyle(CelestiaTheme.textPrimary)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                                .onChange(of: citySearchText) { _, newValue in
                                    searchCity(newValue)
                                }

                            if !searchResults.isEmpty {
                                VStack(spacing: 0) {
                                    ForEach(searchResults, id: \.self) { place in
                                        Button {
                                            selectCity(place)
                                        } label: {
                                            Text(place.locality ?? place.name ?? "Unknown")
                                                .font(CelestiaTheme.bodyFont)
                                                .foregroundStyle(CelestiaTheme.textPrimary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.vertical, 10)
                                                .padding(.horizontal)
                                        }
                                        Divider().background(Color.white.opacity(0.1))
                                    }
                                }
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.08)))
                            }

                            if !birthCity.isEmpty {
                                Text("Selected: \(birthCity)")
                                    .font(CelestiaTheme.captionFont)
                                    .foregroundStyle(CelestiaTheme.gold)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(CelestiaTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveContact() }
                        .foregroundStyle(CelestiaTheme.gold)
                        .disabled(name.isEmpty)
                }
            }
        }
    }

    private func searchCity(_ query: String) {
        guard query.count >= 2 else {
            searchResults = []
            return
        }
        isSearching = true
        geocoder.cancelGeocode()
        geocoder.geocodeAddressString(query) { places, _ in
            isSearching = false
            searchResults = (places ?? []).prefix(5).map { $0 }
        }
    }

    private func selectCity(_ place: CLPlacemark) {
        birthCity = place.locality ?? place.name ?? ""
        birthLatitude = place.location?.coordinate.latitude ?? 0
        birthLongitude = place.location?.coordinate.longitude ?? 0
        citySearchText = birthCity
        searchResults = []
    }

    private func saveContact() {
        let contact = Contact(
            name: name,
            birthDate: birthDate,
            birthTime: includeBirthTime ? birthTime : nil,
            birthCity: birthCity.isEmpty ? nil : birthCity,
            birthLatitude: birthCity.isEmpty ? nil : birthLatitude,
            birthLongitude: birthCity.isEmpty ? nil : birthLongitude,
            relationship: relationship
        )

        // Calculate chart if we have time and location
        if includeBirthTime && !birthCity.isEmpty {
            // Merge date + time
            let calendar = Calendar.current
            let dateComps = calendar.dateComponents([.year, .month, .day], from: birthDate)
            let timeComps = calendar.dateComponents([.hour, .minute], from: birthTime)
            var merged = DateComponents()
            merged.year = dateComps.year
            merged.month = dateComps.month
            merged.day = dateComps.day
            merged.hour = timeComps.hour
            merged.minute = timeComps.minute
            if let fullDate = calendar.date(from: merged) {
                let chart = ChartEngine.shared.calculateBirthChart(
                    date: fullDate,
                    latitude: birthLatitude,
                    longitude: birthLongitude
                )
                contact.chartData = chart
            }
        }

        modelContext.insert(contact)
        dismiss()
    }
}
