import SwiftUI

// MARK: - Match Setup View

struct MatchSetupView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.presentationMode) var presentationMode

    let venue: BoxVenue
    let date: String
    let time: String
    let duration: Double
    let turfName: String
    let totalCost: Double

    // Match Configuration
    @State private var matchMode: MatchMode = .privateMatch
    @State private var totalPlayers: Int = 14
    @State private var skillLevel: SkillLevel = .intermediate
    @State private var ageGroup: AgeGroup = .open
    @State private var matchName: String = ""
    @State private var matchRules: String = ""
    @State private var allowSpectators: Bool = false
    @State private var enableLocationShare: Bool = true
    @State private var paymentWindowHours: Int = 2

    enum MatchMode: String, CaseIterable {
        case privateMatch = "Private"
        case publicMatch  = "Public"
    }

    enum SkillLevel: String, CaseIterable {
        case beginner     = "Beginner"
        case intermediate = "Intermediate"
        case advanced     = "Advanced"
        case allLevels    = "All Levels"
    }

    enum AgeGroup: String, CaseIterable {
        case open    = "Open (All Ages)"
        case under18 = "Under 18"
        case over18  = "18+"
        case over30  = "30+"
    }

    // Computed
    var perPlayerCost: Double { totalCost / Double(totalPlayers) }
    var organizerShare: Double { perPlayerCost }

    var body: some View {
        ZStack(alignment: .bottom) {
            DS.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {



                    // ── Booking Summary Pill ─────────────────────────────
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(turfName)  ·  \(venue.name)")
                                .font(.caption).foregroundColor(DS.textSecondary)
                            Text("\(date)  ·  \(time)")
                                .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                        }
                        Spacer()
                        Text("₹\(String(format: "%.0f", totalCost))")
                            .font(.headline).foregroundColor(.white)
                    }
                    .padding(16)
                    .background(DS.surface)
                    .cornerRadius(16)
                    .padding(.horizontal, DS.s3)
                    .padding(.top, 4)

                    // ── Match Mode ──────────────────────────────────────
                    sectionHeader("HOW DO YOU WANT TO PLAY?")

                    HStack(spacing: 12) {
                        ForEach(MatchMode.allCases, id: \.self) { mode in
                            matchModeCard(mode)
                        }
                    }
                    .padding(.horizontal, DS.s3)

                    // ── Match Name ──────────────────────────────────────
                    sectionHeader("MATCH TITLE (OPTIONAL)")

                    HStack {
                        Image(systemName: "pencil").foregroundColor(DS.textSecondary)
                        TextField("e.g. Sunday Warriors Cricket", text: $matchName)
                            .foregroundColor(.white)
                    }
                    .padding(16)
                    .background(DS.surface)
                    .cornerRadius(16)
                    .padding(.horizontal, DS.s3)

                    // ── Players ──────────────────────────────────────────
                    sectionHeader("PLAYERS")

                    VStack(spacing: 0) {
                        playerCountRow
                        Divider().background(DS.textSecondary.opacity(0.2)).padding(.leading, 16)
                        skillLevelRow
                        if matchMode == .publicMatch {
                            Divider().background(DS.textSecondary.opacity(0.2)).padding(.leading, 16)
                            ageGroupRow
                        }
                    }
                    .background(DS.surface)
                    .cornerRadius(16)
                    .padding(.horizontal, DS.s3)

                    // ── Payment Window (only for split/public) ───────────
                    sectionHeader("PAYMENT WINDOW")

                    VStack(alignment: .leading, spacing: 12) {
                        Text("How long should players have to pay their share after receiving the invite?")
                            .font(.caption).foregroundColor(DS.textSecondary)

                        HStack(spacing: 12) {
                            ForEach([1, 2, 6, 24], id: \.self) { hours in
                                Button { paymentWindowHours = hours } label: {
                                    Text(hours == 24 ? "24 hrs" : "\(hours) hr")
                                        .font(.caption).fontWeight(.bold)
                                        .foregroundColor(paymentWindowHours == hours ? .black : .white)
                                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                                        .background(paymentWindowHours == hours ? Color.white : Color.white.opacity(0.08))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(DS.surface)
                    .cornerRadius(16)
                    .padding(.horizontal, DS.s3)

                    // ── Match Rules ─────────────────────────────────────
                    if matchMode == .publicMatch {
                        sectionHeader("MATCH RULES (OPTIONAL)")

                        ZStack(alignment: .topLeading) {
                            if matchRules.isEmpty {
                                Text("e.g. No aggressive play. Bring your own gear.")
                                    .foregroundColor(DS.textSecondary)
                                    .font(.subheadline)
                                    .padding(16)
                            }
                            TextEditor(text: $matchRules)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .frame(minHeight: 80)
                                .padding(12)
                        }
                        .background(DS.surface)
                        .cornerRadius(16)
                        .padding(.horizontal, DS.s3)
                    }

                    // ── Extras ──────────────────────────────────────────
                    sectionHeader("EXTRAS")

                    VStack(spacing: 0) {
                        toggleRow(
                            icon: "location.fill",
                            title: "Location Sharing",
                            subtitle: "Players can share live location before match",
                            isOn: $enableLocationShare
                        )
                        Divider().background(DS.textSecondary.opacity(0.2)).padding(.leading, 56)
                        toggleRow(
                            icon: "eye",
                            title: "Allow Spectators",
                            subtitle: "Others can watch your public match",
                            isOn: $allowSpectators
                        )
                    }
                    .background(DS.surface)
                    .cornerRadius(16)
                    .padding(.horizontal, DS.s3)

                    // ── Organizer Guarantee Banner ────────────────────────
                    HStack(spacing: 14) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.title2)
                            .foregroundColor(Color(red: 100/255, green: 220/255, blue: 120/255))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Organizer Guarantee")
                                .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                            Text("You pay ₹\(String(format: "%.0f", totalCost)) now to lock the turf. As each player pays, ₹\(String(format: "%.0f", perPlayerCost)) is credited back to your wallet.")
                                .font(.caption).foregroundColor(DS.textSecondary).lineSpacing(2)
                        }
                    }
                    .padding(16)
                    .background(Color(red: 100/255, green: 220/255, blue: 120/255).opacity(0.08))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 100/255, green: 220/255, blue: 120/255).opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, DS.s3)
                    .padding(.top, 8)

                    Color.clear.frame(height: 120)
                }
            }

            // ── Bottom Bar ─────────────────────────────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your cost: ₹\(String(format: "%.0f", organizerShare))")
                        .font(.caption).foregroundColor(DS.textSecondary)
                    Text("Pay ₹\(String(format: "%.0f", totalCost + 49)) to confirm")
                        .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                }

                Spacer()

                Button(action: {
                    router.push(.reviewBooking(
                        venue: venue,
                        date: date,
                        time: time,
                        duration: duration,
                        matchType: matchMode.rawValue,
                        totalPlayers: totalPlayers,
                        totalCost: totalCost,
                        skillLevel: skillLevel.rawValue,
                        paymentWindow: paymentWindowHours
                    ))
                }) {
                    Text("Review Booking")
                        .font(.subheadline).fontWeight(.bold).foregroundColor(.black)
                        .padding(.horizontal, 20).padding(.vertical, 14)
                        .background(Color.white).cornerRadius(24)
                }
            }
            .padding(.horizontal, 20).padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .cornerRadius(36)
            .overlay(RoundedRectangle(cornerRadius: 36).stroke(Color.white.opacity(0.12), lineWidth: 1))
            .padding(.horizontal, DS.s3)
            .padding(.bottom, 16)
        }
        .navigationTitle("Set Up Match")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: Sub-views


    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.caption).fontWeight(.bold)
            .foregroundColor(DS.textSecondary)
            .padding(.horizontal, DS.s3)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }

    private func matchModeCard(_ mode: MatchMode) -> some View {
        let isSelected = matchMode == mode
        let icon = mode == .privateMatch ? "lock.fill" : "globe"
        let subtitle = mode == .privateMatch
            ? "Invite friends via link"
            : "Anyone nearby can join"

        return Button { withAnimation(.spring()) { matchMode = mode } } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? Color(red: 100/255, green: 220/255, blue: 120/255) : DS.textSecondary)
                    Spacer()
                    Circle()
                        .fill(isSelected ? Color(red: 100/255, green: 220/255, blue: 120/255) : Color.clear)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(isSelected
                            ? Color.clear
                            : DS.textSecondary, lineWidth: 1.5))
                }
                Text(mode.rawValue)
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                Text(subtitle)
                    .font(.caption).foregroundColor(DS.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.white.opacity(0.06) : DS.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(red: 100/255, green: 220/255, blue: 120/255) : Color.clear, lineWidth: 1.5)
            )
        }
    }

    private var playerCountRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Players")
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                Text("₹\(String(format: "%.0f", perPlayerCost)) / player")
                    .font(.caption)
                    .foregroundColor(Color(red: 100/255, green: 220/255, blue: 120/255))
            }
            Spacer()
            HStack(spacing: 14) {
                Button { if totalPlayers > 2 { totalPlayers -= 1 } } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3).foregroundColor(DS.textSecondary)
                }
                Text("\(totalPlayers)")
                    .font(.title3).fontWeight(.bold).foregroundColor(.white)
                    .frame(width: 28, alignment: .center)
                Button { if totalPlayers < 30 { totalPlayers += 1 } } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3).foregroundColor(.white)
                }
            }
        }
        .padding(16)
    }

    private var skillLevelRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Skill Level")
                .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SkillLevel.allCases, id: \.self) { level in
                        Button { skillLevel = level } label: {
                            Text(level.rawValue)
                                .font(.caption).fontWeight(.semibold)
                                .foregroundColor(skillLevel == level ? .black : .white)
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(skillLevel == level ? Color.white : Color.white.opacity(0.08))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .padding(16)
    }

    private var ageGroupRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Age Group")
                .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AgeGroup.allCases, id: \.self) { group in
                        Button { ageGroup = group } label: {
                            Text(group.rawValue)
                                .font(.caption).fontWeight(.semibold)
                                .foregroundColor(ageGroup == group ? .black : .white)
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(ageGroup == group ? Color.white : Color.white.opacity(0.08))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .padding(16)
    }

    private func toggleRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(DS.textSecondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                Text(subtitle).font(.caption).foregroundColor(DS.textSecondary)
            }

            Spacer()
            Toggle("", isOn: isOn).labelsHidden().tint(Color(red: 100/255, green: 220/255, blue: 120/255))
        }
        .padding(16)
    }
}
