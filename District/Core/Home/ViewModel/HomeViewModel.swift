//
//  HomeViewModel.swift
//  District
//

import Foundation
import SwiftUI

@Observable
final class HomeViewModel {
    let locationLabel = "Chhatarpur Farms"

    let banners: [Banner] = PlayData.banners

    var sports: [Sport] = []

    private(set) var categories: [PlayCategory] = []
    private(set) var nearbyVenues: [NearbyVenue] = []

    private let dataManager: DataManager

    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
        self.sports = dataManager.sports
        buildCategories()
        buildNearbyVenues()
    }

    private func buildCategories() {
        let sportsWithGames = sports.filter { !dataManager.games(forSport: $0.name).isEmpty }

        categories = sportsWithGames.map { sport in
            let venueRows = dataManager.venues(forSport: sport.name).prefix(2).compactMap { venue -> PlayVenue? in
                let slots = dataManager.games(forVenue: venue.id ?? "")
                    .first(where: { $0.sport == sport.name })?
                    .availableTimes ?? []
                guard !slots.isEmpty else { return nil }
                
                let timeSlots = slots.prefix(3).map { TimeSlot(time: $0, tag: venue.courtType) }
                
                return PlayVenue(
                    name: venue.name,
                    distance: dataManager.distanceString(forVenue: venue),
                    area: venue.address.components(separatedBy: ",").first ?? venue.address,
                    iconAsset: sport.iconAsset,
                    tint: AppColors.accent, // Using accent as a default tint
                    slots: Array(timeSlots)
                )
            }

            return PlayCategory(
                title: sport.name,
                subtitle: "slots available today",
                heroIcon: sport.iconAsset,
                gradient: [Color(hex: "1E3A2A"), Color(hex: "121A15")], // Default gradient
                venues: Array(venueRows)
            )
        }
    }

    private func buildNearbyVenues() {
        nearbyVenues = dataManager.venues
            .sorted { $0.rating > $1.rating }
            .prefix(5)
            .map { venue in
                let icon = dataManager.sports.first { venue.sportsOffered.contains($0.name) }?.iconAsset ?? "icon_cricket"
                let price = dataManager.startingPrice(forVenue: venue.id ?? "").map { "₹\(Int($0)) onwards" } ?? "—"
                return NearbyVenue(
                    name: venue.name,
                    area: venue.address.components(separatedBy: ",").first ?? venue.address,
                    rating: String(format: "%.1f", venue.rating),
                    price: price,
                    iconAsset: icon,
                    tint: AppColors.accent, // default tint
                    isExclusive: venue.isDistrictExclusive
                )
            }
    }
}
