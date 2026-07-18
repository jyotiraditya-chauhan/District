//
//  SportCatalog.swift
//  District
//

import Foundation

struct SportInfo: Identifiable, Sendable, Hashable {
    let id: String
    let displayName: String
    let iconAsset: String
    let symbol: String
}

enum SportCatalog {
    static let all: [SportInfo] = [
        SportInfo(id: "box_cricket", displayName: "Box Cricket", iconAsset: "icon_cricket", symbol: "figure.cricket"),
        SportInfo(id: "turf_football", displayName: "Turf Football", iconAsset: "icon_football", symbol: "soccerball"),
        SportInfo(id: "tennis", displayName: "Tennis", iconAsset: "icon_tennis", symbol: "figure.tennis"),
        SportInfo(id: "table_tennis", displayName: "Table Tennis", iconAsset: "icon_tabletennis", symbol: "figure.table.tennis"),
        SportInfo(id: "pickleball", displayName: "Pickleball", iconAsset: "icon_pickleball", symbol: "figure.pickleball"),
        SportInfo(id: "basketball", displayName: "Basketball", iconAsset: "icon_basketball", symbol: "basketball.fill"),
        SportInfo(id: "volleyball", displayName: "Volleyball", iconAsset: "icon_volleyball", symbol: "volleyball.fill"),
        SportInfo(id: "badminton", displayName: "Badminton", iconAsset: "icon_badminton", symbol: "figure.badminton")
    ]

    static func info(forDisplayName name: String) -> SportInfo? {
        all.first { $0.displayName == name }
    }

    static func info(forId id: String) -> SportInfo? {
        all.first { $0.id == id }
    }
}
