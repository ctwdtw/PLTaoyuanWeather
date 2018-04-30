//
//  NSDate+Components.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/19.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation

extension Date {
  func equalToDay(with date: Date) -> Bool {
    guard self.year() == date.year() else { return false }
    guard self.month() == date.month() else { return false }
    guard self.day() == date.day() else { return false }
    return true
  }
  func equalToMonth(with date: Date) -> Bool {
    guard self.year() == date.year() else { return false }
    guard self.month() == date.month() else { return false }
    return true
  }
  func equalToYear(with date: Date) -> Bool {
    guard self.year() == date.year() else { return false }
    return true
  }
}

extension Date {
  func day() -> Int {
    let day = NSCalendar(calendarIdentifier: .gregorian)!.component(.day, from: self)
    return day
  }
  func month() -> Int {
    let month = NSCalendar(calendarIdentifier: .gregorian)!.component(.month, from: self)
    return month
  }
  func year() -> Int {
    let year = NSCalendar(calendarIdentifier: .gregorian)!.component(.year, from: self)
    return year
  }
  func weekDay() -> Int {
    let weekDay = NSCalendar(calendarIdentifier: .gregorian)!.component(.weekday, from: self)
    return weekDay
  }
}
