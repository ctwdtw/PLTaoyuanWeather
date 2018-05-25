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
  let shouldShow: Bool //show the error by UI or just print it in console
  let title: String
  let errorMessage: String
}

struct DisplayedQuote {
  let id: String
  let displayedDate: String
  let author: String
  let quote: String
  static func empty() -> DisplayedQuote {
    return DisplayedQuote(id: "", displayedDate: "暫無資料", author: "暫無資料", quote: "暫無資料")
  }
}

struct ForecastQuoteViewModel {
  var displayedQuote: DisplayedQuote?
  var displayedForecast: DisplayedForecast?
  var displayedError: DisplayedError?
}
