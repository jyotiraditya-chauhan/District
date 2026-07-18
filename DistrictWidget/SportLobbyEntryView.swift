//
//  SportLobbyEntryView.swift
//  DistrictWidget
//

import SwiftUI
import WidgetKit

struct SportLobbyEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SportLobbyEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallLobbyView(entry: entry)
            default:
                MediumLobbyView(entry: entry)
            }
        }
        .containerBackground(AppColors.background, for: .widget)
    }
}

struct SmallLobbyView: View {
    let entry: SportLobbyEntry

    var body: some View {
        if !entry.isSignedIn {
            SignedOutContent(compact: true)
        } else if let lobby = entry.lobby {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: entry.sport.symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
                Text(entry.sport.displayName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(2)
                Spacer(minLength: 4)
                Text("\(lobby.spotsLeft) spots left")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.secondaryText)
                Link(destination: WidgetDeepLink.lobby(bookingId: lobby.bookingId).url) {
                    Text("Join Now")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppColors.ctaText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppColors.ctaBackground, in: Capsule())
                }
            }
            .padding(12)
        } else {
            EmptyLobbyContent(sport: entry.sport, compact: true)
        }
    }
}

struct MediumLobbyView: View {
    let entry: SportLobbyEntry

    var body: some View {
        if !entry.isSignedIn {
            SignedOutContent(compact: false)
        } else if let lobby = entry.lobby {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: entry.sport.symbol)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.accent)
                        Text(lobby.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(AppColors.primaryText)
                            .lineLimit(1)
                    }
                    Text("by \(lobby.hostName)")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.secondaryText)
                    Text("\(lobby.slotDateLabel) · \(lobby.slotTimeLabel)")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.secondaryText)
                    HStack(spacing: 8) {
                        Text("₹\(String(format: "%.0f", lobby.perPlayerCost))/player")
                        Text("·")
                        Text("\(lobby.spotsLeft) left")
                        if lobby.extraCount > 0 {
                            Text("· +\(lobby.extraCount) more")
                        }
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.secondaryText)
                }
                Spacer(minLength: 8)
                Link(destination: WidgetDeepLink.lobby(bookingId: lobby.bookingId).url) {
                    Text("Join Now")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppColors.ctaText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AppColors.ctaBackground, in: Capsule())
                }
            }
            .padding(14)
        } else {
            EmptyLobbyContent(sport: entry.sport, compact: false)
        }
    }
}

private struct SignedOutContent: View {
    let compact: Bool

    var body: some View {
        Link(destination: WidgetDeepLink.home.url) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColors.secondaryText)
                Text("Sign in to see games")
                    .font(.system(size: compact ? 13 : 14, weight: .semibold))
                    .foregroundStyle(AppColors.primaryText)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct EmptyLobbyContent: View {
    let sport: SportInfo
    let compact: Bool

    var body: some View {
        Link(destination: WidgetDeepLink.create(sportName: sport.displayName).url) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: sport.symbol)
                    .font(.system(size: compact ? 20 : 22, weight: .semibold))
                    .foregroundStyle(AppColors.secondaryText)
                Text(sport.displayName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppColors.primaryText)
                Spacer(minLength: 4)
                Text("No game yet — start one")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
