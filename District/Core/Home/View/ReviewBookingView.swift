import SwiftUI

// MARK: - Review Booking View

struct ReviewBookingView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.presentationMode) var presentationMode
    @Environment(BookingService.self) private var bookingService
    @Environment(AuthViewModel.self) private var authViewModel

    let venue: BoxVenue
    let date: String
    let time: String
    let duration: Double
    let matchType: String
    let totalPlayers: Int
    let totalCost: Double
    let skillLevel: String
    let sport: String
    let slotStartDate: Date

    @State private var isCreating = false
    @State private var errorMessage: String?

    var platformFee: Double { 49 }
    var grandTotal: Double { totalCost + platformFee }
    var perPlayer: Double { totalCost / Double(totalPlayers) }
    var estimatedRecovery: Double { perPlayer * Double(totalPlayers - 1) }
    var organizerNetCost: Double { grandTotal - estimatedRecovery }

    var body: some View {
        ZStack(alignment: .bottom) {
            DS.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Booking Card ─────────────────────────────────────
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 14) {
                            if let img = venue.imageNames.first {
                                Image(img)
                                    .resizable().scaledToFill()
                                    .frame(width: 72, height: 64).cornerRadius(10).clipped()
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text(venue.name)
                                    .font(.headline).foregroundColor(.white)
                                HStack(spacing: 6) {
                                    Image(systemName: "calendar").foregroundColor(DS.textSecondary).font(.caption)
                                    Text(date).font(.caption).foregroundColor(.white)
                                }
                                HStack(spacing: 6) {
                                    Image(systemName: "clock").foregroundColor(DS.textSecondary).font(.caption)
                                    Text("\(time) · \(String(format: "%.1f", duration)) hr").font(.caption).foregroundColor(.white)
                                }
                            }
                        }

                        Divider().background(DS.textSecondary.opacity(0.2)).padding(.vertical, 16)

                        // Match Config Summary
                        HStack(spacing: 0) {
                            configPill(icon: matchType == "Public" ? "globe" : "lock.fill", label: matchType == "Public" ? "Public" : "Private")
                            configPill(icon: "person.2.fill", label: "\(totalPlayers) players")
                            configPill(icon: "star.fill", label: skillLevel)
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .background(DS.surface)
                    .cornerRadius(16)
                    .padding(.horizontal, DS.s3)
                    .padding(.top, 4)

                    // ── Price Breakdown ──────────────────────────────────
                    sectionHeader("PRICE BREAKDOWN")

                    VStack(spacing: 14) {
                        priceRow("Turf Booking (\(String(format: "%.1f", duration)) hr)", "₹\(String(format: "%.0f", totalCost))", color: .white)
                        priceRow("Platform Fee", "₹\(String(format: "%.0f", platformFee))", color: .white)

                        Divider().background(DS.textSecondary.opacity(0.3))

                        priceRow("Total Payable Now", "₹\(String(format: "%.0f", grandTotal))", color: .white, font: .headline)

                        Divider().background(DS.textSecondary.opacity(0.2))

                        VStack(spacing: 10) {
                            priceRow("Estimated Recovery (\(totalPlayers - 1) players × ₹\(String(format: "%.0f", perPlayer)))",
                                     "+ ₹\(String(format: "%.0f", estimatedRecovery))",
                                     color: Color(red: 100/255, green: 220/255, blue: 120/255))
                            priceRow("Your Net Cost", "₹\(String(format: "%.0f", organizerNetCost))",
                                     color: organizerNetCost < 300 ? Color(red: 100/255, green: 220/255, blue: 120/255) : .white,
                                     font: .subheadline)
                        }
                        .padding(12)
                        .background(Color(red: 100/255, green: 220/255, blue: 120/255).opacity(0.06))
                        .cornerRadius(12)
                    }
                    .padding(16)
                    .background(DS.surface)
                    .cornerRadius(16)
                    .padding(.horizontal, DS.s3)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption).foregroundColor(.red)
                            .padding(.horizontal, DS.s3)
                            .padding(.top, 12)
                    }

                    Color.clear.frame(height: 120)
                }
            }

            // ── Bottom Pay Bar ──────────────────────────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("₹\(String(format: "%.0f", grandTotal))")
                        .font(.title3).fontWeight(.bold).foregroundColor(.white)
                    Text("Total Booking Cost")
                        .font(.caption).foregroundColor(DS.textSecondary)
                }

                Spacer()

                Button(action: {
                    Task { await createMatch() }
                }) {
                    HStack(spacing: 6) {
                        if isCreating {
                            ProgressView().tint(.black)
                        } else {
                            Image(systemName: "play.fill").font(.caption)
                            Text("Pay & Create Match")
                        }
                    }
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.black)
                    .padding(.horizontal, 24).padding(.vertical, 14)
                    .background(Color.white).cornerRadius(24)
                }
                .disabled(isCreating)
            }
            .padding(.horizontal, 20).padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .cornerRadius(36)
            .overlay(RoundedRectangle(cornerRadius: 36).stroke(Color.white.opacity(0.12), lineWidth: 1))
            .padding(.horizontal, DS.s3)
            .padding(.bottom, 16)
        }
        .navigationTitle("Review Booking")
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
            .font(.caption).fontWeight(.bold).foregroundColor(DS.textSecondary)
            .padding(.horizontal, DS.s3)
            .padding(.top, 24).padding(.bottom, 8)
    }

    private func configPill(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2).foregroundColor(DS.textSecondary)
            Text(label).font(.caption2).foregroundColor(DS.textSecondary)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Color.white.opacity(0.06))
        .cornerRadius(8)
        .padding(.trailing, 6)
    }

    private func priceRow(_ label: String, _ value: String, color: Color, font: Font = .subheadline) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundColor(DS.textSecondary)
            Spacer()
            Text(value).font(font).fontWeight(.bold).foregroundColor(color)
        }
    }

    private func createMatch() async {
        guard let user = authViewModel.currentUser else {
            errorMessage = "Please sign in to create a match."
            return
        }

        isCreating = true
        errorMessage = nil

        do {
            let bookingId = try await bookingService.createBooking(
                venue: venue,
                sport: sport,
                host: user,
                slotDateLabel: date,
                slotTimeLabel: time,
                startDate: slotStartDate,
                durationHours: duration,
                isPublic: matchType == "Public",
                title: nil,
                matchType: matchType,
                skillLevel: skillLevel,
                ageGroup: nil,
                rules: nil,
                totalSpots: totalPlayers,
                totalCost: totalCost,
                perPlayerCost: perPlayer
            )
            isCreating = false
            router.push(.matchRoom(bookingId: bookingId))
        } catch {
            isCreating = false
            errorMessage = error.localizedDescription
        }
    }
}
