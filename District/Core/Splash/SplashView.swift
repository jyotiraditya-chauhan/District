//
//  SplashView.swift
//  District
//

import SwiftUI

struct SplashView: View {
    var authViewModel: AuthViewModel
    var onFinished: () -> Void

    var body: some View {
        VStack {
            Text(AppConfig.appName)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .task {
            async let sessionCheck: Void = authViewModel.restoreSession()
            try? await Task.sleep(for: .seconds(Constants.splashDelaySeconds))
            _ = await sessionCheck
            onFinished()
        }
    }
}

#Preview {
    SplashView(authViewModel: AuthViewModel(), onFinished: {})
}
