//
//  AuthView.swift
//  District
//

import SwiftUI

struct AuthView: View {
    @Environment(AuthViewModel.self) private var viewModel

    private let googleLogoURL = URL(string: "https://developers.google.com/identity/images/g-logo.png")

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            VStack(spacing: AppSpacing.sm) {
                Text(AppConfig.appName)
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.primaryText)

                Text("Sign in to continue")
                    .font(AppTypography.secondaryBody)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            VStack(spacing: AppSpacing.sm) {
                CustomButton(title: "Google Sign in", imageURL: googleLogoURL, isLoading: viewModel.isLoading) {
                    Task { await viewModel.signInWithGoogle() }
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(AppTypography.secondaryBody)
                        .foregroundStyle(.red)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

#Preview {
    AuthView()
        .environment(AuthViewModel())
}
