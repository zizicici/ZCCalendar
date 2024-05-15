//
//  WeekdayOrder.swift
//  
//
//  Created by zici on 2024/2/22.
//

import Foundation

public enum WeekdayOrder: Int, CaseIterable, Codable {
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
    
    public func isWeekEnd(twoDaysOff: Bool = true) -> Bool {
        switch self {
        case .mon, .tue, .wed, .thu, .fri:
            return false
        case .sat:
            return twoDaysOff
        case .sun:
            return true
        }
    }
    
    public static var firstDayOfWeek: Self {
        return Self.init(rawValue: Calendar.current.firstWeekday - 1) ?? .sun
    }
    
    public func getShortSymbol() -> String {
        guard let shortWeekdaySymbols = weekSymbolFormatter.shortWeekdaySymbols else {
            return ""
        }
        if rawValue % 7 < shortWeekdaySymbols.count {
            return shortWeekdaySymbols[rawValue % 7]
        } else {
            return ""
        }
    }
    
    public func getVeryShortSymbol() -> String {
        guard let veryShortWeekdaySymbols = weekSymbolFormatter.veryShortWeekdaySymbols else {
            return ""
        }
        if rawValue % 7 < veryShortWeekdaySymbols.count {
            return veryShortWeekdaySymbols[rawValue % 7]
        } else {
            return ""
        }
    }
}

private let weekSymbolFormatter = DateFormatter()
