//
//  GregorianMonth.swift
//  ZCCalendar
//
//  Created by Ci Zi on 2024/2/22.
//

import Foundation

public struct GregorianMonth: Hashable {
    public var year: Int
    public var month: Month
    
    public init(year: Int, month: Month) {
        self.year = year
        self.month = month
    }
    
    public static func <= (left: GregorianMonth, right: GregorianMonth) -> Bool {
        return (left < right) || (left == right)
    }
    
    public static func < (left: GregorianMonth, right: GregorianMonth) -> Bool {
        if left.year < right.year {
            return true
        } else if left.year == right.year {
            if left.month < right.month {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    public static func == (left: GregorianMonth, right: GregorianMonth) -> Bool {
        if left.year == right.year, left.month == right.month {
            return true
        } else {
            return false
        }
    }

    public var index: Int {
        return year * 12 + month.rawValue - 1
    }
    
    public static func generate(by index: Int) -> Self {
        let year: Int = index / 12
        let month: Month = Month(rawValue: index % 12 + 1) ?? .jan
        return GregorianMonth(year: year, month: month)
    }
    
    public var title: String {
        return String(format: (String(localized: "calendar.%i%@")), year, month.name)
    }
    
    public var shortTitle: String {
        return String(format: (String(localized: "calendar.short%i%i")), year, month.rawValue)
    }
}
