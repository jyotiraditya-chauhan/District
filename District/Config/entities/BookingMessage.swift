//
//  BookingMessage.swift
//  District
//

import FirebaseFirestore

struct BookingMessage: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var senderId: String
    var senderName: String
    var text: String
    var sentAt: Date
    var isSystem: Bool
}
