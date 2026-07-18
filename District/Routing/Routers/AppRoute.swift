//
//  AppRoute.swift
//  District
//

import Foundation

enum AppRoute: Hashable {
    case auth
    case home
    case searchPlay
    case sportVenues(sportName: String)
    case venueDetail(venue: BoxVenue)
    case bookSlot(venue: BoxVenue)
    case matchSetup(venue: BoxVenue, date: String, time: String, duration: Double, turfName: String, totalCost: Double, slotStartDate: Date)
    case reviewBooking(venue: BoxVenue, date: String, time: String, duration: Double, matchType: String, totalPlayers: Int, totalCost: Double, skillLevel: String, paymentWindow: Int, sport: String, slotStartDate: Date)
    case matchRoom(bookingId: String)
    case joinConfirm(bookingId: String)
    case myMatches
    case profile
}
