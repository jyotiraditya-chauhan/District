//
//  SportLobbyProvider.swift
//  DistrictWidget
//

import WidgetKit

struct SportLobbyEntry: TimelineEntry {
    let date: Date
    let sport: SportInfo
    let isSignedIn: Bool
    let lobby: WidgetLobby?
}

struct SportLobbyProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SportLobbyEntry {
        SportLobbyEntry(date: Date(), sport: SportCatalog.all[0], isSignedIn: true, lobby: nil)
    }

    func snapshot(for configuration: SportSelectionIntent, in context: Context) async -> SportLobbyEntry {
        entry(for: configuration)
    }

    func timeline(for configuration: SportSelectionIntent, in context: Context) async -> Timeline<SportLobbyEntry> {
        let entry = entry(for: configuration)
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        return Timeline(entries: [entry], policy: .after(refreshDate))
    }

    private func entry(for configuration: SportSelectionIntent) -> SportLobbyEntry {
        let sportInfo = configuration.sport.sportInfo
        let snapshot = SharedLobbyStore.read()
        return SportLobbyEntry(
            date: Date(),
            sport: sportInfo,
            isSignedIn: snapshot?.isSignedIn ?? false,
            lobby: snapshot?.lobby(forSport: sportInfo.displayName)
        )
    }
}
