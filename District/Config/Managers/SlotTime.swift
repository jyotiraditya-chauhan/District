//
//  SlotTime.swift
//  District
//
//  Parses the hard-coded booking slot strings into a real Date so the
//  payment-window rules can be validated against the actual slot start.
//

import Foundation

enum SlotTime {
    /// Builds a real start `Date` for a slot.
    /// - Parameters:
    ///   - day: day-of-month (the calendar strip is hard-coded to July of the current year).
    ///   - timeRange: e.g. "4 - 5 PM", "6 - 7 AM", "11:30 AM - 12:30 PM".
    ///   - isPM: whether the slot is in the evening (Morning → false, Evening → true).
    static func startDate(day: Int, timeRange: String, isPM: Bool) -> Date {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())

        // Take the start token before " - " and strip any AM/PM marker.
        let startToken = timeRange
            .components(separatedBy: "-").first?
            .replacingOccurrences(of: "AM", with: "")
            .replacingOccurrences(of: "PM", with: "")
            .trimmingCharacters(in: .whitespaces) ?? "0"

        let parts = startToken.split(separator: ":")
        let rawHour = Int(parts.first ?? "0") ?? 0
        let minute = parts.count > 1 ? (Int(parts[1]) ?? 0) : 0

        // Convert 12-hour to 24-hour.
        let hour24: Int
        if isPM {
            hour24 = rawHour == 12 ? 12 : rawHour + 12
        } else {
            hour24 = rawHour == 12 ? 0 : rawHour
        }

        var components = DateComponents()
        components.year = year
        components.month = 7            // calendar strip is hard-coded to July
        components.day = day
        components.hour = hour24
        components.minute = minute

        return calendar.date(from: components) ?? Date()
    }
}
