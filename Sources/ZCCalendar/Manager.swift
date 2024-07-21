//
//  Manager.swift
//  ZCCalendar
//
//  Created by zici on 2023/5/28.
//

import Foundation
import UIKit
import OSLog

public extension Notification.Name {
    static let TodayUpdated = Notification.Name(rawValue: "com.zizicici.common.time.updated")
}

public class Manager {
    static let shared = Manager()
    
    public private(set) var today: GregorianDay {
        didSet {
            if today != oldValue {
                NotificationCenter.default.post(Notification(name: Notification.Name.TodayUpdated))
            }
        }
    }
    
    init() {
        let component = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: Date())
        self.today = GregorianDay(year: component.year ?? 1, month: Month(rawValue: component.month ?? 1) ?? .jan, day: component.day ?? 1)
        NotificationCenter.default.addObserver(self, selector: #selector(updateToday), name: UIApplication.significantTimeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateToday), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc
    func updateToday() {
        let component = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: Date())
        self.today = GregorianDay(year: component.year ?? 1, month: Month(rawValue: component.month ?? 1) ?? .jan, day: component.day ?? 1)
    }
    
    public func getDays(in month: Month, year: Int) -> [GregorianDay] {
        let dayCount = dayCount(at: month, year: year)
        let result = Array(0..<dayCount).map { dayIndex in
            return GregorianDay(year: year, month: month, day: dayIndex + 1)
        }
        return result
    }
    
    func dayCount(at month: Month, isLeapYear: Bool) -> Int {
        switch month {
        case .jan, .mar, .may, .jul, .aug, .oct, .dec:
            return 31
        case .apr, .jun, .sep, .nov:
            return 30
        case .feb:
            return isLeapYear ? 29 : 28
        }
    }
    
    public func dayCount(at month: Month, year: Int) -> Int {
        if year == 1582 && month == .oct {
            // 1582 fix
            return 21
        } else {
            return dayCount(at: month, isLeapYear: isLeap(year))
        }
    }
    
    func dayCount(year: Int) -> Int {
        if isLeap(year) {
            return 366
        } else {
            if year == 1582 {
                return 355
            } else {
                return 365                
            }
        }
    }
    
    func isLeap(_ year: Int) -> Bool {
        if year <= 4 {
            // Leap year error
            return fixLeap(year)
        } else {
            if year % 4 == 0 {
                if year > 1582 {
                    // Use Gregorian
                    if year % 100 == 0 {
                        return year % 400 == 0
                    } else {
                        return true
                    }
                } else {
                    return true
                }
            } else {
                return false
            }
        }
    }
    
    func fixLeap(_ year: Int) -> Bool {
        // Using Scaliger's theory
        if (year <= -8 && year >= -41) {
            return year % 3 == 2
        } else {
            return false
        }
    }
    
    public func firstDay(at month: Month, year: Int) -> GregorianDay {
        let day = GregorianDay(year: year, month: month, day: 1)
        return day
    }
    
    public func lastDay(at month: Month, year: Int) -> GregorianDay {
        let dayCount = dayCount(at: month, year: year)
        let day = GregorianDay(year: year, month: month, day: dayCount)
        return day
    }
    
    public func isToday(gregorianDay: GregorianDay?) -> Bool {
        if gregorianDay == nil {
            return false
        }
        return today == gregorianDay
    }
    
    public func isCurrent(month: Month, year: Int) -> Bool {
        return (today.month == month) && (today.year == year)
    }
    
    public func isCurrent(year: Int) -> Bool {
        return today.year == year
    }
    
    public func nextMonth(month: Month, year: Int) -> (month: Month, year: Int)? {
        guard let nextMonth = Month(rawValue: (month.rawValue) % 12 + 1) else {
            return nil
        }
        
        switch month {
        case .dec:
            return (nextMonth, year + 1)
        default:
            return (nextMonth, year)
        }
    }
    
    public func previousMonth(month: Month, year: Int) -> (month: Month, year: Int)? {
        guard let previousMonth = Month(rawValue: (month.rawValue + 10) % 12 + 1) else {
            return nil
        }
        
        switch month {
        case .jan:
            return (previousMonth, year - 1)
        default:
            return (previousMonth, year)
        }
    }
}
