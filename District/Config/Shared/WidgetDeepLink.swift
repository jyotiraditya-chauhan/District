//
//  WidgetDeepLink.swift
//  District
//

import Foundation

enum WidgetDeepLink: Equatable {
    case lobby(bookingId: String)
    case create(sportName: String)
    case home

    static let scheme = "district"

    var url: URL {
        switch self {
        case .lobby(let bookingId):
            return URL(string: "\(Self.scheme)://lobby/\(bookingId)")!
        case .create(let sportName):
            let encoded = sportName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? sportName
            return URL(string: "\(Self.scheme)://create/\(encoded)")!
        case .home:
            return URL(string: "\(Self.scheme)://home")!
        }
    }

    init?(url: URL) {
        guard url.scheme == Self.scheme else { return nil }
        let host = url.host
        let value = url.pathComponents.first { $0 != "/" }
        switch host {
        case "lobby":
            guard let id = value else { return nil }
            self = .lobby(bookingId: id)
        case "create":
            guard let raw = value else { return nil }
            self = .create(sportName: raw.removingPercentEncoding ?? raw)
        case "home":
            self = .home
        default:
            return nil
        }
    }
}
