//
//  DataManager.swift
//  District
//

import Foundation
import Combine
import CoreLocation
import FirebaseFirestore

final class DataManager: ObservableObject {

    static let shared = DataManager()

    @Published private(set) var venues: [VenueEntity] = []
    @Published private(set) var games: [GameEntity] = []
    @Published private(set) var sports: [Sport] = []

    private init() {
        seedMockData()
    }

    func games(forVenue venueId: String) -> [GameEntity] {
        games.filter { $0.venueId == venueId }
    }

    func venue(for id: String) -> VenueEntity? {
        venues.first { $0.id == id }
    }

    func venues(forSport sport: String) -> [VenueEntity] {
        venues.filter { $0.sportsOffered.contains(sport) }
    }

    func games(forSport sport: String) -> [GameEntity] {
        games.filter { $0.sport == sport }
    }

    /// Cheapest listed price across a venue's games; nil if it has none.
    func startingPrice(forVenue venueId: String) -> Double? {
        games(forVenue: venueId).map(\.pricePerPerson).min()
    }

    /// Fixed placeholder "current location" (MG Road, Gurugram) — no real location services yet.
    private static let referenceLocation = CLLocation(latitude: 28.4780, longitude: 77.0430)

    /// Distance from the reference location, formatted like "5 km" / "850 m".
    func distanceString(forVenue venue: VenueEntity) -> String {
        let venueLocation = CLLocation(latitude: venue.latitude, longitude: venue.longitude)
        let meters = Self.referenceLocation.distance(from: venueLocation)
        if meters < 1000 {
            return "\(Int(meters)) m"
        }
        return String(format: "%.1f km", meters / 1000)
    }

    private func seedMockData() {
        sports = [
            Sport(name: "Box Cricket", iconAsset: "icon_cricket"),
            Sport(name: "Turf Football", iconAsset: "icon_football"),
            Sport(name: "Tennis", iconAsset: "icon_tennis"),
            Sport(name: "Table Tennis", iconAsset: "icon_tabletennis"),
            Sport(name: "Pickleball", iconAsset: "icon_pickleball"),
            Sport(name: "Basketball", iconAsset: "icon_basketball"),
            Sport(name: "Volleyball", iconAsset: "icon_volleyball"),
            Sport(name: "Badminton", iconAsset: "icon_badminton")
        ]

        let venue1ID = UUID().uuidString
        let venue2ID = UUID().uuidString
        let venue3ID = UUID().uuidString
        let venue4ID = UUID().uuidString
        let venue5ID = UUID().uuidString

        venues = [
            VenueEntity(
                id: venue1ID,
                name: "Smash Arena Sector 45",
                description: "A multi-sport indoor-outdoor complex with floodlit turfs and a dedicated table tennis hall, popular for weekday evening games.",
                address: "Sector 45, Gurugram, Haryana",
                latitude: 28.4489,
                longitude: 77.0714,
                sportsOffered: ["Box Cricket", "Turf Football", "Table Tennis", "Basketball"],
                courtCount: 4,
                imageNames: ["cricket1", "football1", "tennis1", "basketball1"],
                rating: 4.5,
                courtType: "Outdoor",
                isDistrictExclusive: false,
                offerTitle: "20% OFF up to ₹250"
            ),
            VenueEntity(
                id: venue2ID,
                name: "Urban Turf Cyber City",
                description: "Premium synthetic turfs right in the middle of Cyber City, favored by corporate teams for after-work matches.",
                address: "DLF Cyber City, Gurugram, Haryana",
                latitude: 28.4950,
                longitude: 77.0890,
                sportsOffered: ["Turf Football", "Box Cricket", "Volleyball"],
                courtCount: 3,
                imageNames: ["football2", "cricket2", "volleyball1"],
                rating: 4.2,
                courtType: "Rainproof",
                isDistrictExclusive: true,
                offerTitle: "Flat ₹500 OFF"
            ),
            VenueEntity(
                id: venue3ID,
                name: "Ace Court Complex",
                description: "Racket-sports specialist with well-maintained tennis, table tennis, and pickleball courts across a landscaped campus.",
                address: "Golf Course Road, Gurugram, Haryana",
                latitude: 28.4321,
                longitude: 77.1025,
                sportsOffered: ["Tennis", "Table Tennis", "Pickleball", "Badminton"],
                courtCount: 6,
                imageNames: ["tennis2", "tennis1", "banner_pickle", "badminton1"],
                rating: 4.7,
                courtType: "Indoor",
                isDistrictExclusive: false,
                offerTitle: nil
            ),
            VenueEntity(
                id: venue4ID,
                name: "Slam Dunk Sports Hub",
                description: "A basketball-first venue with a full-size court and an adjoining 5-a-side football pitch.",
                address: "MG Road, Gurugram, Haryana",
                latitude: 28.4780,
                longitude: 77.0430,
                sportsOffered: ["Basketball", "Turf Football", "Volleyball"],
                courtCount: 3,
                imageNames: ["basketball2", "football3", "volleyball2"],
                rating: 4.0,
                courtType: "Outdoor",
                isDistrictExclusive: false,
                offerTitle: nil
            ),
            VenueEntity(
                id: venue5ID,
                name: "Greenfield Sporting Club",
                description: "A quieter, greener venue on Sohna Road with cricket nets, pickleball, and tennis courts spread across open grounds.",
                address: "Sohna Road, Gurugram, Haryana",
                latitude: 28.4025,
                longitude: 77.0562,
                sportsOffered: ["Box Cricket", "Pickleball", "Tennis", "Badminton"],
                courtCount: 5,
                imageNames: ["cricket3", "banner_pickle", "tennis3", "badminton2"],
                rating: 4.6,
                courtType: "Outdoor",
                isDistrictExclusive: true,
                offerTitle: nil
            )
        ]

        games = [
            GameEntity(id: UUID().uuidString, venueId: venue1ID, name: "Box Cricket - Turf 1", description: "Fast-paced 6-a-side box cricket on a floodlit synthetic turf.", sport: "Box Cricket", pricePerPerson: 250, durationMinutes: 60, rating: 4.4, availableTimes: ["6:00 AM", "6:30 AM", "7:00 AM", "7:30 AM"]),
            GameEntity(id: UUID().uuidString, venueId: venue1ID, name: "5-a-side Football - Turf 2", description: "Compact 5-a-side football turf with rebound boards.", sport: "Turf Football", pricePerPerson: 200, durationMinutes: 60, rating: 4.3, availableTimes: ["5:00 PM", "6:00 PM", "7:00 PM"]),
            GameEntity(id: UUID().uuidString, venueId: venue1ID, name: "Table Tennis - Court A", description: "Indoor wooden-flooring table tennis court with proper lighting.", sport: "Table Tennis", pricePerPerson: 150, durationMinutes: 45, rating: 4.6, availableTimes: ["8:00 AM", "9:00 AM", "10:00 AM"]),
            GameEntity(id: UUID().uuidString, venueId: venue1ID, name: "Basketball - Court 1", description: "Outdoor basketball court.", sport: "Basketball", pricePerPerson: 200, durationMinutes: 60, rating: 4.2, availableTimes: ["5:00 PM", "6:00 PM"]),

            GameEntity(id: UUID().uuidString, venueId: venue2ID, name: "7-a-side Football - Main Turf", description: "Full-size synthetic turf for 7-a-side football matches.", sport: "Turf Football", pricePerPerson: 300, durationMinutes: 90, rating: 4.1, availableTimes: ["6:00 PM", "7:30 PM"]),
            GameEntity(id: UUID().uuidString, venueId: venue2ID, name: "Box Cricket - Turf 2", description: "Evening box cricket slots with practice nets on the side.", sport: "Box Cricket", pricePerPerson: 280, durationMinutes: 60, rating: 4.2, availableTimes: ["5:30 AM", "6:00 AM", "6:30 AM", "7:00 AM"]),
            GameEntity(id: UUID().uuidString, venueId: venue2ID, name: "Volleyball - Sand Court", description: "Outdoor sand volleyball court.", sport: "Volleyball", pricePerPerson: 150, durationMinutes: 60, rating: 4.0, availableTimes: ["7:00 AM", "8:00 AM"]),

            GameEntity(id: UUID().uuidString, venueId: venue3ID, name: "Tennis - Court 1", description: "Hard-court tennis with ball-boy service on weekends.", sport: "Tennis", pricePerPerson: 400, durationMinutes: 60, rating: 4.8, availableTimes: ["6:00 AM", "7:00 AM"]),
            GameEntity(id: UUID().uuidString, venueId: venue3ID, name: "Table Tennis - Court B", description: "Air-conditioned table tennis court, ideal for competitive singles.", sport: "Table Tennis", pricePerPerson: 180, durationMinutes: 45, rating: 4.5, availableTimes: ["6:00 PM", "7:00 PM", "8:00 PM"]),
            GameEntity(id: UUID().uuidString, venueId: venue3ID, name: "Pickleball - Court 1", description: "Dedicated pickleball court with beginner-friendly coaching on request.", sport: "Pickleball", pricePerPerson: 220, durationMinutes: 60, rating: 4.7, availableTimes: ["8:00 AM", "9:00 AM", "10:00 AM"]),
            GameEntity(id: UUID().uuidString, venueId: venue3ID, name: "Badminton - Court 1", description: "Indoor badminton court.", sport: "Badminton", pricePerPerson: 250, durationMinutes: 60, rating: 4.5, availableTimes: ["6:00 AM", "7:00 AM", "8:00 AM"]),

            GameEntity(id: UUID().uuidString, venueId: venue4ID, name: "Basketball - Full Court", description: "Full-size outdoor basketball court with new hoops and lighting.", sport: "Basketball", pricePerPerson: 200, durationMinutes: 60, rating: 4.3, availableTimes: ["5:00 PM", "6:00 PM"]),
            GameEntity(id: UUID().uuidString, venueId: venue4ID, name: "5-a-side Football - Pitch 1", description: "Compact turf pitch adjoining the basketball court.", sport: "Turf Football", pricePerPerson: 250, durationMinutes: 90, rating: 4.0, availableTimes: ["6:00 PM", "7:30 PM"]),
            GameEntity(id: UUID().uuidString, venueId: venue4ID, name: "Volleyball - Indoor Court", description: "Indoor volleyball court.", sport: "Volleyball", pricePerPerson: 180, durationMinutes: 60, rating: 4.4, availableTimes: ["7:00 PM", "8:00 PM"]),

            GameEntity(id: UUID().uuidString, venueId: venue5ID, name: "Box Cricket - Ground 1", description: "Open-ground box cricket with natural turf and long boundaries.", sport: "Box Cricket", pricePerPerson: 300, durationMinutes: 90, rating: 4.5, availableTimes: ["12:30 AM", "1:00 AM", "1:30 AM"]),
            GameEntity(id: UUID().uuidString, venueId: venue5ID, name: "Pickleball - Court 2", description: "Shaded pickleball court, popular for morning games.", sport: "Pickleball", pricePerPerson: 200, durationMinutes: 60, rating: 4.6, availableTimes: ["7:00 AM", "8:00 AM"]),
            GameEntity(id: UUID().uuidString, venueId: venue5ID, name: "Tennis - Court 2", description: "Clay tennis court with evening floodlights.", sport: "Tennis", pricePerPerson: 350, durationMinutes: 60, rating: 4.7, availableTimes: ["6:00 PM", "7:00 PM"]),
            GameEntity(id: UUID().uuidString, venueId: venue5ID, name: "Badminton - Court 2", description: "Wooden floor badminton court.", sport: "Badminton", pricePerPerson: 250, durationMinutes: 60, rating: 4.5, availableTimes: ["7:00 PM", "8:00 PM"])
        ]
    }
}
