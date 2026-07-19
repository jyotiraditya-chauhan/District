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


    }

    func stopListening() {
        bookingListener?.remove()
        participantsListener?.remove()
        messagesListener?.remove()
        bookingListener = nil
        participantsListener = nil
        messagesListener = nil
    }

    func sendMessage(text: String, sender: UserEntity) async {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        do {
            try await service.sendMessage(bookingId: bookingId, sender: sender, text: text)
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
