//
//  ProfileView.swift
//  District
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    private var user: UserEntity? { authViewModel.currentUser }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.s4) {
                    profileHeader
                        .padding(.top, DS.s3)

                    VStack(spacing: 0) {
                        Button(action: { router.push(.myMatches) }) {
                            HStack(spacing: 14) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .frame(width: 20)

                                Text("History")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(DS.textSecondary)
                            }
                            .padding(16)
                        }
                    }
                    .background(DS.surface)
                    .cornerRadius(16)
                    .padding(.horizontal, DS.s3)

                    Button(action: {
                        authViewModel.signOut()
                        router.popToRoot()
                    }) {
                        Text("Log out")
                            .font(.subheadline).fontWeight(.bold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, DS.s3)
                    .padding(.top, DS.s2)

                    Color.clear.frame(height: 40)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(DS.card)
                .frame(width: 84, height: 84)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 34))
                        .foregroundColor(DS.textSecondary)
                )
                .overlay(Circle().stroke(DS.accent, lineWidth: 2))

            VStack(spacing: 4) {
                Text(user?.name.isEmpty == false ? user!.name : "District Player")
                    .font(.title3).fontWeight(.bold)
                    .foregroundColor(.white)

                if let email = user?.email, !email.isEmpty {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(DS.textSecondary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { ProfileView() }
        .environment(AppRouter())
        .environment(AuthViewModel())
        .preferredColorScheme(.dark)
}
