//
//  MyMatchesView.swift
//  District
//

import SwiftUI

struct MyMatchesView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = MyMatchesViewModel()

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView().tint(.white)
            } else if viewModel.bookings.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "sportscourt")
                        .font(.system(size: 48))
                        .foregroundColor(DS.textSecondary)
                    Text("No matches yet")
                        .font(.headline).foregroundColor(.white)
                    Text("Create or join a match to see it here.")
                        .font(.caption).foregroundColor(DS.textSecondary)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.bookings) { booking in
                            matchCard(booking)
                                .onTapGesture {
                                    if let id = booking.id {
                                        router.push(.matchRoom(bookingId: id))
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, DS.s3)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("My Matches")
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
        .onAppear {
            if let uid = authViewModel.currentUser?.uid {
                viewModel.startObserving(uid: uid)
            }
        }
        .onDisappear {
            viewModel.stopObserving()
        }
    }

    private func matchCard(_ booking: BookingEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                if let img = booking.venueImageName {
                    Image(img)
                        .resizable().scaledToFill()
                        .frame(width: 56, height: 48).cornerRadius(10).clipped()
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.title ?? booking.sport)
                        .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                    Text(booking.venueName)
                        .font(.caption).foregroundColor(DS.textSecondary)
                }
                Spacer()
                statusBadge(booking.status)
            }

            Divider().background(DS.textSecondary.opacity(0.2))

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "calendar").font(.caption2).foregroundColor(DS.textSecondary)
                    Text(booking.slotDateLabel).font(.caption).foregroundColor(.white)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "clock").font(.caption2).foregroundColor(DS.textSecondary)
                    Text(booking.slotTimeLabel).font(.caption).foregroundColor(.white)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "person.2").font(.caption2).foregroundColor(DS.textSecondary)
                    Text("\(booking.participantIds.count)/\(booking.totalSpots)").font(.caption).foregroundColor(.white)
                }
            }
        }
        .padding(16)
        .background(DS.surface)
        .cornerRadius(16)
    }

    private func statusBadge(_ status: BookingStatus) -> some View {
        let (text, color): (String, Color) = {
            switch status {
            case .open: return ("Open", Color(red: 100/255, green: 220/255, blue: 120/255))

            case .confirmed: return ("Confirmed", Color(red: 100/255, green: 180/255, blue: 255/255))
            case .cancelled: return ("Cancelled", .red)
            }
        }()
        return Text(text)
            .font(.caption2).fontWeight(.bold)
            .foregroundColor(color)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(color.opacity(0.15))
            .cornerRadius(8)
    }
}
