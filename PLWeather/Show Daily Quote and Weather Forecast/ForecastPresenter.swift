//
//  WeatherQuotePresenter.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/5/21.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation

//Presentation logic such as formatting string/Date into string user will see.
class ForecastPresenter {
  func getForecastQuoteViewModel(updatedQuote: Quote?,
                                 oldQuote: Quote?,
                                 quoteError: PLErrorProtocol?,
                                 updatedForecast: Forecast?,
                                 oldForecast: Forecast?,
                                 forecastError: PLErrorProtocol?) -> ForecastQuoteViewModel {
    
    if let quote = updatedQuote, let forecast = updatedForecast, quoteError == nil, forecastError == nil {
      //fetch locally success
      let dq = getDisplayedQuote(from: quote)
      let df = getDisplayedForecast(from: forecast)
      return ForecastQuoteViewModel(displayedQuote: dq, displayedForecast: df)
      
    } else if let quote = updatedQuote, quoteError == nil {
      // fetch remote quote success
      let dq = getDisplayedQuote(from: quote)
      return ForecastQuoteViewModel(displayedQuote: dq)
      
    } else if let forecast = updatedForecast, forecastError == nil {
      //fetch remote forecast success
      let df = getDisplayedForecast(from: forecast)
      return ForecastQuoteViewModel(displayedForecast: df)
      
    } else if let qe = quoteError as? CoreDataError, case .noNeedToUpdateQuote = qe {
      //no need update quote
      let de = DisplayedError(shouldShow: false, title: qe.domain, errorMessage: qe.localizedDescription)
      let dq = oldQuote == nil ? DisplayedQuote.empty() : getDisplayedQuote(from: oldQuote!)
      return ForecastQuoteViewModel(displayedQuote: dq, displayedError: de, erroredDataType: .quote)
      
    } else if let fe = forecastError as? CoreDataError, case .noNeedToUpdateForecast = fe {
      // no need update forecast
      let de = DisplayedError(shouldShow: false, title: fe.domain, errorMessage: fe.localizedDescription)
      let df = oldForecast == nil ? DisplayedForecast.empty() : getDisplayedForecast(from: oldForecast!)
      return ForecastQuoteViewModel(displayedForecast: df, displayedError: de, erroredDataType: .forecast)
      
    } else if let qe = quoteError {
      //fetch remote quote error
      let de = DisplayedError(shouldShow: true, title: qe.domain, errorMessage: qe.localizedDescription)
      return ForecastQuoteViewModel(displayedError: de, erroredDataType: .quote)
      
    } else if let fe = forecastError {
      //fetch remote forecast error
      let de = DisplayedError(shouldShow: true, title: fe.domain, errorMessage: fe.localizedDescription)
      return ForecastQuoteViewModel(displayedError: de, erroredDataType: .forecast)
      
    } else if updatedQuote == nil, oldQuote == nil, quoteError == nil,
              updatedForecast == nil, oldForecast == nil, forecastError == nil{
      //first time start app, fetch data locally
      let dq = DisplayedQuote.empty()
      let df = DisplayedForecast.empty()
      return ForecastQuoteViewModel(displayedQuote: dq, displayedForecast: df)
      
    } else {
      fatalError()
    }
    
  }
  
  func getDisplayedForecast(from forecast: Forecast) -> DisplayedForecast {
    let calendar = Calendar(identifier: .gregorian)
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_TW")
    formatter.dateStyle = .medium
    formatter.calendar = calendar
    
    let displayedDate = formatter.string(from: forecast.lastupdate)
    let displayedWeathers = forecast.weathers.map { getDisplayedWeather(from: $0)  }
    let displayedForecast = DisplayedForecast(displayedDate: displayedDate,
                                              displayedWeathers: displayedWeathers)
    return displayedForecast
  }
  
  private func getDisplayedWeather(from weather: Weather) -> DisplayedWeather {
    let calendar = Calendar(identifier: .gregorian)
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_TW")
    formatter.dateFormat = "MM/dd"
    formatter.calendar = calendar
    
    let displayedDate = formatter.string(from: weather.date)
    let displayedHighestTempratrue = "\(weather.highestTemprature)°C"
    let displayedLowestTemprature = "\(weather.lowestTemprature)°C"
    
    return DisplayedWeather(displayedDate,
                            weekDay: weather.weekDay.stringRep,
                            dayOrNight: weather.dayOrNight.stringRep,
                            hightestTemprature: displayedHighestTempratrue,
                            lowestTemprature: displayedLowestTemprature,
                            iconDescription: weather.iconDescription.stringRep)
  }
  
  private func getDisplayedQuote(from quote: Quote) -> DisplayedQuote {
    let cultureCalendar = Calendar(identifier: .hebrew)
    let calendar = Calendar(identifier: .gregorian)
    
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_TW")
    formatter.dateStyle = .medium
    
    formatter.calendar = cultureCalendar
    let displayedCultureDate = formatter.string(from: quote.date)
    
    formatter.calendar = calendar
    let displayedDate = formatter.string(from: quote.date)
    
    let displayedQuote = DisplayedQuote(id: quote.id,
                                        displayedCultureDate: displayedCultureDate,
                                        displayedDate: displayedDate,
                                        author:quote.author ?? "",
                                        quote: quote.quote)
    
    return displayedQuote
    
  }
  
  deinit {
    deinitMessage(from: self)
  }
  
}
