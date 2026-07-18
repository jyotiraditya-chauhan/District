//
//  BookingEntity.swift
//  District
//

import FirebaseFirestore

struct BookingEntity: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var gameId: String
    var hostId: String
    var participantIds: [String]
    var startDate: Date
    var totalSpots: Int
    var pricePerPerson: Double
    var isPublic: Bool
    var inviteCode: String
    var status: BookingStatus
    var createdAt: Date
}

enum BookingStatus: String, Codable {
    case open
    case locked
    case confirmed
    case cancelled
}
