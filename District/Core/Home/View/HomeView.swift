//
//  PlayHomeScreen.swift
//  district
//
//  The District "Play" home screen (matches provided screenshots).
//

import SwiftUI

struct HomeView: View {
    @Environment(AuthViewModel.self) var authViewModel // Required for signout
    @Environment(AppRouter.self) private var router
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.s5) {
                    Color.clear.frame(height: DS.s1) // Spacing for top

                    customHeader

                    BannerCarousel(banners: viewModel.banners)

                    pickASport

                    playYourGame

                    courtsNearYou

                    Color.clear.frame(height: DS.s5)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Custom Header

    private var customHeader: some View {
        VStack(spacing: DS.s4) {
            HStack(alignment: .center) {
                // Left Side: Location Pin & Info
                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(white: 0.8))

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("Chhatarpur Farms")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(DS.textPrimary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(DS.textPrimary)
                        }
                        Text("DLF Farms, New Delhi")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(DS.textSecondary)
                    }
                }

                Spacer()

                // Right Side: Action Icons
                HStack(spacing: DS.s2) {
                    Button(action: {}) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(DS.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(Color(white: 0.15))
                            .clipShape(Circle())
                    }

                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color(white: 0.15))
                            .frame(width: 44, height: 44)
                            .background(Color(white: 0.7))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 0.6, green: 0.5, blue: 0.9), lineWidth: 2)
                            )
                    }
                }
            }
            .padding(.horizontal, DS.s3)

            // Search Bar
            Button(action: { router.push(.searchPlay) }) {
                SearchPill(placeholder: "Search for 'Pool'")
                    .padding(.horizontal, DS.s3)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, DS.s2)
    }

    // MARK: Pick a sport

    private var pickASport: some View {
        VStack(spacing: DS.s3) {
            SectionHeader(title: "Pick a sport")
            ScrollView(.horizontal, showsIndicators: false) {
                // two-row grid that scrolls horizontally
                LazyHGrid(rows: [GridItem(.fixed(150), spacing: DS.s2),
                                 GridItem(.fixed(150), spacing: DS.s2)],
                          spacing: DS.s2) {
                    ForEach(viewModel.sports) { sport in
                        Button(action: { router.push(.sportVenues(sportName: sport.name)) }) {
                            SportTile(sport: sport)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, DS.s3)
            }
        }
    }

    // MARK: Play your game

    private var playYourGame: some View {
        VStack(spacing: DS.s3) {
            SectionHeader(title: "Play your game")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.s2) {
                    ForEach(viewModel.categories) { PlayCard(category: $0) }
                }
                .padding(.horizontal, DS.s3)
            }
        }
    }

    // MARK: Courts near you

    private var courtsNearYou: some View {
        VStack(spacing: DS.s3) {
            SectionHeader(title: "Badminton courts near you")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.s2) {
                    ForEach(viewModel.nearbyVenues) { VenueCard(venue: $0) }
                }
                .padding(.horizontal, DS.s3)
            }
        }
    }
}

#Preview {
    NavigationStack { HomeView() }
        .environment(AuthViewModel())
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
