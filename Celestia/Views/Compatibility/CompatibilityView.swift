import SwiftUI
import SwiftData

struct CompatibilityView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var brain: CelestiaBrain
    @Query(sort: \Contact.createdAt, order: .reverse) private var contacts: [Contact]

    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                CelestiaTheme.darkBg.ignoresSafeArea()

                if contacts.isEmpty {
                    emptyState
                } else {
                    contactList
                }
            }
            .navigationTitle("Compatibility")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(CelestiaTheme.gold)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddContactView()
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle")
                .font(.system(size: 60))
                .foregroundStyle(CelestiaTheme.purple.opacity(0.5))

            Text("No Connections Yet")
                .font(CelestiaTheme.subheadingFont)
                .foregroundStyle(CelestiaTheme.textPrimary)

            Text("Add someone to discover your cosmic compatibility")
                .font(CelestiaTheme.captionFont)
                .foregroundStyle(CelestiaTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                showAddSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add Contact")
                }
                .font(CelestiaTheme.bodyFont)
                .foregroundStyle(CelestiaTheme.navy)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule().fill(CelestiaTheme.gold)
                )
            }
        }
        .padding()
    }

    // MARK: - Contact List

    private var contactList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(contacts) { contact in
                    NavigationLink {
                        CompatReportView(contact: contact)
                            .environmentObject(brain)
                    } label: {
                        contactRow(contact)
                    }
                }
            }
            .padding()
        }
    }

    private func contactRow(_ contact: Contact) -> some View {
        HStack(spacing: 14) {
            // Relationship icon
            ZStack {
                Circle()
                    .fill(CelestiaTheme.purple.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: iconForRelationship(contact.relationship))
                    .foregroundStyle(CelestiaTheme.gold)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(CelestiaTheme.bodyFont)
                    .fontWeight(.medium)
                    .foregroundStyle(CelestiaTheme.textPrimary)

                HStack(spacing: 6) {
                    Text(contact.relationship.capitalized)
                        .font(CelestiaTheme.captionFont)
                        .foregroundStyle(CelestiaTheme.textSecondary)

                    if contact.chartData != nil {
                        let sign = ZodiacSign.from(longitude: sunLongitude(from: contact))
                        Text("· \(sign.symbol) \(sign.rawValue.capitalized)")
                            .font(CelestiaTheme.captionFont)
                            .foregroundStyle(CelestiaTheme.purple)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(CelestiaTheme.textSecondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
        )
        .contextMenu {
            Button(role: .destructive) {
                modelContext.delete(contact)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func iconForRelationship(_ rel: String) -> String {
        switch rel {
        case "partner": return "heart.fill"
        case "crush": return "heart"
        case "family": return "house.fill"
        default: return "person.fill"
        }
    }

    private func sunLongitude(from contact: Contact) -> Double {
        contact.chartData?.planets.first(where: { $0.body == .sun })?.longitude ?? 0
    }
}
