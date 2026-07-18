//
//  AppTypography.swift
//  District
//
//  System font (SF Pro Display on iOS) at the weights/sizes observed in the design system.
//

import SwiftUI

enum AppTypography {
    /// Venue title — 26-30px Bold
    static let title = Font.system(size: 28, weight: .bold)

    /// Section headings — 15-17px Medium, used with increased tracking
    static let sectionHeading = Font.system(size: 16, weight: .medium)
    static let sectionHeadingTracking: CGFloat = 1.2

    /// Primary body — 17-20px Semibold
    static let primaryBody = Font.system(size: 18, weight: .semibold)

    /// Secondary body — 14-16px Regular
    static let secondaryBody = Font.system(size: 15, weight: .regular)

    /// Buttons — Semibold
    static let button = Font.system(size: 17, weight: .semibold)

    /// Chips — Medium
    static let chip = Font.system(size: 14, weight: .medium)

    /// CTA — 20-24px Bold
    static let cta = Font.system(size: 22, weight: .bold)
}
