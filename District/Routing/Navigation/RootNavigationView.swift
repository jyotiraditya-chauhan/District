//
//  RootNavigationView.swift
//  District
//

import SwiftUI

struct RootNavigationView: View {
    @State private var router = AppRouter()
    var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                if authViewModel.currentUser != nil {
                    HomeView()
                } else {
                    AuthView()
                }
            }
            .environment(router)
            .environment(authViewModel)
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
                    .environment(router)
                    .environment(authViewModel)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .auth:
            AuthView()
        case .home:
            HomeView()
        case .searchPlay:
            SearchPlayView()
        case .sportVenues(let sportName):
            SportVenuesView(sportName: sportName)
        case .venueDetail(let venue):
            VenueDetailView(venue: venue)
        case .bookSlot(let venue):
            BookSlotView(venue: venue)
        case .matchSetup(let venue, let date, let time, let duration, let turfName, let totalCost):
            MatchSetupView(venue: venue, date: date, time: time, duration: duration, turfName: turfName, totalCost: totalCost)
        case .reviewBooking(let venue, let date, let time, let duration, let matchType, let totalPlayers, let totalCost, let skillLevel, let paymentWindow):
            ReviewBookingView(venue: venue, date: date, time: time, duration: duration, matchType: matchType, totalPlayers: totalPlayers, totalCost: totalCost, skillLevel: skillLevel, paymentWindow: paymentWindow)
        case .matchRoom(let venue, let date, let time, let matchType, let totalPlayers, let perPlayerCost, let totalCost, let skillLevel):
            MatchRoomView(venue: venue, date: date, time: time, matchType: matchType, totalPlayers: totalPlayers, perPlayerCost: perPlayerCost, totalCost: totalCost, skillLevel: skillLevel)
        }
    }
}

#Preview {
    RootNavigationView(authViewModel: AuthViewModel())
}
