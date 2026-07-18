//
//  AuthViewModel.swift
//  District
//

import Foundation

@Observable
@MainActor
final class AuthViewModel {
    var currentUser: UserEntity?
    var isLoading = false
    var errorMessage: String?

    private let service = AuthService()

    func restoreSession() async {
        currentUser = await service.restoreSession()
    }

    func signInWithGoogle() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            currentUser = try await service.signInWithGoogle()
        } catch let authError as AuthError {
            if case .cancelled = authError { return }
            errorMessage = authError.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        service.signOut()
        currentUser = nil
    }
}
