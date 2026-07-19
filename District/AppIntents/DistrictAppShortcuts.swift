//
//  DistrictAppShortcuts.swift
//  District
//

import AppIntents

struct DistrictAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FindSportVenueIntent(),
            phrases: [
                "Find \(.applicationName) venues",
                "Find open \(.applicationName) venues for \(\.$sport)",
                "Find \(\.$sport) game on \(.applicationName)",
                "Search \(\.$sport) venues in \(.applicationName)"
            ],
            shortTitle: "Find Sport Venues",
            systemImageName: "sportscourt"
        )
    }
}
