import SwiftUI
import SwiftData

struct ReferralView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var stardustManager: StardustManager
    @Query(sort: \ReferralEvent.createdAt, order: .reverse) private var referrals: [ReferralEvent]
    @State private var showCopied = false

    private var profile: UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try? modelContext.fetch(descriptor).first
    }

    private var referralLink: String {
        guard let code = profile?.referralCode else { return "" }
        return "https://celestia.app/refer/\(code)"
    }

    private var referralsThisMonth: Int {
        ReferralEvent.referralsThisMonth(in: modelContext)
    }

    private var l: L10n { L10n(lang: profile?.appLanguage ?? .en) }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                rewardCard
                shareSection
                if !referrals.isEmpty {
                    historySection
                }
            }
            .padding()
        }
        .background(CelestiaTheme.darkBg)
        .navigationTitle(l.shareStars)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(CelestiaTheme.gold)

            Text(l.inviteFriends)
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(l.referralReward)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Reward Card

    private var rewardCard: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("\(referralsThisMonth)")
                    .font(.title.bold())
                    .foregroundStyle(CelestiaTheme.gold)
                Text(l.thisMonth)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Divider()
                .frame(height: 40)
                .background(.white.opacity(0.2))

            VStack(spacing: 4) {
                Text("\(ReferralEvent.monthlyCapacity - referralsThisMonth)")
                    .font(.title.bold())
                    .foregroundStyle(CelestiaTheme.purple)
                Text(l.remaining)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Divider()
                .frame(height: 40)
                .background(.white.opacity(0.2))

            VStack(spacing: 4) {
                Text("\(referrals.count * ReferralEvent.rewardPerReferral) ✦")
                    .font(.title.bold())
                    .foregroundStyle(.yellow)
                Text(l.totalEarned)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(CelestiaTheme.cardBg)
        .cornerRadius(16)
    }

    // MARK: - Share

    private var shareSection: some View {
        VStack(spacing: 12) {
            if let code = profile?.referralCode {
                // Referral code display
                HStack {
                    Text(code)
                        .font(.title3.monospaced().bold())
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        UIPasteboard.general.string = referralLink
                        showCopied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCopied = false
                        }
                    } label: {
                        Label(showCopied ? l.copied : l.copy, systemImage: showCopied ? "checkmark" : "doc.on.doc")
                            .font(.subheadline.bold())
                            .foregroundStyle(CelestiaTheme.gold)
                    }
                }
                .padding()
                .background(CelestiaTheme.cardBg)
                .cornerRadius(12)
            }

            // Share button
            ShareLink(
                item: referralLink,
                subject: Text("Celestia — AI Astrology"),
                message: Text("Check out Celestia! Get your personalized AI astrology readings. Use my referral link to get 15 free Stardust ✦")
            ) {
                Label(l.shareInviteLink, systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [CelestiaTheme.purple, CelestiaTheme.gold.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
            }
        }
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(l.referralHistory)
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(referrals, id: \.id) { event in
                HStack {
                    Image(systemName: "person.badge.plus")
                        .foregroundStyle(CelestiaTheme.gold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(l.friendJoined)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Text(event.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                    Text("+\(event.rewardAmount) ✦")
                        .font(.subheadline.bold())
                        .foregroundStyle(.yellow)
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(CelestiaTheme.cardBg)
        .cornerRadius(16)
    }
}
