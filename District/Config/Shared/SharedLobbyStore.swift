//
//  SharedLobbyStore.swift
//  District
//

import Foundation

enum SharedLobbyStore {
    static let appGroupId = "group.com.jyotiraditya.district"
    static let widgetKind = "SportLobbyWidget"

    private static let snapshotKey = "widget_lobby_snapshot"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    static func read() -> WidgetLobbySnapshot? {
        guard let data = defaults?.data(forKey: snapshotKey) else { return nil }
        return try? JSONDecoder.shared.decode(WidgetLobbySnapshot.self, from: data)
    }

    static func write(_ snapshot: WidgetLobbySnapshot) {
        guard let data = try? JSONEncoder.shared.encode(snapshot) else { return }
        defaults?.set(data, forKey: snapshotKey)
    }
}

private extension JSONDecoder {
    static let shared: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

private extension JSONEncoder {
    static let shared: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}
