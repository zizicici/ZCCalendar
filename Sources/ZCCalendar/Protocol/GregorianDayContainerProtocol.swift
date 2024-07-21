//
//  GregorianDayContainerProtocol.swift
//  ZCCalendar
//
//  Created by zici on 2019/9/21.
//

import Foundation

public protocol GregorianDayContainerProtocol {
    func firstDay() -> Int
    func lastDay() -> Int
}

public extension GregorianDayContainerProtocol {
    func interSection(with other: GregorianDayContainerProtocol) -> Bool {
        return !(other.lastDay() < firstDay() || other.firstDay() > lastDay())
    }

    func contain(_ day: GregorianDay) -> Bool {
        return day.julianDay >= firstDay() && day.julianDay <= lastDay()
    }

    func earlier(than day: GregorianDay) -> Bool {
        return lastDay() < day.julianDay
    }
}

public struct GregorianDayContainer: GregorianDayContainerProtocol {
    let start: GregorianDay
    let end: GregorianDay

    init(start: GregorianDay, end: GregorianDay) {
        self.start = start
        self.end = end
    }

    init(year: Int) {
        start = GregorianDay(year: year, month: .jan, day: 1)
        end = GregorianDay(year: year, month: .dec, day: 31)
    }

    init(year: Int, month: Month) {
        let dayCount = Manager.shared.dayCount(at: month, year: year)
        start = GregorianDay(year: year, month: month, day: 1)
        end = GregorianDay(year: year, month: month, day: dayCount)
    }

    public func firstDay() -> Int {
        return start.julianDay
    }

    public func lastDay() -> Int {
        return end.julianDay
    }
}

public extension Array where Element: GregorianDayContainerProtocol {
    func findElement(containing day: GregorianDay) -> Element? {
        var lowerBound: Int = 0
        var upperBound: Int = count
        while lowerBound < upperBound {
            let midIndex = lowerBound + (upperBound - lowerBound) / 2
            if self[midIndex].contain(day) {
                return self[midIndex]
            } else if self[midIndex].earlier(than: day) {
                lowerBound = midIndex + 1
            } else {
                upperBound = midIndex
            }
        }
        return nil
    }
}
