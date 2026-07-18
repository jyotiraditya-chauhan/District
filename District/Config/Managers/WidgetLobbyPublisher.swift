//
//  WidgetLobbyPublisher.swift
//  District
//

import Foundation
import FirebaseFirestore
import WidgetKit

@Observable
@MainActor
final class WidgetLobbyPublisher {
    private let service: BookingService
    private var listener: ListenerRegistration?

    init(service: BookingService) {
        self.service = service
    }

    func start() {
        guard listener == nil else { return }
        listener = service.observeAllOpenPublicLobbies { [weak self] bookings in
            self?.publish(bookings)
        }
    }

    func stop() {
        listener?.remove()
        listener = nil
    }

    func publishSignedOut() {
        stop()
        SharedLobbyStore.write(.signedOut)
        reloadWidgets()
    }

    private func publish(_ bookings: [BookingEntity]) {
        let grouped = Dictionary(grouping: bookings, by: { $0.sport })

        var lobbiesBySport: [String: WidgetLobby] = [:]
        for (sport, group) in grouped {
            let sorted = group.sorted { $0.startDate < $1.startDate }
            guard let soonest = sorted.first, let id = soonest.id else { continue }

            lobbiesBySport[sport] = WidgetLobby(
                bookingId: id,
                sport: sport,
                title: soonest.title ?? "\(sport) Match",
                hostName: soonest.hostName,
                slotDateLabel: soonest.slotDateLabel,
                slotTimeLabel: soonest.slotTimeLabel,
                perPlayerCost: soonest.perPlayerCost,
                spotsLeft: max(0, soonest.totalSpots - soonest.participantIds.count),
                extraCount: max(0, sorted.count - 1),
                startDate: soonest.startDate
            )
        }

        let snapshot = WidgetLobbySnapshot(
            isSignedIn: true,
            lobbiesBySport: lobbiesBySport,
            updatedAt: Date()
        )
        SharedLobbyStore.write(snapshot)
        reloadWidgets()
    }

    private func reloadWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: SharedLobbyStore.widgetKind)
    }
}
