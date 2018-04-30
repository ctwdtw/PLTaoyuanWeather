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
  let displayedHighestTemprature: String
  let displayedLowetstTemprature: String
  let displayedIconDescription: String
  
  init(_ displayedDate: String,
         weekDay: String,
         hightestTemprature: String,
         lowestTemprature: String,
         iconDescription: String) {
    
    self.displayedDate = displayedDate
    self.displayedWeekDay = weekDay
    self.displayedHighestTemprature = hightestTemprature
    self.displayedLowetstTemprature = lowestTemprature
    self.displayedIconDescription = iconDescription
  }
}

struct DisplayedForecast {
  let displayedDate: String
  let displayedWeathers: [DisplayedWeather]
}

struct DisplayedError {
  let title: String
  let errorMessage: String
}

struct DisplayedQuote {
  let id: String
  let displayedDate: String!
  let author: String!
  let quote: String
}

struct WeatherQuoteViewModel {
  var displayedQuote: DisplayedQuote?
  var displayedForecast: DisplayedForecast?
  var displayedError: DisplayedError?
}
