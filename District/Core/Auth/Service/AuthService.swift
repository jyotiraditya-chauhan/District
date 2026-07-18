//
//  AuthService.swift
//  District
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

enum AuthError: LocalizedError, Equatable {
    case cancelled
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .cancelled: "Sign in was cancelled."
        case .unknown(let message): message
        }
    }
}

@Observable
@MainActor
final class AuthService {
    private var auth: Auth { Auth.auth() }
    private var db: Firestore { Firestore.firestore() }

    func signInWithGoogle() async throws -> UserEntity {
        guard let rootVC = rootViewController() else {
            throw AuthError.unknown("Unable to present Google Sign In.")
        }
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.unknown("Google ID token missing.")
            }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            let authResult = try await auth.signIn(with: credential)
            return try await fetchOrCreateUser(
                uid: authResult.user.uid,
                name: result.user.profile?.name ?? authResult.user.displayName ?? "",
                email: result.user.profile?.email ?? authResult.user.email ?? "",
                profileImageURL: result.user.profile?.imageURL(withDimension: 200)?.absoluteString
            )
        } catch let error as NSError {
            if let gidError = error as? GIDSignInError, gidError.code == .canceled {
                throw AuthError.cancelled
            }
            throw AuthError.unknown(error.localizedDescription)
        }
    }

    func restoreSession() async -> UserEntity? {
        guard let firebaseUser = auth.currentUser else { return nil }
        return try? await fetchOrCreateUser(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? "",
            email: firebaseUser.email ?? "",
            profileImageURL: firebaseUser.photoURL?.absoluteString
        )
    }

    func signOut() {
        try? auth.signOut()
        GIDSignIn.sharedInstance.signOut()
    }

    private func fetchOrCreateUser(
        uid: String,
        name: String,
        email: String,
        profileImageURL: String?
    ) async throws -> UserEntity {
        let ref = db.collection(Constants.usersCollectionPath).document(uid)
        let snapshot = try await ref.getDocument()

        if var user = try? snapshot.data(as: UserEntity.self) {
            user.lastLogin = Date()
            try? ref.setData(from: user, merge: true)
            return user
        }

        let now = Date()
        let user = UserEntity(
            id: uid,
            uid: uid,
            name: name,
            email: email,
            profileImageURL: profileImageURL,
            createdAt: now,
            lastLogin: now
        )
        try ref.setData(from: user)
        return user
    }

    private func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.keyWindow?
            .rootViewController
    }
}
