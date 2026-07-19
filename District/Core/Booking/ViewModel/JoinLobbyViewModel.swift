//
//  JoinLobbyViewModel.swift
//  District
//

import Foundation
import FirebaseFirestore

@Observable
@MainActor
final class JoinLobbyViewModel {
    private let service = BookingService()

    var publicLobbies: [BookingEntity] = []
    var isJoining = false
    var errorMessage: String?

    private var lobbiesListener: ListenerRegistration?

    func startObservingLobbies(venueId: String) {
        lobbiesListener = service.observePublicLobbies(venueId: venueId) { [weak self] lobbies in
            Task { @MainActor in
                self?.publicLobbies = lobbies
            }
        }
    }

    func stopObservingLobbies() {
        lobbiesListener?.remove()
        lobbiesListener = nil
    }

    func fetchBookingIdByCode(_ code: String) async throws -> String {
        isJoining = true
        defer { isJoining = false }
        errorMessage = nil
        do {
            let bookingId = try await service.fetchBookingIdByCode(code)
            return bookingId
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func joinBooking(id: String, user: UserEntity) async throws {
        isJoining = true
        defer { isJoining = false }
        errorMessage = nil
        do {
            try await service.joinBooking(id: id, user: user)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
}
