import SwiftUI

// MARK: - Review Booking View

struct ReviewBookingView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.presentationMode) var presentationMode

    let venue: BoxVenue
    let date: String
    let time: String
    let duration: Double
    let matchType: String
    let totalPlayers: Int
    let totalCost: Double
    let skillLevel: String
    let paymentWindow: Int

    @State private var couponCode = ""
    @State private var couponApplied = false
    @State private var selectedPayment = "UPI"

    var platformFee: Double { 49 }
    var discount: Double { couponApplied ? 100 : 0 }
    var grandTotal: Double { totalCost + platformFee - discount }
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
                            Image("cricket1")
                                .resizable().scaledToFill()
                                .frame(width: 72, height: 64).cornerRadius(10).clipped()

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

                        if couponApplied {
                            priceRow("Coupon (PLAY100)", "- ₹100", color: Color(red: 100/255, green: 220/255, blue: 120/255))
                        }

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

                    // ── Coupon ────────────────────────────────────────────
                    sectionHeader("COUPON CODE")

                    HStack {
                        Image(systemName: "ticket").foregroundColor(DS.textSecondary)
                        TextField("Enter coupon", text: $couponCode)
                            .foregroundColor(.white)
                            .font(.subheadline)
                        Spacer()
                        Button {
                            if couponCode.uppercased() == "PLAY100" { couponApplied = true }
                        } label: {
                            Text("Apply")
                                .font(.caption).fontWeight(.bold).foregroundColor(.black)
                                .padding(.horizontal, 14).padding(.vertical, 7)
                                .background(Color.white).cornerRadius(10)
                        }
                    }
                    .padding(16)
                    .background(DS.surface)
                    .cornerRadius(16)
                    .padding(.horizontal, DS.s3)

                    // ── Payment Method ────────────────────────────────────
                    sectionHeader("PAY VIA")

                    HStack(spacing: 10) {
                        ForEach(["UPI", "Card", "Wallet"], id: \.self) { method in
                            Button { selectedPayment = method } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: paymentIcon(method))
                                        .font(.caption)
                                    Text(method).font(.caption).fontWeight(.bold)
                                }
                                .foregroundColor(selectedPayment == method ? .black : .white)
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(selectedPayment == method ? Color.white : DS.surface)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedPayment == method ? Color.clear : DS.textSecondary.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, DS.s3)

                    // ── Cancellation Policy ───────────────────────────────
                    sectionHeader("CANCELLATION POLICY")

                    VStack(alignment: .leading, spacing: 12) {
                        cancellationRow(icon: "clock.badge.checkmark", label: "> 24 hrs", detail: "Full refund to wallet")
                        cancellationRow(icon: "clock.badge.exclamationmark", label: "4–24 hrs", detail: "50% refund + slot reopened")
                        cancellationRow(icon: "xmark.circle", label: "< 4 hrs", detail: "No refund — slot stays open")
                        cancellationRow(icon: "cloud.rain", label: "Venue / Rain", detail: "100% refund guaranteed")
                    }
                    .padding(16)
                    .background(DS.surface)
                    .cornerRadius(16)
                    .padding(.horizontal, DS.s3)

                    // ── Disclaimer ────────────────────────────────────────
                    Text("Payment Window: Players have \(paymentWindow) hr\(paymentWindow > 1 ? "s" : "") to pay after invite. Unpaid slots auto-open to public to protect your investment.")
                        .font(.caption).foregroundColor(DS.textSecondary)
                        .lineSpacing(3)
                        .padding(.horizontal, DS.s3)
                        .padding(.top, 12)

                    Color.clear.frame(height: 120)
                }
            }

            // ── Bottom Pay Bar ──────────────────────────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("₹\(String(format: "%.0f", grandTotal))")
                        .font(.title3).fontWeight(.bold).foregroundColor(.white)
                    Text("Pay via \(selectedPayment)")
                        .font(.caption).foregroundColor(DS.textSecondary)
                }

                Spacer()

                Button(action: {
                    router.push(.matchRoom(
                        venue: venue,
                        date: date,
                        time: time,
                        matchType: matchType,
                        totalPlayers: totalPlayers,
                        perPlayerCost: perPlayer,
                        totalCost: totalCost,
                        skillLevel: skillLevel
                    ))
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill").font(.caption)
                        Text("Pay & Book")
                    }
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.black)
                    .padding(.horizontal, 24).padding(.vertical, 14)
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

    private func cancellationRow(icon: String, label: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(DS.textSecondary).frame(width: 20)
            Text(label).font(.caption).fontWeight(.bold).foregroundColor(.white).frame(width: 70, alignment: .leading)
            Text(detail).font(.caption).foregroundColor(DS.textSecondary)
        }
    }

    private func paymentIcon(_ method: String) -> String {
        switch method {
        case "UPI": return "indianrupeesign.circle.fill"
        case "Card": return "creditcard.fill"
        case "Wallet": return "wallet.pass.fill"
        default: return "creditcard"
        }
    }
}
