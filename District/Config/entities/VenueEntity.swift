//
//  VenueEntity.swift
//  District
//

import FirebaseFirestore

struct VenueEntity: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var address: String
    var latitude: Double
    var longitude: Double
    var sportsOffered: [String]
    var courtCount: Int
    var imageNames: [String]
    var rating: Double
    var courtType: String = "Outdoor"
    var isDistrictExclusive: Bool = false

    var offerTitle: String? = nil
}
