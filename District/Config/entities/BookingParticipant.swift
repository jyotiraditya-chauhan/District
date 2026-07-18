//
//  BookingParticipant.swift
//  District
//

import FirebaseFirestore

struct BookingParticipant: Identifiable, Codable, Equatable, Hashable {
    @DocumentID var id: String?   // == uid
    var uid: String
    var name: String
    var profileImageURL: String?
    var isHost: Bool
    var joinedAt: Date
    var hasPaid: Bool
    var amountPaid: Double
    var team: String?             // "A" / "B" / nil
}
