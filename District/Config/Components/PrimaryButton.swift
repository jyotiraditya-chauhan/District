//
//  PrimaryButton.swift
//  District
//
//  The app's single primary CTA: a white pill button with black text,
//  per the design system's "accent reserved for trust/offers only" rule.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.cta)
                .foregroundStyle(AppColors.ctaText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(AppColors.ctaBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.cta, style: .continuous))
        }
    }
}

#Preview {
    PrimaryButton(title: "Get Started", action: {})
        .padding()
        .background(AppColors.background)
}
