//
//  SportLobbyWidget.swift
//  DistrictWidget
//

import WidgetKit
import SwiftUI

struct SportLobbyWidget: Widget {
    let kind: String = SharedLobbyStore.widgetKind

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SportSelectionIntent.self, provider: SportLobbyProvider()) { entry in
            SportLobbyEntryView(entry: entry)
        }
        .configurationDisplayName("District Game")
        .description("See if a game is open for your sport and join in one tap.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
