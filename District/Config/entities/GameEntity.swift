//
//  GameEntity.swift
//  District
//

import FirebaseFirestore

struct GameEntity: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var venueId: String
    var name: String
    var description: String
    var sport: String
    var pricePerPerson: Double
    var durationMinutes: Int
    var rating: Double
    /// Display-only recurring slot start times shown as chips (e.g. "6:00 AM").
    var availableTimes: [String] = []
}
