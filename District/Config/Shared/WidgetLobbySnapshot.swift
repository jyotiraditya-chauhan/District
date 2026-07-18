//
//  WidgetLobbySnapshot.swift
//  District
//

import Foundation

struct WidgetLobby: Codable, Sendable, Hashable {
    var bookingId: String
    var sport: String
    var title: String
    var hostName: String
    var slotDateLabel: String
    var slotTimeLabel: String
    var perPlayerCost: Double
    var spotsLeft: Int
    var extraCount: Int
    var startDate: Date
}

struct WidgetLobbySnapshot: Codable, Sendable {
    var isSignedIn: Bool
    var lobbiesBySport: [String: WidgetLobby]
    var updatedAt: Date

    static let signedOut = WidgetLobbySnapshot(isSignedIn: false, lobbiesBySport: [:], updatedAt: Date())

    func lobby(forSport sport: String) -> WidgetLobby? {
        lobbiesBySport[sport]
    }
}
