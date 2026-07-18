import SwiftUI

// MARK: - Player Model

struct MatchPlayer: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let color: Color
    var status: PlayerStatus
}

enum PlayerStatus {
    case confirmed, pendingPayment, invited, empty

    var label: String {
        switch self {
        case .confirmed:       return "Paid · Confirmed"
        case .pendingPayment:  return "Payment Pending"
        case .invited:         return "Invited"
        case .empty:           return "Open Slot"
        }
    }

    var color: Color {
        switch self {
        case .confirmed:      return Color(red: 100/255, green: 220/255, blue: 120/255)
        case .pendingPayment: return Color(red: 255/255, green: 170/255, blue: 60/255)
        case .invited:        return Color(red: 120/255, green: 180/255, blue: 255/255)
        case .empty:          return Color.white.opacity(0.3)
        }
    }
}

// MARK: - Match Room View

struct MatchRoomView: View {
    @Environment(\.presentationMode) var presentationMode

    let venue: BoxVenue
    let date: String
    let time: String
    let matchType: String
    let totalPlayers: Int
    let perPlayerCost: Double
    let totalCost: Double
    let skillLevel: String

    // Tabs
    @State private var activeTab = "Room"
    @State private var showInviteSheet = false
    @State private var chatText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(sender: "System", text: "🎉 Match Room created! Invite players to get started.", isSystem: true)
    ]

    // Mock Roster
    @State var roster: [MatchPlayer] = [
        MatchPlayer(name: "You (Organizer)", initials: "YO", color: .blue, status: .confirmed),
        MatchPlayer(name: "Rahul M.", initials: "RM", color: .purple, status: .pendingPayment),
        MatchPlayer(name: "Aarav K.", initials: "AK", color: .orange, status: .invited),
    ]

    var confirmedCount: Int { roster.filter { $0.status == .confirmed }.count }
    var pendingCount: Int { roster.filter { $0.status == .pendingPayment }.count }
    var openSlots: Int { totalPlayers - roster.count }
    var collectedAmount: Double { Double(confirmedCount) * perPlayerCost }
    var fillPercent: Double { Double(confirmedCount) / Double(totalPlayers) }

    var tabs = ["Room", "Roster", "Chat", "Teams"]

    var body: some View {
        ZStack(alignment: .bottom) {
            DS.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Live Activity Banner ──────────────────────────────────
                liveActivityBanner

                // ── Tab Bar ───────────────────────────────────────────────
                tabBar

                // ── Tab Content ───────────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    switch activeTab {
                    case "Room":   roomTab
                    case "Roster": rosterTab
                    case "Chat":   chatTab
                    case "Teams":  teamsTab
                    default:       EmptyView()
                    }
                }
            }

            // ── Chat Input (only on Chat tab) ─────────────────────────────
            if activeTab == "Chat" {
                chatInputBar
            }
        }
        .navigationTitle("Match Room")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text("Match Room")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(venue.name)
                        .font(.caption2)
                        .foregroundColor(DS.textSecondary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showInviteSheet = true }) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showInviteSheet) { InvitePlayersSheet(matchType: matchType) }
    }


    // MARK: Live Activity Banner (Dynamic Island simulation)

    private var liveActivityBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color(red: 100/255, green: 220/255, blue: 120/255).opacity(0.2)).frame(width: 40, height: 40)
                Text("🏏").font(.title3)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(confirmedCount)/\(totalPlayers) Players Confirmed")
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                Text("\(date)  ·  \(time)  ·  \(matchType)")
                    .font(.caption).foregroundColor(DS.textSecondary)
            }

            Spacer()

            // Mini progress ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 4)
                    .frame(width: 36, height: 36)
                Circle()
                    .trim(from: 0, to: fillPercent)
                    .stroke(Color(red: 100/255, green: 220/255, blue: 120/255), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(fillPercent * 100))%")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(14)
        .background(DS.surface)
        .cornerRadius(18)
        .padding(.horizontal, DS.s3)
        .padding(.bottom, 12)
    }

    // MARK: Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button { withAnimation { activeTab = tab } } label: {
                    VStack(spacing: 4) {
                        Text(tab)
                            .font(.caption).fontWeight(activeTab == tab ? .bold : .regular)
                            .foregroundColor(activeTab == tab ? .white : DS.textSecondary)
                        Rectangle()
                            .fill(activeTab == tab ? Color.white : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
            }
        }
        .padding(.horizontal, DS.s3)
        .background(DS.background)
        .overlay(Divider().background(DS.surface).offset(y: 20), alignment: .bottom)
    }

    // MARK: Room Tab

    private var roomTab: some View {
        VStack(alignment: .leading, spacing: 24) {

            // Cost Recovery Dashboard
            VStack(spacing: 16) {
                HStack {
                    Text("Recovery Tracker")
                        .font(.headline).foregroundColor(.white)
                    Spacer()
                    Text("₹\(String(format: "%.0f", collectedAmount)) / ₹\(String(format: "%.0f", totalCost))")
                        .font(.caption).fontWeight(.bold)
                        .foregroundColor(Color(red: 100/255, green: 220/255, blue: 120/255))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08)).frame(height: 10)
                        Capsule()
                            .fill(Color(red: 100/255, green: 220/255, blue: 120/255))
                            .frame(width: max(0, geo.size.width * fillPercent), height: 10)
                    }
                }
                .frame(height: 10)

                HStack {
                    statPill("\(confirmedCount)", "Confirmed", color: Color(red: 100/255, green: 220/255, blue: 120/255))
                    statPill("\(pendingCount)", "Pending", color: Color(red: 255/255, green: 170/255, blue: 60/255))
                    statPill("\(openSlots)", "Open Slots", color: DS.textSecondary)
                }
            }
            .padding(16)
            .background(DS.surface)
            .cornerRadius(18)

            // Quick Actions
            VStack(alignment: .leading, spacing: 12) {
                Text("QUICK ACTIONS")
                    .font(.caption).fontWeight(.bold).foregroundColor(DS.textSecondary)

                HStack(spacing: 12) {
                    actionButton(icon: "square.and.arrow.up", label: "Share Link") {
                        showInviteSheet = true
                    }
                    actionButton(icon: "bell.fill", label: "Nudge Pending") {}
                    actionButton(icon: "person.2.fill", label: "Find Players") {}
                    actionButton(icon: "qrcode", label: "Entry QR") {}
                }
            }

            // Announcements
            VStack(alignment: .leading, spacing: 12) {
                Text("ANNOUNCEMENTS")
                    .font(.caption).fontWeight(.bold).foregroundColor(DS.textSecondary)

                HStack(spacing: 12) {
                    Image(systemName: "megaphone.fill")
                        .foregroundColor(Color(red: 120/255, green: 180/255, blue: 255/255))
                    Text("Match confirmed! Gather at the entrance 15 mins early. Bring your own gloves.")
                        .font(.caption).foregroundColor(.white).lineSpacing(2)
                }
                .padding(14)
                .background(Color(red: 120/255, green: 180/255, blue: 255/255).opacity(0.1))
                .cornerRadius(14)
            }

            // Match Details
            VStack(alignment: .leading, spacing: 12) {
                Text("MATCH DETAILS")
                    .font(.caption).fontWeight(.bold).foregroundColor(DS.textSecondary)

                VStack(spacing: 0) {
                    detailRow(icon: "mappin.circle.fill", label: "Venue", value: venue.name)
                    Divider().background(DS.textSecondary.opacity(0.2)).padding(.leading, 44)
                    detailRow(icon: "calendar", label: "Date & Time", value: "\(date)  ·  \(time)")
                    Divider().background(DS.textSecondary.opacity(0.2)).padding(.leading, 44)
                    detailRow(icon: "person.2", label: "Players", value: "\(totalPlayers) total  ·  \(matchType)")
                    Divider().background(DS.textSecondary.opacity(0.2)).padding(.leading, 44)
                    detailRow(icon: "star", label: "Skill Level", value: skillLevel)
                    Divider().background(DS.textSecondary.opacity(0.2)).padding(.leading, 44)
                    detailRow(icon: "indianrupeesign.circle", label: "Per Player", value: "₹\(String(format: "%.0f", perPlayerCost))")
                }
                .background(DS.surface).cornerRadius(16)
            }

            Color.clear.frame(height: 40)
        }
        .padding(.horizontal, DS.s3)
        .padding(.top, 20)
    }

    // MARK: Roster Tab

    private var rosterTab: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Team slots grid
            VStack(alignment: .leading, spacing: 12) {
                Text("ALL SLOTS  (\(confirmedCount)/\(totalPlayers) filled)")
                    .font(.caption).fontWeight(.bold).foregroundColor(DS.textSecondary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(roster) { player in
                        VStack(spacing: 6) {
                            ZStack {
                                Circle().fill(player.color.opacity(0.25)).frame(width: 50, height: 50)
                                Text(player.initials)
                                    .font(.caption).fontWeight(.bold).foregroundColor(player.color)
                                Circle()
                                    .fill(player.status.color)
                                    .frame(width: 12, height: 12)
                                    .offset(x: 18, y: 18)
                            }
                            Text(player.name.components(separatedBy: " ").first ?? "")
                                .font(.system(size: 10)).foregroundColor(.white)
                                .lineLimit(1)
                        }
                    }

                    // Open Slots
                    ForEach(0..<openSlots, id: \.self) { _ in
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .strokeBorder(DS.textSecondary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "plus").foregroundColor(DS.textSecondary)
                            }
                            Text("Open")
                                .font(.system(size: 10)).foregroundColor(DS.textSecondary)
                        }
                    }
                }
            }
            .padding(16)
            .background(DS.surface)
            .cornerRadius(18)

            // Roster list
            VStack(spacing: 10) {
                ForEach(roster) { player in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(player.color.opacity(0.25)).frame(width: 44, height: 44)
                            Text(player.initials).font(.caption).fontWeight(.bold).foregroundColor(player.color)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(player.name).font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                            Text(player.status.label).font(.caption).foregroundColor(player.status.color)
                        }

                        Spacer()

                        if player.status == .pendingPayment {
                            Button {} label: {
                                Text("Nudge")
                                    .font(.caption).fontWeight(.bold).foregroundColor(.black)
                                    .padding(.horizontal, 14).padding(.vertical, 6)
                                    .background(Color.white).cornerRadius(10)
                            }
                        }
                    }
                    .padding(14)
                    .background(DS.surface)
                    .cornerRadius(16)
                }
            }

            Color.clear.frame(height: 40)
        }
        .padding(.horizontal, DS.s3)
        .padding(.top, 20)
    }

    // MARK: Chat Tab

    private var chatTab: some View {
        VStack(spacing: 12) {
            ForEach(messages) { msg in
                if msg.isSystem {
                    Text(msg.text)
                        .font(.caption).foregroundColor(DS.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                } else {
                    HStack(alignment: .bottom) {
                        if msg.sender != "You" {
                            Circle().fill(Color.purple.opacity(0.3)).frame(width: 28, height: 28)
                                .overlay(Text(String(msg.sender.prefix(1))).font(.caption2).foregroundColor(.white))
                        }

                        VStack(alignment: msg.sender == "You" ? .trailing : .leading, spacing: 4) {
                            if msg.sender != "You" {
                                Text(msg.sender).font(.caption2).foregroundColor(DS.textSecondary)
                            }
                            Text(msg.text)
                                .font(.subheadline).foregroundColor(.white)
                                .padding(.horizontal, 14).padding(.vertical, 10)
                                .background(msg.sender == "You" ? DS.surface : Color.white.opacity(0.08))
                                .cornerRadius(18)
                        }
                        .frame(maxWidth: 260, alignment: msg.sender == "You" ? .trailing : .leading)

                        if msg.sender == "You" {
                            Spacer(minLength: 0)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: msg.sender == "You" ? .trailing : .leading)
                }
            }
            Color.clear.frame(height: 80)
        }
        .padding(.horizontal, DS.s3)
        .padding(.top, 20)
    }

    // MARK: Teams Tab

    private var teamsTab: some View {
        VStack(alignment: .leading, spacing: 20) {

            Text("District AI will suggest balanced teams based on skill levels once all players confirm.")
                .font(.subheadline).foregroundColor(DS.textSecondary).lineSpacing(4)
                .padding(16).background(DS.surface).cornerRadius(16)

            HStack(alignment: .top, spacing: 16) {
                // Team A
                teamColumn(name: "Team A", color: Color(red: 100/255, green: 180/255, blue: 255/255),
                           players: Array(roster.prefix(roster.count / 2 + roster.count % 2)))

                // Team B
                teamColumn(name: "Team B", color: Color(red: 255/255, green: 130/255, blue: 100/255),
                           players: Array(roster.dropFirst(roster.count / 2 + roster.count % 2)))
            }

            Button {} label: {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Auto-assign Teams with AI")
                }
                .font(.subheadline).fontWeight(.bold).foregroundColor(.black)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(Color.white).cornerRadius(24)
            }

            Color.clear.frame(height: 40)
        }
        .padding(.horizontal, DS.s3)
        .padding(.top, 20)
    }

    // MARK: Chat Input

    private var chatInputBar: some View {
        HStack(spacing: 12) {
            TextField("Message the team...", text: $chatText)
                .foregroundColor(.white)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(DS.surface).cornerRadius(24)

            Button {
                guard !chatText.isEmpty else { return }
                messages.append(ChatMessage(sender: "You", text: chatText, isSystem: false))
                chatText = ""
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32)).foregroundColor(.white)
            }
        }
        .padding(.horizontal, DS.s3).padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
    }

    // MARK: Helper Sub-views

    private func statPill(_ number: String, _ label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(number).font(.headline).fontWeight(.bold).foregroundColor(color)
            Text(label).font(.caption2).foregroundColor(DS.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }

    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(DS.surface).cornerRadius(14)
                Text(label).font(.system(size: 10)).foregroundColor(DS.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(DS.textSecondary).frame(width: 22)
            Text(label).font(.caption).foregroundColor(DS.textSecondary)
            Spacer()
            Text(value).font(.caption).fontWeight(.bold).foregroundColor(.white)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    private func teamColumn(name: String, color: Color, players: [MatchPlayer]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(name).font(.subheadline).fontWeight(.bold)
                .foregroundColor(color)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(color.opacity(0.15)).cornerRadius(10)

            ForEach(players) { p in
                HStack(spacing: 8) {
                    Circle().fill(p.color.opacity(0.2)).frame(width: 32, height: 32)
                        .overlay(Text(p.initials).font(.caption2).fontWeight(.bold).foregroundColor(p.color))
                    Text(p.name.components(separatedBy: " ").first ?? "")
                        .font(.caption).foregroundColor(.white)
                    Spacer()
                }
            }

            let needed = max(0, totalPlayers / 2 - players.count)
            ForEach(0..<needed, id: \.self) { _ in
                HStack(spacing: 8) {
                    Circle().strokeBorder(DS.textSecondary.opacity(0.3), lineWidth: 1.5).frame(width: 32, height: 32)
                        .overlay(Image(systemName: "plus").foregroundColor(DS.textSecondary).font(.caption2))
                    Text("Open").font(.caption).foregroundColor(DS.textSecondary)
                }
            }
        }
        .padding(14)
        .background(DS.surface).cornerRadius(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Supporting Models

struct ChatMessage: Identifiable {
    let id = UUID()
    let sender: String
    let text: String
    let isSystem: Bool
}

// MARK: - Invite Players Sheet

struct InvitePlayersSheet: View {
    @Environment(\.presentationMode) var presentationMode
    let matchType: String

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Invite Players")
                        .font(.title3).fontWeight(.bold).foregroundColor(.white)
                    Spacer()
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(DS.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(DS.surface).clipShape(Circle())
                    }
                }
                .padding(.top, 24)

                // Match Link
                VStack(alignment: .leading, spacing: 12) {
                    Text("SHARE MATCH LINK")
                        .font(.caption).fontWeight(.bold).foregroundColor(DS.textSecondary)

                    HStack {
                        Image(systemName: "link").foregroundColor(DS.textSecondary)
                        Text("district.app/match/CLQ7X")
                            .font(.subheadline).foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                        Button {} label: {
                            Text("Copy")
                                .font(.caption).fontWeight(.bold).foregroundColor(.black)
                                .padding(.horizontal, 14).padding(.vertical, 7)
                                .background(Color.white).cornerRadius(10)
                        }
                    }
                    .padding(14)
                    .background(DS.surface).cornerRadius(14)

                    HStack(spacing: 14) {
                        shareOption(icon: "message.fill", label: "iMessage", color: Color.green)
                        shareOption(icon: "paperplane.fill", label: "WhatsApp", color: Color(red: 37/255, green: 211/255, blue: 102/255))
                        shareOption(icon: "square.and.arrow.up.fill", label: "More", color: DS.textSecondary)
                    }
                }

                // QR Code placeholder
                VStack(spacing: 12) {
                    Text("OR SCAN QR CODE")
                        .font(.caption).fontWeight(.bold).foregroundColor(DS.textSecondary)
                        .frame(maxWidth: .infinity)

                    Image(systemName: "qrcode")
                        .font(.system(size: 120))
                        .foregroundColor(.white)
                        .padding(24)
                        .background(DS.surface).cornerRadius(20)
                        .frame(maxWidth: .infinity)
                }

                Spacer()
            }
            .padding(.horizontal, DS.s3)
        }
    }

    private func shareOption(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3).foregroundColor(.white)
                .frame(width: 52, height: 52)
                .background(color.opacity(0.2)).cornerRadius(14)
            Text(label).font(.caption).foregroundColor(DS.textSecondary)
        }
    }
}
