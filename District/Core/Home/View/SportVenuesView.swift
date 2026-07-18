import SwiftUI

enum Theme {
    static let background = Color(red: 19/255, green: 19/255, blue: 21/255)
    static let surface = Color(red: 29/255, green: 29/255, blue: 31/255)
    static let card = Color(red: 44/255, green: 44/255, blue: 46/255)
    static let primaryText = Color(red: 245/255, green: 245/255, blue: 247/255)
    static let secondaryText = Color(red: 161/255, green: 161/255, blue: 168/255)
    static let accent = Color(red: 79/255, green: 151/255, blue: 46/255)
    static let ctaBackground = Color(red: 244/255, green: 244/255, blue: 244/255)
    static let ctaText = Color(red: 20/255, green: 20/255, blue: 20/255)
    static let divider = Color(red: 156/255, green: 162/255, blue: 157/255).opacity(0.3)
    
    // Extracted from screenshots
    static let offerPurple = Color(red: 65/255, green: 29/255, blue: 124/255) 
    static let ratingYellow = Color.yellow
    
    static let radiusLarge: CGFloat = 24
    static let radiusMedium: CGFloat = 16
    static let radiusSmall: CGFloat = 8
}

import Foundation

struct BoxVenue: Identifiable, Hashable, Equatable {
    let id = UUID()
    let venueId: String
    let gameId: String
    let name: String
    let rating: Double
    let distance: String
    let location: String
    let price: Int
    let offerTitle: String?
    let isDistrictExclusive: Bool
    let slots: [BoxTimeSlot]
    let imageNames: [String]
}

struct BoxTimeSlot: Identifiable, Hashable, Equatable {
    let id = UUID()
    let time: String
    let type: String // e.g., "Outdoor"
}

struct SearchPlayCategory: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}

extension BoxVenue {
    static let mocks = [
        BoxVenue(
            venueId: "mock_venue_1",
            gameId: "mock_game_1",
            name: "Elite Cricket",
            rating: 5.0,
            distance: "5 km",
            location: "New Delhi, Delhi/NCR",
            price: 2000,
            offerTitle: "20% OFF up to ₹250",
            isDistrictExclusive: false,
            slots: [
                BoxTimeSlot(time: "06:00 AM", type: "Outdoor"),
                BoxTimeSlot(time: "06:30 AM", type: "Outdoor"),
                BoxTimeSlot(time: "07:00 AM", type: "Outdoor"),
                BoxTimeSlot(time: "07:30 AM", type: "Outdoor")
            ],
            imageNames: ["Box Cricket"]
        ),
        BoxVenue(
            venueId: "mock_venue_2",
            gameId: "mock_game_2",
            name: "ClayGrounds x District Play | Chattarpur",
            rating: 3.3,
            distance: "1.3 km",
            location: "DLF Farms, Delhi/NCR",
            price: 2000,
            offerTitle: "Flat ₹500 OFF",
            isDistrictExclusive: true,
            slots: [
                BoxTimeSlot(time: "05:30 AM", type: "Outdoor"),
                BoxTimeSlot(time: "06:00 AM", type: "Outdoor"),
                BoxTimeSlot(time: "06:30 AM", type: "Outdoor"),
                BoxTimeSlot(time: "07:00 AM", type: "Outdoor")
            ],
            imageNames: ["Box Cricket"]
        )
    ]
}

extension SearchPlayCategory {
    static let mocks = [
        SearchPlayCategory(title: "REPPP-RKT Badminton Arena", subtitle: "Play"),
        SearchPlayCategory(title: "ClayGrounds x District Play", subtitle: "Play"),
        SearchPlayCategory(title: "GoRally x Swerve | Chhattarpur", subtitle: "Play"),
        SearchPlayCategory(title: "ClayGrounds x District Play", subtitle: "Play"),
        SearchPlayCategory(title: "Pickleball XL | MG Road", subtitle: "Play"),
        SearchPlayCategory(title: "Rackonnect Exclusive", subtitle: "Play")
    ]
}


struct DateSelectorView: View {
    let dates = [
        ("Today", "Sun, 19 Jul"),
        ("Tomorrow", "Mon, 20 Jul"),
        ("21 Jul", "Tue"),
        ("22 Jul", "Wed"),
        ("23 Jul", "Thu")
    ]
    
    @State private var selectedIndex = 0
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(0..<dates.count, id: \.self) { index in
                    VStack(spacing: 6) {
                        Text(dates[index].0)
                            .font(.system(size: 16, weight: selectedIndex == index ? .semibold : .medium))
                            .foregroundColor(selectedIndex == index ? Theme.primaryText : Theme.secondaryText)
                        
                        Text(dates[index].1)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(selectedIndex == index ? Theme.primaryText : Theme.secondaryText)
                        
                        Rectangle()
                            .fill(selectedIndex == index ? Theme.primaryText : Color.clear)
                            .frame(height: 2)
                            .padding(.top, 8)
                    }
                    .onTapGesture {
                        withAnimation {
                            selectedIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .overlay(
            Divider().background(Theme.divider),
            alignment: .bottom
        )
    }
}

struct FilterPillsView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Filters Dropdown
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Filters")
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.primaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Theme.divider, lineWidth: 1)
                    )
                }
                
                // Toggle Filter
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(Color.blue.opacity(0.8))
                        Text("Rainproof Turfs")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.primaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Theme.divider, lineWidth: 1)
                    )
                }
                
                // Normal Filter
                Button(action: {}) {
                    Text("Under 5 km")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.primaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Theme.divider, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}


struct BoxVenueCardView: View {
    let venue: BoxVenue
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Image Section
            ZStack(alignment: .top) {
                // Venue Image
                if let imageName = venue.imageNames.first {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(LinearGradient(colors: [Color.green.opacity(0.6), Color.green.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                        .frame(height: 200)
                }
                
                HStack(alignment: .top) {
                    if venue.isDistrictExclusive {
                        Text("DISTRICT EXCLUSIVE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.9))
                            .clipShape(CustomBannerShape())
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(12)
                
                // Price Tag
                VStack(alignment: .trailing) {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("₹\(venue.price)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            Text("onwards")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMedium))
                        .padding(12)
                    }
                }
            }
            
            // Offer Strip
            if let offer = venue.offerTitle {
                HStack(spacing: 6) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 12))
                    Text(offer)
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Theme.offerPurple)
            }
            
            // Details Section
            VStack(alignment: .leading, spacing: 12) {
                Text(venue.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.primaryText)
                
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.ratingYellow)
                    Text(String(format: "%.1f", venue.rating))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.primaryText)
                    
                    Text("|")
                        .foregroundColor(Theme.secondaryText)
                    
                    Text("Google")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.primaryText)
                    
                    Circle()
                        .fill(Theme.secondaryText)
                        .frame(width: 3, height: 3)
                    
                    Text("\(venue.distance) • \(venue.location)")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.secondaryText)
                }
                
                // Slots
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(venue.slots) { slot in
                            VStack(spacing: 4) {
                                Text(slot.time)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Theme.primaryText)
                                Text(slot.type)
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(Theme.secondaryText)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Theme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Theme.divider, lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(16)
            .glassy(in: RoundedRectangle(cornerRadius: Theme.radiusLarge))
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLarge))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

struct CustomBannerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        // Pointy bit at the end
        path.addLine(to: CGPoint(x: rect.maxX - 8, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}


struct SportVenuesView: View {
    let sportName: String
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    
    private var venues: [BoxVenue] {
        DataManager.shared.venues(forSport: sportName).map { entity in
            let games = DataManager.shared.games(forVenue: entity.id ?? "")
            let sportsGames = games.filter { $0.sport == sportName }
            
            let slots = sportsGames.flatMap { game in
                game.availableTimes.map { BoxTimeSlot(time: $0, type: entity.courtType) }
            }.prefix(4)
            
            return BoxVenue(
                venueId: entity.id ?? "",
                gameId: sportsGames.first?.id ?? "",
                name: entity.name,
                rating: entity.rating,
                distance: DataManager.shared.distanceString(forVenue: entity),
                location: entity.address.components(separatedBy: ",").first ?? entity.address,
                price: Int(sportsGames.map(\.pricePerPerson).min() ?? 0),
                offerTitle: entity.offerTitle,
                isDistrictExclusive: entity.isDistrictExclusive,
                slots: Array(slots),
                imageNames: entity.imageNames
            )
        }
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation & Hero
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack {
                        Text(sportName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Theme.primaryText)
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                        Spacer()
                        // Placeholder for cricket stumps illustration
                        Image(systemName: "cricket.ball.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                            .padding(.trailing, 24)
                            .opacity(0.8)
                    }
                    .padding(.bottom, 24)
                }
                .background(
                    LinearGradient(
                        colors: [Color(red: 25/255, green: 40/255, blue: 35/255), Theme.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                )
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        Section {
                            VStack(spacing: 0) {
                                FilterPillsView()
                                
                                ForEach(venues) { venue in
                                    Button {
                                        router.push(.venueDetail(venue: venue))
                                    } label: {
                                        BoxVenueCardView(venue: venue)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        } header: {
                            DateSelectorView()
                                .background(Theme.background)
                        }
                    }
                }
            }
        }
        .navigationTitle(sportName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { router.pop() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.primaryText)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.primaryText)
                }
            }
        }
    }
}

struct SportVenuesView_Previews: PreviewProvider {
    static var previews: some View {
        SportVenuesView(sportName: "Box Cricket")
            .environment(AppRouter())
    }
}
