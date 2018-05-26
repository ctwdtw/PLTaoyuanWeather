//
//  ViewModel.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/18.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
struct DisplayedWeather {
  let displayedDate: String
  let displayedWeekDay: String
  let displayedDayOrNight: String
  let displayedHighestTemprature: String
  let displayedLowetstTemprature: String
  let displayedIconDescription: String
  
  init(_ displayedDate: String,
       weekDay: String,
       dayOrNight: String,
       hightestTemprature: String,
       lowestTemprature: String,
       iconDescription: String) {
    
    self.displayedDate = displayedDate
    self.displayedWeekDay = weekDay
    self.displayedDayOrNight = dayOrNight
    self.displayedHighestTemprature = hightestTemprature
    self.displayedLowetstTemprature = lowestTemprature
    self.displayedIconDescription = iconDescription
  }
}

struct DisplayedForecast {
  let displayedDate: String
  var displayedWeathers: [DisplayedWeather]
  static func empty() -> DisplayedForecast {
    return DisplayedForecast(displayedDate: "", displayedWeathers: [])
  }
}

struct DisplayedError {
  let timeStamp: Double = Date().timeIntervalSince1970
  let shouldShow: Bool //show the error by UI or just print it in console
  let title: String
  let errorMessage: String
  
  func isContentEqual(to error: DisplayedError) -> Bool {
    return
      self.shouldShow == error.shouldShow &&
        self.title == error.title &&
        self.errorMessage == error.errorMessage
  }
  
}

extension DisplayedError: Equatable {
  static func == (lhs: DisplayedError, rhs: DisplayedError) -> Bool {
    return
      lhs.timeStamp == rhs.timeStamp &&
      lhs.shouldShow == rhs.shouldShow &&
      lhs.title == rhs.title &&
      lhs.errorMessage == rhs.errorMessage
  }
  
  static func != (lhs: DisplayedError, rhs: DisplayedError) -> Bool {
    return
      lhs.timeStamp != rhs.timeStamp ||
      lhs.shouldShow != rhs.shouldShow ||
        lhs.title != rhs.title ||
        lhs.errorMessage != rhs.errorMessage
  }
  
}

struct DisplayedQuote {
  let id: String
  let displayedCultureDate: String
  let displayedDate: String
  let author: String
  let quote: String
  static func empty() -> DisplayedQuote {
    return DisplayedQuote(id: "", displayedCultureDate: "暫無資料", displayedDate: "暫無資料", author: "暫無資料", quote: "暫無資料")
  }
}

struct ForecastQuoteViewModel {
  var displayedQuote: DisplayedQuote?
  var displayedForecast: DisplayedForecast?
  var displayedError: DisplayedError?
  
  //  init(_ displayedQuote: DisplayedQuote? = nil,
  //       _ displayedForecast: DisplayedForecast? = nil,
  //       _ displayedError: DisplayedError? = nil) {
  //    self.displayedQuote = displayedQuote
  //    self.displayedForecast = displayedForecast
  //    self.displayedError = displayedError
  //  }
  //
  //  init(_ displayedQuote: DisplayedQuote?,
  //        displayedForecast: DisplayedForecast?,
  //        displayedError: DisplayedError?) {
  //    self.displayedQuote = displayedQuote
  //    self.displayedForecast = displayedForecast
  //    self.displayedError = displayedError
  //  }
  //
  //  init( displayedQuote: DisplayedQuote?,
  //       _ displayedForecast: DisplayedForecast?,
  //       displayedError: DisplayedError?) {
  //    self.displayedQuote = displayedQuote
  //    self.displayedForecast = displayedForecast
  //    self.displayedError = displayedError
  //  }
  //
  //  init( _ displayedQuote: DisplayedQuote?,
  //          displayedForecast: DisplayedForecast?,
  //        _ displayedError: DisplayedError?) {
  //    self.displayedQuote = displayedQuote
  //    self.displayedForecast = displayedForecast
  //    self.displayedError = displayedError
  //  }
  
  init(displayedQuote: DisplayedQuote? = nil,
       displayedForecast: DisplayedForecast? = nil,
       displayedError: DisplayedError? = nil) {
    self.displayedQuote = displayedQuote
    self.displayedForecast = displayedForecast
    self.displayedError = displayedError
  }
  
}
