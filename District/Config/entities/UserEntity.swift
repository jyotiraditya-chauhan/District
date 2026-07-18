//
//  UserEntity.swift
//  District
//

import FirebaseFirestore

struct UserEntity: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var uid: String
    var name: String
    var email: String
    var profileImageURL: String?
    var createdAt: Date
    var lastLogin: Date
}
