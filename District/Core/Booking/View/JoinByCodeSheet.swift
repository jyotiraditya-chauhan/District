//
//  JoinByCodeSheet.swift
//  District
//

import SwiftUI

struct JoinByCodeSheet: View {
    @Environment(AppRouter.self) private var router
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var code = ""
    @State private var viewModel = JoinLobbyViewModel()

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Join with Code")
                        .font(.title3).fontWeight(.bold).foregroundColor(.white)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(DS.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(DS.surface).clipShape(Circle())
                    }
                }
                .padding(.top, 24)

                VStack(alignment: .leading, spacing: 12) {
                    Text("INVITE CODE")
                        .font(.caption).fontWeight(.bold).foregroundColor(DS.textSecondary)

                    HStack {
                        Image(systemName: "ticket").foregroundColor(DS.textSecondary)
                        TextField("e.g. ABC123", text: $code)
                            .foregroundColor(.white)
                            .font(.title3.monospaced())
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .onChange(of: code) { _, newValue in
                                code = String(newValue.uppercased().prefix(6))
                            }
                    }
                    .padding(16)
                    .background(DS.surface)
                    .cornerRadius(16)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption).foregroundColor(.red)
                        .padding(.horizontal, 4)
                }

                Button {
                    Task {
                        guard let user = authViewModel.currentUser else { return }
                        do {
                            let bookingId = try await viewModel.joinByCode(code, user: user)
                            dismiss()
                            router.push(.matchRoom(bookingId: bookingId))
                        } catch {}
                    }
                } label: {
                    HStack {
                        if viewModel.isJoining {
                            ProgressView().tint(.black)
                        } else {
                            Text("Join Match")
                        }
                    }
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(code.count == 6 ? Color.white : Color.white.opacity(0.3))
                    .cornerRadius(24)
                }
                .disabled(code.count != 6 || viewModel.isJoining)

                Spacer()
            }
            .padding(.horizontal, DS.s3)
        }
    }
}
