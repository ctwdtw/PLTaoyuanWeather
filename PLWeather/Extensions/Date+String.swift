//
//  Date+String.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/24.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
extension Date {
  static func quoteDate(from dailyQuoteDatetimeString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    guard let date = dateFormatter.date(from: dailyQuoteDatetimeString) else {
      fatalError("ERROR: Date conversion failed due to mismatched format.")
    }
    return date
  }
  
  //convert 2018/04/24 20:27:00 GMT to Date
  static func forecastDate(from weatherBureauDateTimeString: String) -> Date {
    let wbDatetimeWithoutTimeZone = String(weatherBureauDateTimeString.dropLast(4))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 8*60*60)
    guard let date = dateFormatter.date(from: wbDatetimeWithoutTimeZone) else {
      fatalError("ERROR: Date conversion failed due to mismatched format.")
    }
    return date
  }
  
  static func weatherDate(from weatherDateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd"
    guard let date = dateFormatter.date(from: weatherDateString) else {
      fatalError("ERROR: Date conversion failed due to mismatched format.")
    }
    return date
  }
}
