//
//  BookingEntity.swift
//  District
//

import FirebaseFirestore

struct BookingEntity: Identifiable, Codable, Equatable {
    @DocumentID var id: String?

    // Stable refs into DataManager
    var venueId: String
    var gameId: String

    // Display snapshot (denormalized — venues/games are hard-coded & stable)
    var venueName: String
    var venueImageName: String?
    var venueAddress: String
    var sport: String
    var turfName: String

    // Host
    var hostId: String
    var hostName: String

    // Schedule
    var slotDateLabel: String        // "Sun, 19 Jul"
    var slotTimeLabel: String        // "6:00 AM"
    var startDate: Date
    var durationHours: Double

    // Match config
    var isPublic: Bool
    var title: String?
    var matchType: String            // "Public" / "Private"
    var skillLevel: String
    var ageGroup: String?
    var rules: String?

    // Capacity & cost
    var totalSpots: Int
    var totalCost: Double
    var perPlayerCost: Double
    var platformFee: Double

    // Invite
    var inviteCode: String           // 6-char uppercase

    // Denormalized participant IDs (for arrayContains queries + spot-count)
    var participantIds: [String]

    // Payment window
    // (Removed payment window logic: host pays upfront, participants pay to join)

    // Status
    var status: BookingStatus
    var createdAt: Date
}

enum BookingStatus: String, Codable {
    case open
    case confirmed
    case cancelled
}
