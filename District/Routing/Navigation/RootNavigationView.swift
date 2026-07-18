//
//  RootNavigationView.swift
//  District
//

import SwiftUI

struct RootNavigationView: View {
    @State private var router = AppRouter()
    var authViewModel: AuthViewModel
    var initialDeepLink: URL? = nil
    @State private var bookingService = BookingService()
    @State private var widgetPublisher: WidgetLobbyPublisher?
    @State private var pendingLobbyId: String?

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
            .environment(bookingService)
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
                    .environment(router)
                    .environment(authViewModel)
                    .environment(bookingService)
            }
        }
        .task {
            configureWidgetPublisher()
            if let initialDeepLink {
                handleDeepLink(initialDeepLink)
            }
        }
        .onChange(of: authViewModel.currentUser?.uid) { _, uid in
            handleAuthChange(signedIn: uid != nil)
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }

    private func configureWidgetPublisher() {
        if widgetPublisher == nil {
            widgetPublisher = WidgetLobbyPublisher(service: bookingService)
        }
        if authViewModel.currentUser != nil {
            widgetPublisher?.start()
        }
    }

    private func handleAuthChange(signedIn: Bool) {
        if signedIn {
            widgetPublisher?.start()
            if let id = pendingLobbyId {
                pendingLobbyId = nil
                router.push(.joinConfirm(bookingId: id))
            }
        } else {
            widgetPublisher?.publishSignedOut()
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard let link = WidgetDeepLink(url: url) else { return }
        let signedIn = authViewModel.currentUser != nil
        switch link {
        case .lobby(let bookingId):
            if signedIn {
                router.push(.joinConfirm(bookingId: bookingId))
            } else {
                pendingLobbyId = bookingId
            }
        case .create(let sportName):
            if signedIn {
                router.push(.sportVenues(sportName: sportName))
            }
        case .home:
            break
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
        case .matchSetup(let venue, let date, let time, let duration, let turfName, let totalCost, let slotStartDate):
            MatchSetupView(venue: venue, date: date, time: time, duration: duration, turfName: turfName, totalCost: totalCost, slotStartDate: slotStartDate)
        case .reviewBooking(let venue, let date, let time, let duration, let matchType, let totalPlayers, let totalCost, let skillLevel, let paymentWindow, let sport, let slotStartDate):
            ReviewBookingView(venue: venue, date: date, time: time, duration: duration, matchType: matchType, totalPlayers: totalPlayers, totalCost: totalCost, skillLevel: skillLevel, paymentWindow: paymentWindow, sport: sport, slotStartDate: slotStartDate)
        case .matchRoom(let bookingId):
            MatchRoomView(bookingId: bookingId)
        case .joinConfirm(let bookingId):
            JoinConfirmView(bookingId: bookingId)
        case .myMatches:
            MyMatchesView()
        case .profile:
            ProfileView()
        }
    }
}

#Preview {
    RootNavigationView(authViewModel: AuthViewModel())
}
