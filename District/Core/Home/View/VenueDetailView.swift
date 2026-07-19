import SwiftUI
import FirebaseFirestore

struct VenueDetailView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.presentationMode) var presentationMode
    @Environment(BookingService.self) private var bookingService
    @Environment(AuthViewModel.self) private var authViewModel

    let venue: BoxVenue

    // For scroll tracking
    @State private var scrollOffset: CGFloat = 0

    @State private var publicLobbies: [BookingEntity] = []
    @State private var lobbiesListener: ListenerRegistration?
    @State private var showJoinCodeSheet = false

    /// Hide lobbies whose payment window has already lapsed, and ones the
    /// current user already hosts or has joined — nothing left to do there.
    private var joinablePublicLobbies: [BookingEntity] {
        let uid = authViewModel.currentUser?.uid
        return publicLobbies.filter { lobby in
            guard lobby.status == .open else { return false }
            guard lobby.hostId != uid else { return false }
            if let uid, lobby.participantIds.contains(uid) { return false }
            return true
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            DS.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero Image
                    GeometryReader { geo in
                        let minY = geo.frame(in: .global).minY
                        let height = max(300, 300 + minY)
                        
                        TabView {
                            if venue.imageNames.isEmpty {
                                Rectangle()
                                    .fill(DS.surface)
                                    .frame(width: geo.size.width, height: height)
                            } else {
                                ForEach(venue.imageNames, id: \.self) { imageName in
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geo.size.width, height: height)
                                        .clipped()
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(width: geo.size.width, height: height)
                        .offset(y: minY > 0 ? -minY : 0)
                        .overlay(
                            LinearGradient(
                                colors: [Color.clear, DS.background],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                            .offset(y: minY > 0 ? -minY : 0)
                        )
                    }
                    .frame(height: 300)
                    
                    // Main Content
                    VStack(alignment: .leading, spacing: DS.s4) {
                        // Title & Rating
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: DS.s1) {
                                Text(venue.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("\(venue.distance) • H.N.148, CH.ARJUN SINGH MRKT, Ghitorni, New Delhi, Delhi, 110030, India")
                                    .font(.subheadline)
                                    .foregroundColor(DS.textSecondary)
                                    .lineSpacing(4)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                HStack(spacing: 2) {
                                    Text(String(format: "%.1f", venue.rating))
                                        .fontWeight(.bold)
                                    Image(systemName: "star.fill")
                                        .font(.caption2)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 50/255, green: 130/255, blue: 60/255))
                                .cornerRadius(8)
                                
                                Text("Google")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("18 ratings")
                                    .font(.system(size: 9))
                                    .foregroundColor(DS.textSecondary)
                            }
                        }
                        .padding(.horizontal, DS.s3)
                        
                        // Action Buttons
                        HStack(spacing: DS.s2) {
                            Button(action: {}) {
                                HStack {
                                    Text("Directions")
                                    Image(systemName: "arrow.turn.up.right")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(DS.surface)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text("Been here?")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(DS.surface)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, DS.s3)
                        
                        // Sports Available
                        VStack(alignment: .leading, spacing: DS.s2) {
                            Text("3 SPORTS AVAILABLE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(DS.textSecondary)
                                .padding(.horizontal, DS.s3)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: DS.s2) {
                                    SportPill(icon: "cricket.ball", title: "Box Cricket", isSelected: true)
                                    SportPill(icon: "square.grid.3x3", title: "Cricket Nets", isSelected: false)
                                    SportPill(icon: "soccerball", title: "Turf Football", isSelected: false)
                                }
                                .padding(.horizontal, DS.s3)
                            }
                        }
                        
                        // Public Lobbies
                        if !joinablePublicLobbies.isEmpty {
                            VStack(alignment: .leading, spacing: DS.s2) {
                                Text("PUBLIC MATCHES")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(DS.textSecondary)
                                    .padding(.horizontal, DS.s3)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: DS.s2) {
                                        ForEach(joinablePublicLobbies) { lobby in
                                            PublicLobbyCard(booking: lobby) {
                                                router.push(.joinConfirm(bookingId: lobby.id ?? ""))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, DS.s3)
                                }
                            }
                        }

                        // Join a private match with a code
                        VStack(alignment: .leading, spacing: DS.s2) {
                            Button(action: { showJoinCodeSheet = true }) {
                                HStack(spacing: DS.s2) {
                                    Image(systemName: "ticket")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(8)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Have an invite code?")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("Join a private match at this venue")
                                            .font(.caption)
                                            .foregroundColor(DS.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(DS.textSecondary)
                                }
                                .padding(16)
                                .background(DS.surface)
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, DS.s3)
                        
                        // Offers
                        VStack(alignment: .leading, spacing: DS.s2) {
                            Text("1 OFFER AVAILABLE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(DS.textSecondary)
                                .padding(.horizontal, DS.s3)
                            
                            HStack(spacing: DS.s2) {
                                Image(systemName: "percent")
                                    .font(.title3)
                                    .foregroundColor(Color(red: 100/255, green: 220/255, blue: 120/255))
                                    .padding(8)
                                    .background(Color(red: 100/255, green: 220/255, blue: 120/255).opacity(0.1))
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Get 20% OFF up to ₹250")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Valid on select facility")
                                        .font(.caption)
                                        .foregroundColor(DS.textSecondary)
                                }
                                Spacer()
                            }
                            .padding(16)
                            .background(DS.surface)
                            .cornerRadius(16)
                            .padding(.horizontal, DS.s3)
                        }
                        
                        // Amenities
                        VStack(alignment: .leading, spacing: DS.s2) {
                            Text("AMENITIES AVAILABLE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(DS.textSecondary)
                                .padding(.horizontal, DS.s3)
                            
                            LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], spacing: 16) {
                                AmenityRow(icon: "drop", title: "Drinking water")
                                AmenityRow(icon: "p.circle", title: "Parking")
                                AmenityRow(icon: "lightbulb", title: "Flood lights")
                            }
                            .padding(.horizontal, DS.s3)
                        }
                        
                        // Gallery
                        VStack(alignment: .leading, spacing: DS.s2) {
                            Text("GALLERY")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(DS.textSecondary)
                                .padding(.horizontal, DS.s3)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    if venue.imageNames.isEmpty {
                                        Rectangle()
                                            .fill(DS.surface)
                                            .frame(width: 200, height: 140)
                                            .cornerRadius(12)
                                    } else {
                                        ForEach(venue.imageNames, id: \.self) { imageName in
                                            Image(imageName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 200, height: 140)
                                                .cornerRadius(12)
                                                .clipped()
                                        }
                                    }
                                }
                                .padding(.horizontal, DS.s3)
                            }
                            .padding(.horizontal, DS.s3)
                        }
                        
                        // More
                        VStack(alignment: .leading, spacing: DS.s2) {
                            Text("MORE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(DS.textSecondary)
                                .padding(.horizontal, DS.s3)
                            
                            VStack(spacing: 0) {
                                MoreRow(icon: "indianrupeesign.circle", title: "Cancellation policy", subtitle: nil)
                                Divider().background(DS.textSecondary.opacity(0.3)).padding(.leading, 40)
                                MoreRow(icon: "calendar", title: "Reschedule policy", subtitle: "You can reschedule your booking up to 3 hours before the slot start time.")
                                Divider().background(DS.textSecondary.opacity(0.3)).padding(.leading, 40)
                                MoreRow(icon: "questionmark.circle", title: "Frequently asked questions", subtitle: nil)
                            }
                            .background(DS.surface)
                            .cornerRadius(16)
                            .padding(.horizontal, DS.s3)
                        }
                        
                        // Bottom Padding for FAB
                        Color.clear.frame(height: 100)
                    }
                    .padding(.top, DS.s2)
                    
                    // Track scroll offset
                    GeometryReader { geo in
                        Color.clear.preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
                    }
                }
            }
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                self.scrollOffset = value
            }
            .ignoresSafeArea(edges: .top)
            
            
            
            // Floating Liquid Glass Action Bar
            HStack {
                Spacer()
                
                Button(action: { router.push(.bookSlot(venue: venue)) }) {
                    Text("Book slots")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(24)
                }
            }
            .padding(.leading, 24)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .cornerRadius(40)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, DS.s3)
            .padding(.bottom, 16)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(scrollOffset < -150 ? Color.clear : Color.black.opacity(0.4))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
                }
            }
            
            ToolbarItem(placement: .principal) {
                if scrollOffset < -150 {
                    Text(venue.name)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    Button(action: {}) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(scrollOffset < -150 ? Color.clear : Color.black.opacity(0.4))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
                    }
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(scrollOffset < -150 ? Color.clear : Color.black.opacity(0.4))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
                    }
                }
            }
        }
        .onAppear {
            lobbiesListener = bookingService.observePublicLobbies(venueId: venue.venueId) { lobbies in
                self.publicLobbies = lobbies
            }
        }
        .onDisappear {
            lobbiesListener?.remove()
        }
        .sheet(isPresented: $showJoinCodeSheet) {
            JoinByCodeSheet()
        }
    }
    
    
    
    // MARK: - Subcomponents
    
    struct SportPill: View {
        let icon: String
        let title: String
        let isSelected: Bool
        
        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
            }
            .foregroundColor(isSelected ? .white : DS.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? DS.surface : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.white.opacity(0.1) : DS.surface, lineWidth: 1)
            )
        }
    }
    
    struct AmenityRow: View {
        let icon: String
        let title: String
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.white)
                    .frame(width: 20)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        }
    }
    
    struct MoreRow: View {
        let icon: String
        let title: String
        let subtitle: String?
        
        var body: some View {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(DS.textSecondary)
                    .frame(width: 20)
                    .padding(.top, subtitle == nil ? 0 : 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(DS.textSecondary)
                            .lineSpacing(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(DS.textSecondary)
                    .padding(.top, subtitle == nil ? 0 : 2)
            }
            .padding(16)
        }
    }
    
    struct ScrollOffsetKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value += nextValue()
        }
    }
}
