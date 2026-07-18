import SwiftUI

// MARK: - Data Models

struct BookingSlot: Identifiable, Equatable {
    let id = UUID()
    let time: String
    let availability: String
    var isBooked: Bool = false
}

// MARK: - Book Slot View (Dynamic, Step-by-Step)

struct BookSlotView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.presentationMode) var presentationMode
    let venue: BoxVenue

    // Step state
    @State private var selectedDate = 19
    @State private var durationHours: Double = 1.0
    @State private var selectedTimeOfDay = "Morning"
    @State private var selectedTimeSlot: BookingSlot? = nil
    @State private var selectedTurf = false
    
    // Expand/collapse animation
    @State private var timeSlotsExpanded = true

    let dates = [(19,"Sun"),(20,"Mon"),(21,"Tue"),(22,"Wed"),(23,"Thu"),(24,"Fri")]

    var morningSlots: [BookingSlot] {
        [
            BookingSlot(time: "6 - 7 AM", availability: "1 Outdoor"),
            BookingSlot(time: "6:30 - 7:30 AM", availability: "1 Outdoor"),
            BookingSlot(time: "7 - 8 AM", availability: "1 Outdoor"),
            BookingSlot(time: "7:30 - 8:30 AM", availability: "1 Outdoor"),
            BookingSlot(time: "8 - 9 AM", availability: "1 Outdoor"),
            BookingSlot(time: "8:30 - 9:30 AM", availability: "1 Outdoor"),
            BookingSlot(time: "9 - 10 AM", availability: "1 Outdoor"),
            BookingSlot(time: "9:30 - 10:30 AM", availability: "1 Outdoor"),
            BookingSlot(time: "10 - 11 AM", availability: "1 Outdoor"),
            BookingSlot(time: "10:30 - 11:30 AM", availability: "1 Outdoor"),
            BookingSlot(time: "11 AM - 12 PM", availability: "1 Outdoor"),
            BookingSlot(time: "11:30 AM - 12:30 PM", availability: "1 Outdoor", isBooked: true)
        ]
    }

    var eveningSlots: [BookingSlot] {
        [
            BookingSlot(time: "4 - 5 PM", availability: "1 Outdoor"),
            BookingSlot(time: "4:30 - 5:30 PM", availability: "1 Outdoor"),
            BookingSlot(time: "5 - 6 PM", availability: "1 Outdoor"),
            BookingSlot(time: "5:30 - 6:30 PM", availability: "1 Outdoor"),
            BookingSlot(time: "6 - 7 PM", availability: "1 Outdoor"),
            BookingSlot(time: "6:30 - 7:30 PM", availability: "1 Outdoor"),
            BookingSlot(time: "7 - 8 PM", availability: "1 Outdoor", isBooked: true),
            BookingSlot(time: "7:30 - 8:30 PM", availability: "1 Outdoor"),
            BookingSlot(time: "8 - 9 PM", availability: "1 Outdoor"),
            BookingSlot(time: "8:30 - 9:30 PM", availability: "1 Outdoor"),
            BookingSlot(time: "9 - 10 PM", availability: "1 Outdoor"),
            BookingSlot(time: "10 - 11 PM", availability: "1 Outdoor")
        ]
    }

    var activeSlots: [BookingSlot] {
        selectedTimeOfDay == "Morning" ? morningSlots : eveningSlots
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            DS.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Calendar Strip ──────────────────────────────────
                    HStack(spacing: 10) {
                        Text("JUL")
                            .font(.caption2).fontWeight(.bold).foregroundColor(.white)
                            .frame(width: 36, height: 68)
                            .background(DS.surface).cornerRadius(14)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(dates, id: \.0) { date in
                                    Button { selectedDate = date.0 } label: {
                                        VStack(spacing: 4) {
                                            Text("\(date.0)").font(.headline)
                                            Text(date.1).font(.caption2)
                                        }
                                        .foregroundColor(selectedDate == date.0 ? .black : DS.textSecondary)
                                        .frame(width: 54, height: 68)
                                        .background(selectedDate == date.0 ? Color.white : Color.clear)
                                        .cornerRadius(14)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DS.s3)

                    // ── Duration Stepper ────────────────────────────────
                    HStack {
                        Text("Duration").font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                        Spacer()
                        HStack(spacing: 14) {
                            Button { if durationHours > 0.5 { durationHours -= 0.5 } } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            Text(durationHours == 1 ? "1 hr" : "\(String(format: "%.1f", durationHours)) hrs")
                                .font(.headline).foregroundColor(.black).frame(width: 50, alignment: .center)
                            Button { durationHours += 0.5 } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .padding(16)
                    .background(DS.surface)
                    .cornerRadius(16)
                    .padding(.horizontal, DS.s3)
                    .padding(.top, 20)

                    // ── Time Slot Picker ─────────────────────────────────
                    VStack(alignment: .leading, spacing: 16) {

                        // Section header – tappable to collapse when slot chosen
                        Button {
                            if selectedTimeSlot != nil {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    timeSlotsExpanded.toggle()
                                }
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Time slots available")
                                        .font(.headline).foregroundColor(.white)
                                    if let slot = selectedTimeSlot, !timeSlotsExpanded {
                                        Text(slot.time)
                                            .font(.caption)
                                            .foregroundColor(Color(red: 100/255, green: 220/255, blue: 120/255))
                                    }
                                }
                                Spacer()
                                if selectedTimeSlot != nil {
                                    Image(systemName: timeSlotsExpanded ? "chevron.up" : "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(DS.textSecondary)
                                }
                            }
                            .padding(.horizontal, DS.s3)
                        }
                        .buttonStyle(PlainButtonStyle())

                        if timeSlotsExpanded {
                            // Morning / Evening Toggle
                            HStack(spacing: 0) {
                                ForEach(["Morning", "Evening"], id: \.self) { period in
                                    Button { selectedTimeOfDay = period } label: {
                                        Text(period)
                                            .font(.subheadline).fontWeight(.semibold)
                                            .foregroundColor(selectedTimeOfDay == period ? .white : DS.textSecondary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(selectedTimeOfDay == period ? DS.surface : Color.clear)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(4)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(24)
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(DS.surface, lineWidth: 1))
                            .padding(.horizontal, DS.s3)

                            // Grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(activeSlots) { slot in
                                    Button {
                                        if slot.isBooked { return }
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            selectedTimeSlot = slot
                                            selectedTurf = false
                                            timeSlotsExpanded = false
                                        }
                                    } label: {
                                        VStack(spacing: 4) {
                                            Text(slot.time)
                                                .font(.subheadline).fontWeight(.bold)
                                                .foregroundColor(slot.isBooked ? DS.textSecondary : .white)
                                                .multilineTextAlignment(.center)
                                            Text(slot.isBooked ? "Booked" : slot.availability)
                                                .font(.caption2)
                                                .foregroundColor(slot.isBooked
                                                    ? Color.red.opacity(0.7)
                                                    : DS.textSecondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(selectedTimeSlot?.id == slot.id
                                            ? Color.white.opacity(0.08)
                                            : slot.isBooked ? DS.surface.opacity(0.4) : Color.clear)
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    selectedTimeSlot?.id == slot.id ? Color.white
                                                        : slot.isBooked ? Color.clear : DS.surface,
                                                    lineWidth: 1
                                                )
                                        )
                                        .strikethrough(slot.isBooked)
                                    }
                                    .disabled(slot.isBooked)
                                }
                            }
                            .padding(.horizontal, DS.s3)
                        }
                    }
                    .padding(.top, 24)

                    // ── Turf Available (slides in after time selection) ───
                    if selectedTimeSlot != nil {
                        VStack(alignment: .leading, spacing: 16) {

                            Text("1 turf available")
                                .font(.headline).foregroundColor(.white)
                                .padding(.horizontal, DS.s3)

                            Button { withAnimation(.spring()) { selectedTurf.toggle() } } label: {
                                HStack(spacing: 14) {
                                    Image("cricket1")
                                        .resizable().scaledToFill()
                                        .frame(width: 72, height: 64).cornerRadius(10).clipped()

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Turf 1")
                                            .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                                        Text("Outdoor  |  Artificial grass  |  7 vs 7")
                                            .font(.caption).foregroundColor(DS.textSecondary)
                                        Text("₹2,000 / hr")
                                            .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                                    }

                                    Spacer()

                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedTurf
                                                ? Color(red: 100/255, green: 160/255, blue: 240/255)
                                                : Color.clear)
                                            .frame(width: 28, height: 28)
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedTurf
                                                ? Color.clear
                                                : DS.textSecondary, lineWidth: 1.5)
                                            .frame(width: 28, height: 28)
                                        if selectedTurf {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .padding(16)
                                .background(DS.surface)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedTurf ? Color(red: 100/255, green: 160/255, blue: 240/255) : Color.clear, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, DS.s3)
                        }
                        .padding(.top, 28)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Color.clear.frame(height: 120)
                }
            }

            // ── Bottom Bar ─────────────────────────────────────────────
            if selectedTurf, let slot = selectedTimeSlot {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("1 turf · \(slot.time)")
                            .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                        Text("₹\(String(format: "%.0f", 2000 * durationHours))  ·  Jul \(selectedDate)")
                            .font(.caption).foregroundColor(DS.textSecondary)
                    }

                    Spacer()

                    Button(action: {
                        router.push(.matchSetup(
                            venue: venue,
                            date: "Jul \(selectedDate)",
                            time: slot.time,
                            duration: durationHours,
                            turfName: "Turf 1",
                            totalCost: 2000 * durationHours
                        ))
                    }) {
                        Text("Proceed")
                            .font(.subheadline).fontWeight(.bold).foregroundColor(.black)
                            .padding(.horizontal, 28).padding(.vertical, 14)
                            .background(Color.white).cornerRadius(24)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .cornerRadius(36)
                .overlay(RoundedRectangle(cornerRadius: 36).stroke(Color.white.opacity(0.12), lineWidth: 1))
                .padding(.horizontal, DS.s3)
                .padding(.bottom, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTurf)
            }
        }
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
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text("Box Cricket")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(venue.name)
                        .font(.caption2)
                        .foregroundColor(DS.textSecondary)
                }
            }
        }
    }
}
