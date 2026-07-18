//
//  PlayModels.swift
//  district
//
//  Data models + sample data for the Play home screen.
//

import SwiftUI

// MARK: - Sport

struct Sport: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let iconAsset: String
}

// MARK: - Banner

struct Banner: Identifiable, Hashable {
    let id = UUID()
    let imageAsset: String
}

// MARK: - Time slot chip

struct TimeSlot: Identifiable, Hashable {
    let id = UUID()
    let time: String
    let tag: String   // e.g. "Rainproof"
}

// MARK: - Venue row inside a "Play your game" card

struct PlayVenue: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let distance: String
    let area: String
    let iconAsset: String       // placeholder thumbnail icon
    let tint: Color
    let slots: [TimeSlot]
}

// MARK: - "Play your game" card

struct PlayCategory: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let heroIcon: String
    let gradient: [Color]
    let venues: [PlayVenue]
}

// MARK: - Nearby court card

struct NearbyVenue: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let area: String
    let rating: String
    let price: String
    let iconAsset: String
    let tint: Color
    let isExclusive: Bool
}

// MARK: - Sample data

enum PlayData {
    static let banners: [Banner] = [
        Banner(imageAsset: "banner_rainproof"),
        Banner(imageAsset: "banner_pickle"),
        Banner(imageAsset: "banner_play")
    ]

    static let sports: [Sport] = [
        Sport(name: "Pickleball",    iconAsset: "icon_pickleball"),
        Sport(name: "Table Tennis",  iconAsset: "icon_tabletennis"),
        Sport(name: "Tennis",        iconAsset: "icon_tennis"),
        Sport(name: "Box Cricket",   iconAsset: "icon_cricket"),
        Sport(name: "Turf Football", iconAsset: "icon_football"),
        Sport(name: "Basketball",    iconAsset: "icon_basketball"),
        Sport(name: "Volleyball",    iconAsset: "icon_volleyball"),
        Sport(name: "Snooker",       iconAsset: "icon_snooker")
    ]

    static let categories: [PlayCategory] = [
        PlayCategory(
            title: "Cricket",
            subtitle: "slots available today",
            heroIcon: "icon_cricket",
            gradient: [Color(hex: "1E3A2A"), Color(hex: "121A15")],
            venues: [
                PlayVenue(name: "GoRally x Swerve | Chhattarp...", distance: "1.3 km", area: "DLF Farms",
                          iconAsset: "icon_cricket", tint: Color(hex: "4F972E"),
                          slots: [TimeSlot(time: "12:30 AM", tag: "Rainproof"),
                                  TimeSlot(time: "1 AM", tag: "Rainproof"),
                                  TimeSlot(time: "1:30 AM", tag: "Rainproof")]),
                PlayVenue(name: "Olympic Tennis and Badmint...", distance: "5.7 km", area: "Ghitorni",
                          iconAsset: "icon_tennis", tint: Color(hex: "3A6EA5"),
                          slots: [TimeSlot(time: "5 AM", tag: "Rainproof"),
                                  TimeSlot(time: "6 AM", tag: "Rainproof"),
                                  TimeSlot(time: "7 AM", tag: "Rainproof")])
            ]),
        PlayCategory(
            title: "Pickleball",
            subtitle: "slots available today",
            heroIcon: "icon_pickleball",
            gradient: [Color(hex: "203040"), Color(hex: "12171C")],
            venues: [
                PlayVenue(name: "Smash Arena | Sultanpur", distance: "2.1 km", area: "Sultanpur",
                          iconAsset: "icon_pickleball", tint: Color(hex: "3A6EA5"),
                          slots: [TimeSlot(time: "8 AM", tag: "Indoor"),
                                  TimeSlot(time: "9 AM", tag: "Indoor"),
                                  TimeSlot(time: "10 AM", tag: "Indoor")]),
                PlayVenue(name: "The Rally Club | Chhatarpur", distance: "3.4 km", area: "Chhatarpur",
                          iconAsset: "icon_tabletennis", tint: Color(hex: "C1443B"),
                          slots: [TimeSlot(time: "6 PM", tag: "Indoor"),
                                  TimeSlot(time: "7 PM", tag: "Indoor"),
                                  TimeSlot(time: "8 PM", tag: "Indoor")])
            ])
    ]

    static let nearby: [NearbyVenue] = [
        NearbyVenue(name: "GoRally x Swerve", area: "DLF Farms", rating: "4.8", price: "₹1,200",
                    iconAsset: "icon_cricket", tint: Color(hex: "1E3A2A"), isExclusive: true),
        NearbyVenue(name: "Olympic Courts", area: "Ghitorni", rating: "4.6", price: "₹900",
                    iconAsset: "icon_tennis", tint: Color(hex: "203040"), isExclusive: false),
        NearbyVenue(name: "Smash Arena", area: "Sultanpur", rating: "4.9", price: "₹1,500",
                    iconAsset: "icon_pickleball", tint: Color(hex: "2A2440"), isExclusive: true)
    ]
}
