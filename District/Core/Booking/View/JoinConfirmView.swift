//
//  JoinConfirmView.swift
//  District
//

import SwiftUI
import FirebaseFirestore

struct JoinConfirmView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    let bookingId: String

    @State private var booking: BookingEntity?
    @State private var isLoading = true
    @State private var isJoining = false
    @State private var errorMessage: String?

    private let service = BookingService()

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            if isLoading {
                ProgressView().tint(.white)
            } else if let booking {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // Match Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 14) {
                                if let img = booking.venueImageName {
                                    Image(img)
                                        .resizable().scaledToFill()
                                        .frame(width: 72, height: 64).cornerRadius(10).clipped()
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(booking.venueName)
                                        .font(.headline).foregroundColor(.white)
                                    Text(booking.sport)
                                        .font(.caption).foregroundColor(DS.textSecondary)
                                }
                            }

                            Divider().background(DS.textSecondary.opacity(0.2))

                            HStack(spacing: 0) {
                                infoPill(icon: "calendar", text: booking.slotDateLabel)
                                infoPill(icon: "clock", text: booking.slotTimeLabel)
                                infoPill(icon: "person.2.fill", text: "\(booking.participantIds.count)/\(booking.totalSpots)")
                            }

                            Divider().background(DS.textSecondary.opacity(0.2))

                            HStack {
                                Text("Your Share")
                                    .font(.subheadline).foregroundColor(DS.textSecondary)
                                Spacer()
                                Text("\u{20B9}\(String(format: "%.0f", booking.perPlayerCost))")
                                    .font(.title3).fontWeight(.bold).foregroundColor(.white)
                            }

                            Text("Hosted by \(booking.hostName)")
                                .font(.caption).foregroundColor(DS.textSecondary)
                        }
                        .padding(16)
                        .background(DS.surface)
                        .cornerRadius(16)
                        .padding(.horizontal, DS.s3)
                        .padding(.top, 16)

                        // Payment note
                        HStack(spacing: 14) {
                            Image(systemName: "clock.badge.checkmark")
                                .font(.title2)
                                .foregroundColor(Color(red: 100/255, green: 220/255, blue: 120/255))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Paymentz Deferred")
                                    .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                                Text("Joining reserves your spot. You'll pay your share of \u{20B9}\(Int(booking.perPlayerCost)) when the payment window closes.")
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
                        .padding(.top, 20)

                        if let error = errorMessage {
                            Text(error)
                                .font(.caption).foregroundColor(.red)
                                .padding(.horizontal, DS.s3)
                                .padding(.top, 12)
                        }

                        Color.clear.frame(height: 120)
                    }
                }

                // Bottom bar
                VStack {
                    Spacer()
                    Button {
                        Task { await joinMatch() }
                    } label: {
                        HStack {
                            if isJoining {
                                ProgressView().tint(.black)
                            } else {
                                Image(systemName: "checkmark.circle.fill").font(.caption)
                                Text("Confirm & Join")
                            }
                        }
                        .font(.subheadline).fontWeight(.bold).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color.white).cornerRadius(24)
                    }
                    .disabled(isJoining)
                    .padding(.horizontal, DS.s3)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Join Match")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .task { await fetchBooking() }
    }

    private func fetchBooking() async {
        do {
            let snap = try await Firestore.firestore()
                .collection(Constants.bookingsCollectionPath)
                .document(bookingId)
                .getDocument()
            booking = try snap.data(as: BookingEntity.self)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func joinMatch() async {
        guard let user = authViewModel.currentUser else {
            errorMessage = "Please sign in first."
            return
        }
        isJoining = true
        defer { isJoining = false }
        do {
            let svc = BookingService()
            try await svc.joinBooking(id: bookingId, user: user)
            router.push(.matchRoom(bookingId: bookingId))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func infoPill(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2).foregroundColor(DS.textSecondary)
            Text(text).font(.caption2).foregroundColor(DS.textSecondary)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Color.white.opacity(0.06))
        .cornerRadius(8)
        .padding(.trailing, 6)
    }
}
