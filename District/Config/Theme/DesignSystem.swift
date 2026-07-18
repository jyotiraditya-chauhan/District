//
//  Theme.swift
//  district
//
//  Design tokens for the District Play UI.
//

import SwiftUI
import Combine

// MARK: - Color from hex

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch h.count {
        case 8: (r, g, b, a) = (int >> 24 & 0xFF, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b, a) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF, 255)
        }
        self.init(.sRGB,
                  red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Design tokens

enum DS {
    // Colors
    static let background   = Color(hex: "131315")
    static let surface      = Color(hex: "1D1D1F")
    static let card         = Color(hex: "2C2C2E")
    static let divider      = Color(hex: "9CA29D")
    static let textPrimary  = Color(hex: "F5F5F7")
    static let textSecondary = Color(hex: "A1A1A8")
    static let accent       = Color(hex: "4F972E")
    static let ctaBackground = Color(hex: "F4F4F4")
    static let ctaText      = Color(hex: "141414")

    // Radius
    static let rLarge: CGFloat = 28
    static let rMedium: CGFloat = 20
    static let rChip: CGFloat = 12

    // Spacing (8pt base)
    static let s1: CGFloat = 8
    static let s2: CGFloat = 16
    static let s3: CGFloat = 24
    static let s4: CGFloat = 32
    static let s5: CGFloat = 40
    static let s6: CGFloat = 56
}

// MARK: - Section header title style (tracked, uppercased)

extension View {
    func sectionTitleStyle() -> some View {
        self.font(.system(size: 15, weight: .semibold))
            .tracking(2)
            .foregroundStyle(DS.textSecondary)
    }
}

// MARK: - Liquid Glass with fallback

extension View {
    @ViewBuilder
    func glassy(in shape: some Shape = .capsule) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self.background(.ultraThinMaterial, in: shape)
        }
    }
}

//
//  Components.swift
//  district
//
//  Reusable UI components for the Play home screen.
//


// MARK: - Section header ( —— TITLE —— )

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack(spacing: DS.s2) {
            line
            Text(title.uppercased())
                .sectionTitleStyle()
                .fixedSize()
            line
        }
        .padding(.horizontal, DS.s3)
    }
    private var line: some View {
        Rectangle()
            .fill(DS.textSecondary.opacity(0.25))
            .frame(height: 1)
    }
}

// MARK: - Glass circle icon button

struct GlassCircleButton: View {
    let systemName: String
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(DS.textPrimary)
                .frame(width: 44, height: 44)
        }
        .glassy(in: .circle)
    }
}

// MARK: - Search pill

struct SearchPill: View {
    let placeholder: String
    var body: some View {
        HStack(spacing: DS.s1 + 2) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(DS.textSecondary)
            Text(placeholder)
                .font(.system(size: 17))
                .foregroundStyle(DS.textSecondary)
            Spacer()
        }
        .padding(.horizontal, DS.s2 + 2)
        .frame(height: 52)
        .glassy(in: .capsule)
    }
}

// MARK: - Auto-sliding banner carousel

struct BannerCarousel: View {
    let banners: [Banner]
    @State private var index = 0
    private let timer = Timer.publish(every: 3.5, on: .main, in: .common).autoconnect()

    var body: some View {
        TabView(selection: $index) {
            ForEach(Array(banners.enumerated()), id: \.element.id) { i, banner in
                Image(banner.imageAsset)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
                    .tag(i)
            }
        }
        .frame(height: 280)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onReceive(timer) { _ in
            withAnimation(.easeInOut) {
                index = (index + 1) % max(banners.count, 1)
            }
        }
        .overlay(alignment: .bottom) {
            // page dots
            HStack(spacing: 7) {
                ForEach(banners.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == index ? Color.white : Color.white.opacity(0.4))
                        .frame(width: i == index ? 20 : 7, height: 7)
                        .animation(.easeInOut, value: index)
                }
            }
            .padding(.bottom, 12)
        }
    }
}

// MARK: - Sport tile

struct SportTile: View {
    let sport: Sport
    var body: some View {
        VStack(alignment: .leading) {
            Text(sport.name)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(DS.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            HStack {
                Spacer()
                Image(sport.iconAsset)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 74)
                    .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
            }
        }
        .padding(DS.s2)
        .frame(width: 150, height: 150, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: DS.rMedium, style: .continuous)
                .fill(DS.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.rMedium, style: .continuous)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

// MARK: - Time slot chip

struct TimeChip: View {
    let slot: TimeSlot
    var body: some View {
        VStack(spacing: 3) {
            Text(slot.time)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DS.textPrimary)
            Text(slot.tag)
                .font(.system(size: 13))
                .foregroundStyle(DS.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.s1 + 4)
        .background(
            RoundedRectangle(cornerRadius: DS.rChip, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.rChip, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }
}

// MARK: - Venue thumbnail placeholder

struct VenueThumb: View {
    let iconAsset: String
    let tint: Color
    var size: CGFloat = 64
    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(
                LinearGradient(colors: [tint.opacity(0.9), tint.opacity(0.35)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .frame(width: size, height: size)
            .overlay(
                Image(iconAsset)
                    .resizable().aspectRatio(contentMode: .fit)
                    .padding(size * 0.18)
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
            )
    }
}

// MARK: - Venue row (inside Play card)

struct VenueRow: View {
    let venue: PlayVenue
    var body: some View {
        VStack(spacing: DS.s2) {
            HStack(spacing: DS.s2) {
                VenueThumb(iconAsset: venue.iconAsset, tint: venue.tint)
                VStack(alignment: .leading, spacing: 4) {
                    Text(venue.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(DS.textPrimary)
                        .lineLimit(1)
                    Text("\(venue.distance) • \(venue.area)")
                        .font(.system(size: 15))
                        .foregroundStyle(DS.textSecondary)
                }
                Spacer(minLength: 0)
            }
            HStack(spacing: DS.s1 + 4) {
                ForEach(venue.slots) { TimeChip(slot: $0) }
            }
        }
    }
}

// MARK: - "Play your game" big card

struct PlayCard: View {
    let category: PlayCategory
    var body: some View {
        VStack(alignment: .leading, spacing: DS.s3) {
            // header w/ hero icon
            ZStack(alignment: .topLeading) {
                HStack {
                    Spacer()
                    Image(category.heroIcon)
                        .resizable().aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .opacity(0.9)
                        .shadow(color: .black.opacity(0.4), radius: 10, y: 6)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(DS.textPrimary)
                    Text(category.subtitle)
                        .font(.system(size: 17))
                        .foregroundStyle(DS.textSecondary)
                }
            }
            .padding(.top, DS.s1)

            ForEach(category.venues) { VenueRow(venue: $0) }

            // View all
            Button { } label: {
                HStack(spacing: 6) {
                    Text("View all venues")
                        .font(.system(size: 18, weight: .bold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(DS.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: DS.rLarge, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
            }
        }
        .padding(DS.s3)
        .frame(width: 360, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DS.rLarge, style: .continuous)
                .fill(
                    LinearGradient(colors: category.gradient,
                                   startPoint: .topTrailing, endPoint: .bottomLeading)
                )
        )
    }
}

// MARK: - Nearby court card

struct VenueCard: View {
    let venue: NearbyVenue
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                LinearGradient(colors: [venue.tint.opacity(0.95), venue.tint.opacity(0.5)],
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: 150)
                    .overlay(
                        Image(venue.iconAsset)
                            .resizable().aspectRatio(contentMode: .fit)
                            .frame(height: 90)
                            .opacity(0.85)
                            .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, DS.s2)
                    )

                HStack {
                    if venue.isExclusive {
                        Text("DISTRICT EXCLUSIVE")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(0.5)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(
                                Capsule().fill(
                                    LinearGradient(colors: [Color(hex: "C97A18"), Color(hex: "E0A32E")],
                                                   startPoint: .leading, endPoint: .trailing))
                            )
                    }
                    Spacer()
                    Image(systemName: "bookmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(.black.opacity(0.35)))
                }
                .padding(DS.s2 - 4)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(venue.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(DS.textPrimary)
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill").font(.system(size: 11))
                        Text(venue.rating).font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Capsule().fill(DS.accent))
                }
                Text(venue.area)
                    .font(.system(size: 14))
                    .foregroundStyle(DS.textSecondary)
                Text("\(venue.price) onwards")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DS.textPrimary)
                    .padding(.top, 2)
            }
            .padding(DS.s2)
        }
        .frame(width: 280)
        .background(RoundedRectangle(cornerRadius: DS.rMedium, style: .continuous).fill(DS.surface))
        .clipShape(RoundedRectangle(cornerRadius: DS.rMedium, style: .continuous))
    }
}
