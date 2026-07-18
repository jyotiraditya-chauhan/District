//
//  InvitePlayersSheet.swift
//  District
//
//  Created for District
//

import SwiftUI
import CoreLocation

struct InvitePlayersSheet: View {
    @Environment(\.presentationMode) var presentationMode
    let joinCode: String
    
    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Invite Players")
                        .font(.title3).fontWeight(.bold).foregroundColor(.white)
                    Spacer()
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(DS.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(DS.surface).clipShape(Circle())
                    }
                }
                .padding(.top, 24)
                
                // Match Code
                VStack(alignment: .leading, spacing: 12) {
                    Text("SHARE JOIN CODE")
                        .font(.caption).fontWeight(.bold).foregroundColor(DS.textSecondary)
                    
                    HStack {
                        Image(systemName: "number.square.fill").foregroundColor(DS.textSecondary)
                        Text(joinCode)
                            .font(.title2).fontWeight(.black).foregroundColor(.white)
                            .tracking(2)
                            .lineLimit(1)
                        Spacer()
                        Button {
                            UIPasteboard.general.string = joinCode
                        } label: {
                            Text("Copy")
                                .font(.caption).fontWeight(.bold).foregroundColor(.black)
                                .padding(.horizontal, 14).padding(.vertical, 7)
                                .background(Color.white).cornerRadius(10)
                        }
                    }
                    .padding(14)
                    .background(DS.surface).cornerRadius(14)
                    
                    HStack(spacing: 14) {
                        shareOption(icon: "message.fill", label: "iMessage", color: Color.green)
                        shareOption(icon: "paperplane.fill", label: "WhatsApp", color: Color(red: 37/255, green: 211/255, blue: 102/255))
                        shareOption(icon: "square.and.arrow.up.fill", label: "More", color: DS.textSecondary)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, DS.s3)
        }
    }
    
    private func shareOption(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.8)).cornerRadius(14)
            Text(label).font(.caption2).foregroundColor(DS.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
