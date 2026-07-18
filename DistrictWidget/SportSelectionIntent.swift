//
//  SportSelectionIntent.swift
//  DistrictWidget
//

import AppIntents

enum SportChoice: String, AppEnum {
    case boxCricket, turfFootball, tennis, tableTennis, pickleball, basketball, volleyball, badminton

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Sport"

    static var caseDisplayRepresentations: [SportChoice: DisplayRepresentation] = [
        .boxCricket: "Box Cricket",
        .turfFootball: "Turf Football",
        .tennis: "Tennis",
        .tableTennis: "Table Tennis",
        .pickleball: "Pickleball",
        .basketball: "Basketball",
        .volleyball: "Volleyball",
        .badminton: "Badminton"
    ]

    var sportId: String {
        switch self {
        case .boxCricket: "box_cricket"
        case .turfFootball: "turf_football"
        case .tennis: "tennis"
        case .tableTennis: "table_tennis"
        case .pickleball: "pickleball"
        case .basketball: "basketball"
        case .volleyball: "volleyball"
        case .badminton: "badminton"
        }
    }

    var sportInfo: SportInfo {
        SportCatalog.info(forId: sportId) ?? SportCatalog.all[0]
    }
}

struct SportSelectionIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Sport"
    static var description = IntentDescription("Choose which sport's games this widget shows.")

    @Parameter(title: "Sport", default: .boxCricket)
    var sport: SportChoice
}
