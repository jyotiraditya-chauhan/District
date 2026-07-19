//
//  FindSportVenueIntent.swift
//  District
//

import AppIntents
import UIKit

enum SiriSportChoice: String, AppEnum {
    case boxCricket, turfFootball, tennis, tableTennis, pickleball, basketball, volleyball, badminton

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Sport"

    static var caseDisplayRepresentations: [SiriSportChoice: DisplayRepresentation] = [
        .boxCricket: "Box Cricket",
        .turfFootball: "Turf Football",
        .tennis: "Tennis",
        .tableTennis: "Table Tennis",
        .pickleball: "Pickleball",
        .basketball: "Basketball",
        .volleyball: "Volleyball",
        .badminton: "Badminton"
    ]
    
    var sportName: String {
        switch self {
        case .boxCricket: "Box Cricket"
        case .turfFootball: "Turf Football"
        case .tennis: "Tennis"
        case .tableTennis: "Table Tennis"
        case .pickleball: "Pickleball"
        case .basketball: "Basketball"
        case .volleyball: "Volleyball"
        case .badminton: "Badminton"
        }
    }
}

struct FindSportVenueIntent: AppIntent {
    static var title: LocalizedStringResource = "Find Sport Venues"
    static var description = IntentDescription("Find venues for a specific sport.")
    
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Sport", default: .boxCricket)
    var sport: SiriSportChoice

    @MainActor
    func perform() async throws -> some IntentResult {
        let name = sport.sportName
        let deepLinkUrl = WidgetDeepLink.create(sportName: name).url
        
        UIApplication.shared.open(deepLinkUrl, options: [:], completionHandler: nil)
        
        return .result()
    }
}
