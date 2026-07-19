//
//  MatchRoomView.swift
//  District
//

import SwiftUI

struct MatchRoomView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(AppRouter.self) private var router
    @Environment(AuthViewModel.self) private var authViewModel
    
    let bookingId: String

    @State private var viewModel: MatchRoomViewModel
    @State private var showInviteSheet = false
    @State private var activeTab = "Room"
    @State private var chatText = ""

    private let tabs = ["Room", "Chat"]

    init(bookingId: String) {
        self.bookingId = bookingId
        self._viewModel = State(initialValue: MatchRoomViewModel(bookingId: bookingId))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            DS.background.ignoresSafeArea()

            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView().tint(.white)
                    Spacer()
                }
            } else if let booking = viewModel.booking {
                VStack(spacing: 0) {
                    liveActivityBanner(booking: booking)
                    tabBar

                    ScrollView(showsIndicators: false) {
                        if activeTab == "Room" {
                            roomTab(booking: booking)
                        } else {
                            chatTab
                        }
                    }
                }

                if activeTab == "Chat" {
                    chatInputBar
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showInviteSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .onAppear {
            viewModel.startListening()
        }
        .onDisappear {
            viewModel.stopListening()
        }
        .sheet(isPresented: $showInviteSheet) {
            if let code = viewModel.booking?.inviteCode {
                InvitePlayersSheet(joinCode: code)
            }
        }
    }
    
    // MARK: - Banner
    
    @ViewBuilder
    private func liveActivityBanner(booking: BookingEntity) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .foregroundColor(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text(booking.status == .open ? "WAITING FOR PLAYERS" : "MATCH CONFIRMED")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.7))
                Text(booking.status == .open ? "\(viewModel.openSlots) slots remaining" : "Ready to play")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
        .padding(.horizontal, DS.s3)
        .padding(.vertical, 10)
    }
    
    // MARK: - Tab Bar

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
        .overlay(Divider().background(Color.white.opacity(0.08)).offset(y: 20), alignment: .bottom)
    }

    // MARK: - Room Tab

    @ViewBuilder
    private func roomTab(booking: BookingEntity) -> some View {
        VStack(spacing: 24) {

            paymentSection(booking: booking)

            // Financial Status Dashboard
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Total Collected")
                        .font(.caption)
                        .foregroundColor(DS.textSecondary)
                    Text("₹\(Int(viewModel.totalCollected))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("of ₹\(Int(booking.totalCost))")
                        .font(.caption2)
                        .foregroundColor(DS.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Players Paid")
                        .font(.caption)
                        .foregroundColor(DS.textSecondary)
                    Text("\(viewModel.confirmedCount)/\(booking.totalSpots)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    ProgressView(value: viewModel.fillPercent)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
            }
            
            // Match Details
            VStack(alignment: .leading, spacing: 0) {
                Text("Match Details")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                
                detailRow(icon: "mappin.circle.fill", label: "Venue", value: booking.venueName)
                Divider().background(Color.white.opacity(0.1))
                detailRow(icon: "calendar", label: "Date", value: booking.slotDateLabel)
                Divider().background(Color.white.opacity(0.1))
                detailRow(icon: "clock.fill", label: "Time", value: booking.slotTimeLabel)
                Divider().background(Color.white.opacity(0.1))
                detailRow(icon: "indianrupeesign.circle.fill", label: "Per Player", value: "₹\(Int(booking.perPlayerCost))")
                Divider().background(Color.white.opacity(0.1))
                detailRow(icon: "star.circle.fill", label: "Skill Level", value: booking.skillLevel)
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            
            // Roster
            VStack(alignment: .leading, spacing: 16) {
                Text("Roster (\(viewModel.participants.count)/\(booking.totalSpots))")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                
                ForEach(viewModel.participants) { player in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 44, height: 44)
                            .overlay(Text(String(player.name.prefix(1))).font(.subheadline).foregroundColor(.white))
                            .overlay(
                                Circle()
                                    .fill(player.hasPaid ? Color.green : Color.orange)
                                    .frame(width: 12, height: 12)
                                    .offset(x: 14, y: 14)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(player.name).font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                            Text(player.hasPaid ? "Paid" : "Pending Payment").font(.caption).foregroundColor(player.hasPaid ? .green : .orange)
                        }
                        Spacer()
                        if player.isHost {
                            Text("HOST")
                                .font(.caption2).fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                }
            }
            
            Color.clear.frame(height: 40)
        }
        .padding(.horizontal, DS.s3)
        .padding(.top, 20)
    }
    
    // MARK: - Payment Section (deferred to window close)

    @ViewBuilder
    private func paymentSection(booking: BookingEntity) -> some View {
        if booking.status == .cancelled {
            statusBanner(icon: "xmark.circle.fill", text: "This match was cancelled.", color: .red)
        } else if !viewModel.participants.isEmpty && viewModel.participants.count == booking.totalSpots {
            statusBanner(icon: "checkmark.seal.fill", text: "Confirmed — everyone has paid and the match is full!", color: .green)
        }
    }

    private func statusBanner(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.title2).foregroundColor(color)
            Text(text).font(.caption).foregroundColor(.white).lineSpacing(2)
        }
        .padding(16)
        .background(color.opacity(0.1))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Chat Tab

    private var chatTab: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.messages) { msg in
                if msg.isSystem {
                    Text(msg.text)
                        .font(.caption).foregroundColor(DS.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                } else {
                    let isMe = msg.senderId == authViewModel.currentUser?.uid
                    HStack(alignment: .bottom) {
                        if !isMe {
                            Circle().fill(Color.purple.opacity(0.3)).frame(width: 28, height: 28)
                                .overlay(Text(String(msg.senderName.prefix(1))).font(.caption2).foregroundColor(.white))
                        }
                        VStack(alignment: isMe ? .trailing : .leading, spacing: 4) {
                            if !isMe {
                                Text(msg.senderName).font(.caption2).foregroundColor(DS.textSecondary)
                            }
                            Text(msg.text)
                                .font(.subheadline).foregroundColor(.white)
                                .padding(.horizontal, 14).padding(.vertical, 10)
                                .background(isMe ? Color.white.opacity(0.12) : Color.white.opacity(0.08))
                                .cornerRadius(18)
                        }
                        .frame(maxWidth: 260, alignment: isMe ? .trailing : .leading)
                        if isMe { Spacer(minLength: 0) }
                    }
                    .frame(maxWidth: .infinity, alignment: isMe ? .trailing : .leading)
                }
            }
            Color.clear.frame(height: 80)
        }
        .padding(.horizontal, DS.s3)
        .padding(.top, 20)
    }

    private var chatInputBar: some View {
        HStack(spacing: 12) {
            TextField("Message the team...", text: $chatText)
                .foregroundColor(.white)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(DS.surface).cornerRadius(24)

            Button {
                guard !chatText.isEmpty, let user = authViewModel.currentUser else { return }
                let text = chatText
                chatText = ""
                Task { await viewModel.sendMessage(text: text, sender: user) }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32)).foregroundColor(.white)
            }
        }
        .padding(.horizontal, DS.s3).padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
    }

    // MARK: - Helpers

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(DS.textSecondary).frame(width: 22)
            Text(label).font(.caption).foregroundColor(DS.textSecondary)
            Spacer()
            Text(value).font(.caption).fontWeight(.bold).foregroundColor(.white)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}
