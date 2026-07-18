//
//  CustomButton.swift
//  District
//
//  White, glass-tinted pill button — 54pt tall with a 60pt corner radius.
//

import SwiftUI

struct CustomButton: View {
    let title: String
    var imageURL: URL? = nil
    var isLoading: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                HStack(spacing: AppSpacing.sm) {
                    if let imageURL {
                        AsyncImage(url: imageURL) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 20, height: 20)
                    }

                    Text(title)
                        .font(AppTypography.button)
                        .foregroundStyle(AppColors.ctaText)
                }
                .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .tint(AppColors.ctaText)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
        }
        .disabled(isLoading)
        .modifier(GlassOrFallbackBackground())
    }
}

private struct GlassOrFallbackBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.tint(.white), in: .rect(cornerRadius: AppRadius.customButton))
        } else {
            content
                .background(Color.white, in: .rect(cornerRadius: AppRadius.customButton))
        }
    }
}

#Preview {
    CustomButton(title: "Get Started", action: {})
        .padding()
        .background(AppColors.background)
}
