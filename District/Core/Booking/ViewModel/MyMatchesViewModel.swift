//
//  MyMatchesViewModel.swift
//  District
//

import Foundation
import FirebaseFirestore

@Observable
@MainActor
final class MyMatchesViewModel {
    private let service = BookingService()

    var bookings: [BookingEntity] = []
    var isLoading = true

    private var listener: ListenerRegistration?

    func startObserving(uid: String) {
        isLoading = true
        listener = service.observeMyBookings(uid: uid) { [weak self] list in
            Task { @MainActor in
                self?.bookings = list
                self?.isLoading = false
            }
        }
    }

    func stopObserving() {
        listener?.remove()
        listener = nil
    }
}
