//
//  MatchRoomViewModel.swift
//  District
//

import Foundation
import FirebaseFirestore

@Observable
@MainActor
final class MatchRoomViewModel {
    let bookingId: String
    private let service = BookingService()

    var booking: BookingEntity?
    var participants: [BookingParticipant] = []
    var messages: [BookingMessage] = []
    var isLoading = true
    var errorMessage: String?

    private var bookingListener: ListenerRegistration?
    private var participantsListener: ListenerRegistration?
    private var messagesListener: ListenerRegistration?
    private var expiryCheckTask: Task<Void, Never>?

    // Derived
    var paymentEnabled: Bool {
        guard let booking else { return false }
        return Date() >= booking.paymentDeadline
    }

    var timeRemaining: TimeInterval {
        guard let booking else { return 0 }
        return max(0, booking.paymentDeadline.timeIntervalSinceNow)
    }

    var confirmedCount: Int {
        participants.filter(\.hasPaid).count
    }

    var totalCollected: Double {
        participants.reduce(0) { $0 + $1.amountPaid }
    }

    var openSlots: Int {
        (booking?.totalSpots ?? 0) - participants.count
    }

    var fillPercent: Double {
        guard let booking, booking.totalSpots > 0 else { return 0 }
        return Double(participants.count) / Double(booking.totalSpots)
    }

    var allPaid: Bool {
        !participants.isEmpty && participants.allSatisfy(\.hasPaid)
    }

    init(bookingId: String) {
        self.bookingId = bookingId
    }

    func startListening() {
        isLoading = true

        bookingListener = service.observeBooking(id: bookingId) { [weak self] booking in
            Task { @MainActor in
                self?.booking = booking
                self?.isLoading = false
            }
        }

        participantsListener = service.observeParticipants(bookingId: bookingId) { [weak self] list in
            Task { @MainActor in
                self?.participants = list
            }
        }

        messagesListener = service.observeMessages(bookingId: bookingId) { [weak self] list in
            Task { @MainActor in
                self?.messages = list
            }
        }

        // Periodically check whether the payment window has expired, so the room
        // flips open → awaitingPayment (and the Pay button appears) without a manual refresh.
        expiryCheckTask?.cancel()
        expiryCheckTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                if let booking = self.booking, booking.status == .open, Date() >= booking.paymentDeadline {
                    await self.service.expirePaymentWindowIfNeeded(bookingId: self.bookingId)
                }
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    func stopListening() {
        bookingListener?.remove()
        participantsListener?.remove()
        messagesListener?.remove()
        bookingListener = nil
        participantsListener = nil
        messagesListener = nil
        expiryCheckTask?.cancel()
        expiryCheckTask = nil
    }

    func sendMessage(text: String, sender: UserEntity) async {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        do {
            try await service.sendMessage(bookingId: bookingId, sender: sender, text: text)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func pay(uid: String) async {
        guard let perPlayerCost = booking?.perPlayerCost else { return }
        do {
            try await service.markPaid(bookingId: bookingId, uid: uid, amount: perPlayerCost)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func payHostCoverage(uid: String) async {
        guard let booking else { return }
        let unfilledSpots = booking.totalSpots - participants.count
        let hostAmount = booking.perPlayerCost + (Double(unfilledSpots) * booking.perPlayerCost)
        do {
            try await service.markPaid(bookingId: bookingId, uid: uid, amount: hostAmount)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancel() async {
        guard let id = booking?.id else { return }
        do {
            try await service.cancelBooking(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func isHost(uid: String) -> Bool {
        booking?.hostId == uid
    }

    func hasUserPaid(uid: String) -> Bool {
        participants.first(where: { $0.uid == uid })?.hasPaid ?? false
    }
}
