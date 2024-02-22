//
//  GregorianDay.swift
//  OneOne
//
//  Created by Ci Zi on 2019/9/21.
//  Copyright © 2019 zizicici. All rights reserved.
//

import Foundation

public struct GregorianDay: Equatable, Codable, Hashable {
    let year: Int
    let month: Month
    let day: Int

    var julianDay: Int

    enum CodingKeys: String, CodingKey {
        case year
        case month
        case day
    }

    public init(from decoder: Decoder) throws {
        let decodeValue = try decoder.singleValueContainer().decode(String.self)
        let array = decodeValue.components(separatedBy: "-")
        if array.count == 3 {
            year = Int(array[0]) ?? 1
            month = Month(rawValue: Int(array[1]) ?? 1) ?? .jan
            day = Int(array[2]) ?? 1
        } else {
            year = 1
            month = .jan
            day = 1
        }
        julianDay = GregorianDay.standardJDN(year: year, month: month, day: day)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(format: "%d-%02d-%02d", year, month.rawValue, day))
    }

    init(year: Int, month: Month, day: Int) {
        self.year = year
        self.month = month
        self.day = day
        julianDay = GregorianDay.standardJDN(year: year, month: month, day: day)
    }
    
    init(from date: Date) {
        let calendar = Calendar.current
        self.init(year: calendar.component(.year, from: date), month: Month(rawValue: calendar.component(.month, from: date)) ?? .apr, day: calendar.component(.day, from: date))
    }
    
    init(nanoSeconds: Int64) {
        self.init(from: Date(timeIntervalSince1970: Double(nanoSeconds) / 1000.0))
    }

    init(JDN: Int) {
        var target = JDN
        if JDN <= 2299160 {
            // 1582/10/4
        } else {
            // 1582/10/15
            let alpha = Int((Float(JDN) - 2305447.5) / 36524.25)
            target = JDN + 10 + alpha - Int(alpha/4)
        }
        let B: Float = Float(target + 1524)
        let C = Int((B - 122.1)/365.25)
        let D = Int(365.25 * Float(C))
        let E = Int((B - Float(D)) / 30.60001)
        let dayValue: Int = Int(B - Float(D) - Float(Int(30.60001 * Float(E))))
        var month = E
        if E < 14 {
            month = E - 1
        } else if E < 16 {
            month = E - 13
        }
        var year = 0
        if month > 2 {
            year = C - 4716
        } else {
            year = C - 4715
        }
        self.year = year
        self.month = Month(rawValue: month) ?? .jan
        self.day = dayValue
        julianDay = JDN
    }

    func dayString() -> String {
        if year == 1582, month == .sep, day >= 5 {
            return "\(day + 10)"
        } else {
            return "\(day)"
        }
    }

    func weekdayOrder() -> WeekdayOrder {
        return WeekdayOrder(rawValue: julianDay % 7 + 1) ?? .sun
    }
    
    func generateDate(secondsFromGMT: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month.rawValue
        dateComponents.day = day
        dateComponents.timeZone = TimeZone(secondsFromGMT: secondsFromGMT)
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        return Calendar.current.date(from: dateComponents)
    }

    static func <= (left: GregorianDay, right: GregorianDay) -> Bool {
        if left.year < right.year {
            return true
        } else if left.year == right.year {
            if left.month < right.month {
                return true
            } else if left.month == right.month {
                if left.day <= right.day {
                    return true
                }
            }
        }
        return false
    }

    static func < (left: GregorianDay, right: GregorianDay) -> Bool {
        if left.year < right.year {
            return true
        } else if left.year == right.year {
            if left.month < right.month {
                return true
            } else if left.month == right.month {
                if left.day < right.day {
                    return true
                }
            }
        }
        return false
    }

    static func >= (left: GregorianDay, right: GregorianDay) -> Bool {
        if left.year > right.year {
            return true
        } else if left.year == right.year {
            if left.month > right.month {
                return true
            } else if left.month == right.month {
                if left.day >= right.day {
                    return true
                }
            }
        }
        return false
    }

    static func > (left: GregorianDay, right: GregorianDay) -> Bool {
        if left.year > right.year {
            return true
        } else if left.year == right.year {
            if left.month > right.month {
                return true
            } else if left.month == right.month {
                if left.day > right.day {
                    return true
                }
            }
        }
        return false
    }

    static func - (left: GregorianDay, right: GregorianDay) -> Int {
        return left.julianDay - right.julianDay
    }

    static func + (left: GregorianDay, right: Int) -> GregorianDay {
        return GregorianDay(JDN: left.julianDay + right)
    }

    static func standardJDN(year: Int, month: Month, day: Int) -> Int {
        let a: Int = (month <= .feb) ? 1 : 0
        let y: Int = year + 4800 - a
        let m: Int = month.rawValue + 12 * a - 3
        let dayPart: Int = Int(floor(Float(153 * m + 2) / 5))
        let yYearDays: Int = 365 * y
        let yLeapYears: Int = Int(floor(Float(y / 4)))
        if (year > 1582) || (year == 1582 && month > .oct) || (year == 1582 && month == .oct && day >= 15) {
            let yLeapYearsFix: Int = Int(floor(Float(y / 100))) - Int(floor(Float(y / 400)))
            return Int(day + dayPart + yYearDays + yLeapYears - yLeapYearsFix - 32045)
        } else {
            return Int(day + dayPart + yYearDays + yLeapYears - 32083)
        }
    }
}

extension GregorianDay: GregorianDayContainerProtocol {
    func firstDay() -> Int {
        return julianDay
    }

    func lastDay() -> Int {
        return julianDay
    }
}

extension GregorianDay {
    func convertToIslamicDate() -> (year: Int, month: Int, day: Int)? {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        
        guard let date = gregorianCalendar.date(from: DateComponents(year: self.year, month: self.month.rawValue, day: self.day))
            else {
            return nil
        }
        let islamicalendar = Calendar(identifier: .islamicCivil)//? Why
        
        let formatter = DateFormatter()
        formatter.calendar = islamicalendar
        formatter.dateFormat = "yyyy-MM-dd"
        let islamicDateString = formatter.string(from: date)
        
        guard let date = formatter.date(from: islamicDateString)
               else {
            return nil
        }
        
        let components = islamicalendar.dateComponents([.year, .month, .day], from: date)
        
        return (components.year!, components.month!, components.day!)
    }
    
    func convertToHebrewDate() -> (year: Int, month: Int, day: Int)? {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        
        guard let date = gregorianCalendar.date(from: DateComponents(year: self.year, month: self.month.rawValue, day: self.day))
            else {
            return nil
        }
        let hebrewCalendar = Calendar(identifier: .hebrew)//? Why
        
        let formatter = DateFormatter()
        formatter.calendar = hebrewCalendar
        formatter.dateFormat = "yyyy-MM-dd"
        let islamicDateString = formatter.string(from: date)
        
        guard let date = formatter.date(from: islamicDateString)
               else {
            return nil
        }
        
        let components = hebrewCalendar.dateComponents([.year, .month, .day], from: date)
        
        return (components.year!, components.month!, components.day!)
    }
}

extension GregorianDay {
    public func formatString() -> String? {
        return generateDate(secondsFromGMT: Calendar.current.timeZone.secondsFromGMT())?.formatted(date: .abbreviated, time: .omitted)
    }
    
    public func shortTitle() -> String {
        return String(format: (String(localized: "calendar.short%i%i%i", bundle: .module)), year, month.rawValue, day)
    }
}

enum Month: Int, Codable, CaseIterable {
    case jan = 1
    case feb = 2
    case mar = 3
    case apr = 4
    case may = 5
    case jun = 6
    case jul = 7
    case aug = 8
    case sep = 9
    case oct = 10
    case nov = 11
    case dec = 12

    func dayCount(inLeapYear: Bool = false) -> Int {
        // Normal case, don't handle the 1582 Oct case
        switch self {
        case .jan, .mar, .may, .jul, .aug, .oct, .dec:
            return 31
        case .feb:
            return inLeapYear ? 29 : 28
        case .apr, .jun, .sep, .nov:
            return 30
        }
    }

    static func < (left: Month, right: Month) -> Bool {
        return left.rawValue < right.rawValue
    }

    static func > (left: Month, right: Month) -> Bool {
        return left.rawValue > right.rawValue
    }

    static func <= (left: Month, right: Month) -> Bool {
        return left.rawValue <= right.rawValue
    }

    static func >= (left: Month, right: Month) -> Bool {
        return left.rawValue >= right.rawValue
    }
    
    var name: String {
        switch self {
        case .jan:
            return String(localized: "calendar.month.1", bundle: .module)
        case .feb:
            return String(localized: "calendar.month.2", bundle: .module)
        case .mar:
            return String(localized: "calendar.month.3", bundle: .module)
        case .apr:
            return String(localized: "calendar.month.4", bundle: .module)
        case .may:
            return String(localized: "calendar.month.5", bundle: .module)
        case .jun:
            return String(localized: "calendar.month.6", bundle: .module)
        case .jul:
            return String(localized: "calendar.month.7", bundle: .module)
        case .aug:
            return String(localized: "calendar.month.8", bundle: .module)
        case .sep:
            return String(localized: "calendar.month.9", bundle: .module)
        case .oct:
            return String(localized: "calendar.month.10", bundle: .module)
        case .nov:
            return String(localized: "calendar.month.11", bundle: .module)
        case .dec:
            return String(localized: "calendar.month.12", bundle: .module)
        }
    }
    
    func getShortSymbol() -> String {
        guard let shortMonthSymbols = symbolFormatter.shortMonthSymbols else {
            return ""
        }
        if rawValue <= shortMonthSymbols.count {
            return shortMonthSymbols[rawValue - 1]
        } else {
            return ""
        }
    }
}

enum WeekdayOrder: Int, CaseIterable {
    case mon = 1
    case tue = 2
    case wed = 3
    case thu = 4
    case fri = 5
    case sat = 6
    case sun = 7

    var name: String {
        switch self {
        case .mon:
            return "周一"
        case .tue:
            return "周二"
        case .wed:
            return "周三"
        case .thu:
            return "周四"
        case .fri:
            return "周五"
        case .sat:
            return "周六"
        case .sun:
            return "周日"
        }
    }
    
    var isWeekEnd: Bool {
        if self == .sun || self == .sat {
            return true
        } else {
            return false
        }
    }
    
    static var firstDayOfWeek: Self {
        return Self.init(rawValue: Calendar.current.firstWeekday - 1) ?? .sun
    }
    
    func getShortSymbol() -> String {
        guard let shortWeekdaySymbols = symbolFormatter.shortWeekdaySymbols else {
            return ""
        }
        if rawValue % 7 < shortWeekdaySymbols.count {
            return shortWeekdaySymbols[rawValue % 7]
        } else {
            return ""
        }
    }
}

private let symbolFormatter = DateFormatter()
