//
//  GregorianDay.swift
//  ZCCalendar
//
//  Created by zici on 2019/9/21.
//

import Foundation

private struct YMDKey: Hashable {
    let year: Int
    let month: Month
    let day: Int
}

private final class GregorianDayCache {
    static let shared = GregorianDayCache()
    private var ymdCache = [YMDKey: GregorianDay]()
    private var jdnCache = [Int: GregorianDay]()
    private let queue = DispatchQueue(label: "com.gregorianday.cache", attributes: .concurrent)
    
    func getFromYMD(key: YMDKey) -> GregorianDay? {
        return queue.sync { ymdCache[key] }
    }
    
    func getFromJDN(JDN: Int) -> GregorianDay? {
        return queue.sync { jdnCache[JDN] }
    }
    
    func cache(day: GregorianDay) {
        let key = YMDKey(year: day.year, month: day.month, day: day.day)
        queue.async(flags: .barrier) {
            self.ymdCache[key] = day
            self.jdnCache[day.julianDay] = day
        }
    }
}

public struct GregorianDay: Equatable, Codable, Hashable {
    public let year: Int
    public let month: Month
    public let day: Int
    public var julianDay: Int

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
    
    private init(year: Int, month: Month, day: Int, julianDay: Int) {
        self.year = year
        self.month = month
        self.day = day
        self.julianDay = julianDay
    }

    public init(year: Int, month: Month, day: Int) {
        let key = YMDKey(year: year, month: month, day: day)
        
        if let cached = GregorianDayCache.shared.getFromYMD(key: key) {
            self = cached
            return
        }
        
        let jdn = Self.standardJDN(year: year, month: month, day: day)
        let newValue = Self.init(year: year, month: month, day: day, julianDay: jdn)
        
        GregorianDayCache.shared.cache(day: newValue)
        self = newValue
    }
    
    public init(from date: Date, timeZone: TimeZone = TimeZone.current) {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        self.init(year: calendar.component(.year, from: date), month: Month(rawValue: calendar.component(.month, from: date)) ?? .apr, day: calendar.component(.day, from: date))
    }
    
    public init(nanoSeconds: Int64) {
        self.init(from: Date(timeIntervalSince1970: Double(nanoSeconds) / 1000.0))
    }

    public init(JDN: Int) {
        if let cached = GregorianDayCache.shared.getFromJDN(JDN: JDN) {
            self = cached
            return
        }
        
        let jd = Double(JDN)
        let z = Int(jd + 0.5)
        let f = jd + 0.5 - Double(z)
        var a = z
        if z < 2299161 {
            a = z
        } else {
            let alpha = Int((Double(z) - 1867216.25) / 36524.25)
            a = z + 1 + alpha - alpha / 4
        }
        let b = a + 1524
        let c = Int((Double(b) - 122.1) / 365.25)
        let d = Int(365.25 * Double(c))
        let e = Int(Double(b - d) / 30.6001)
        
        let day = b - d - Int(30.6001 * Double(e)) + Int(f)
        let month = e < 14 ? e - 1 : e - 13
        let year = month > 2 ? c - 4716 : c - 4715
        
        let newValue = Self.init(year: year, month: Month(rawValue: month) ?? .jan, day: day, julianDay: JDN)
        GregorianDayCache.shared.cache(day: newValue)

        self = newValue
    }

    public func dayString() -> String {
        if year == 1582, month == .sep, day >= 5 {
            return "\(day + 10)"
        } else {
            return "\(day)"
        }
    }

    public func weekdayOrder() -> WeekdayOrder {
        return WeekdayOrder(rawValue: julianDay % 7 + 1) ?? .sun
    }
    
    public func generateDate(secondsFromGMT: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date? {
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

    public static func <= (left: GregorianDay, right: GregorianDay) -> Bool {
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

    public static func < (left: GregorianDay, right: GregorianDay) -> Bool {
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

    public static func >= (left: GregorianDay, right: GregorianDay) -> Bool {
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

    public static func > (left: GregorianDay, right: GregorianDay) -> Bool {
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

    public static func - (left: GregorianDay, right: GregorianDay) -> Int {
        return left.julianDay - right.julianDay
    }

    public static func + (left: GregorianDay, right: Int) -> GregorianDay {
        return GregorianDay(JDN: left.julianDay + right)
    }

    public static func standardJDN(year: Int, month: Month, day: Int) -> Int {
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
    public func firstDay() -> Int {
        return julianDay
    }

    public func lastDay() -> Int {
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
    public func completeFormatString() -> String? {
        return generateDate(secondsFromGMT: Calendar.current.timeZone.secondsFromGMT())?.formatted(date: .complete, time: .omitted)
    }
    
    public func formatString() -> String? {
        return generateDate(secondsFromGMT: Calendar.current.timeZone.secondsFromGMT())?.formatted(date: .abbreviated, time: .omitted)
    }
    
    public func shortTitle() -> String {
        return String(format: (String(localized: "calendar.short%i%i%i", bundle: .module)), year, month.rawValue, day)
    }
}
