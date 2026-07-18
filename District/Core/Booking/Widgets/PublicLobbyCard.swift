//
//  PublicLobbyCard.swift
//  District
//

import SwiftUI

struct PublicLobbyCard: View {
    let booking: BookingEntity
    let onJoin: () -> Void

    var spotsLeft: Int {
        max(0, booking.totalSpots - booking.participantIds.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.title ?? "\(booking.sport) Match")
                        .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                    Text("by \(booking.hostName)")
                        .font(.caption).foregroundColor(DS.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\u{20B9}\(String(format: "%.0f", booking.perPlayerCost))")
                        .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                    Text("/player").font(.caption2).foregroundColor(DS.textSecondary)
                }
            }

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "clock").font(.caption2).foregroundColor(DS.textSecondary)
                    Text("\(booking.slotDateLabel) · \(booking.slotTimeLabel)")
                        .font(.caption).foregroundColor(.white)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "person.2").font(.caption2).foregroundColor(DS.textSecondary)
                    Text("\(spotsLeft) spots left")
                        .font(.caption).fontWeight(.bold)
                        .foregroundColor(spotsLeft <= 2 ? Color(red: 255/255, green: 170/255, blue: 60/255) : Color(red: 100/255, green: 220/255, blue: 120/255))
                }
            }

            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").font(.caption2).foregroundColor(DS.textSecondary)
                    Text(booking.skillLevel).font(.caption).foregroundColor(DS.textSecondary)
                }
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color.white.opacity(0.06)).cornerRadius(8)

                HStack(spacing: 4) {
                    Image(systemName: booking.matchType == "Public" ? "globe" : "lock.fill").font(.caption2).foregroundColor(DS.textSecondary)
                    Text(booking.matchType).font(.caption).foregroundColor(DS.textSecondary)
                }
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color.white.opacity(0.06)).cornerRadius(8)

                Spacer()

                Button(action: onJoin) {
                    Text("Join")
                        .font(.caption).fontWeight(.bold).foregroundColor(.black)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(Color.white).cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(DS.surface)
        .cornerRadius(16)
    }
}
