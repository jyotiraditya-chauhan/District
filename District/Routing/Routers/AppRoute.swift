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
    case matchSetup(venue: BoxVenue, date: String, time: String, duration: Double, turfName: String, totalCost: Double)
    case reviewBooking(venue: BoxVenue, date: String, time: String, duration: Double, matchType: String, totalPlayers: Int, totalCost: Double, skillLevel: String, paymentWindow: Int)
    case matchRoom(venue: BoxVenue, date: String, time: String, matchType: String, totalPlayers: Int, perPlayerCost: Double, totalCost: Double, skillLevel: String)
}
