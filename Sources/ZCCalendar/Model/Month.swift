//
//  Month.swift
//  
//
//  Created by Ci Zi on 2024/2/22.
//

import Foundation

public enum Month: Int, Codable, CaseIterable {
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
    
    public var name: String {
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
    
    public func getShortSymbol() -> String {
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

private let symbolFormatter = DateFormatter()
