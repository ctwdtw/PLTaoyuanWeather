//
//  WeatherQuotePresenter.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/5/21.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation

//Presentation logic such as formatting string/Date into string user will see.
class WeatherQuotePresenter {
  func getWeatherQuoteViewModel(updatedQuote: Quote?,
                                oldQuote: Quote?,
                                quoteError: PLErrorProtocol?,
                                updatedForecast: Forecast?,
                                oldForecast: Forecast?,
                                forecastError: PLErrorProtocol?) -> WeatherQuoteViewModel {
    
    if let quote = updatedQuote, let forecast = updatedForecast {
      let vm = getSuccessWeatherQuoteVM(quote: quote, forecast: forecast)
      return vm
      
    } else if let quote = updatedQuote, let forecastError = forecastError {
      let vm = getWeatherFailedWeatherQuoteVM(quote: quote, forecastError: forecastError)
      return vm
      
    } else if let quoteError = quoteError, let forecast = updatedForecast {
      let vm = getQuoteFailedWeatherQuoteVM(quoteError: quoteError, forecast: forecast)
      return vm
      
    } else if let quoteError = quoteError, let forecastError = forecastError {
      let vm = getFailedWeatherQuoteVM(oldQuote: oldQuote,
                                       quoteError: quoteError,
                                       oldForecast: oldForecast,
                                       forecastError: forecastError)
      return vm
      
    } else if updatedQuote == nil, updatedForecast == nil, quoteError == nil, forecastError == nil {
      let vm = getEmptyWeatherQuoteVM()
      return vm
      
    } else {
      fatalError()
      //unexpectPath
    }
    
  }
  
  
  private func getDisplayedQuote(from quote: Quote) -> DisplayedQuote {
    let calendar = Calendar(identifier: .hebrew)
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_TW")
    formatter.dateStyle = .medium
    formatter.calendar = calendar
    
    let displayedDate = formatter.string(from: quote.date)
    
    let displayedQuote = DisplayedQuote(id: quote.id,
                                        displayedDate: displayedDate,
                                        author:quote.author ?? "",
                                        quote: quote.quote)
    
    return displayedQuote
    
  }
  
  func getDisplayedForecast(from forecast: Forecast) -> DisplayedForecast {
    let calendar = Calendar(identifier: .hebrew)
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
    let calendar = Calendar(identifier: .hebrew)
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_TW")
    formatter.dateStyle = .medium
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
  
  
  private func getSuccessWeatherQuoteVM(quote: Quote, forecast: Forecast) -> WeatherQuoteViewModel {
    
    let displayedQuote = getDisplayedQuote(from: quote)
    let displayedForecast = getDisplayedForecast(from: forecast)
    
    let vm = WeatherQuoteViewModel(displayedQuote:displayedQuote,
                                   displayedForecast: displayedForecast,
                                   displayedError: nil)
    return vm
  }
  
  private func getFailedWeatherQuoteVM(oldQuote: Quote?,
                                       quoteError: PLErrorProtocol,
                                       oldForecast: Forecast?,
                                       forecastError: PLErrorProtocol) -> WeatherQuoteViewModel {
    
    //debug info for developer
    //let forecastDebugInfo = "\(forecastError.domain):code\(forecastError.code)"
    //let quoteDebugInfo = "\(quoteError.domain):code\(quoteError.code)"
    
    //TODO:// - fix hard code
    
    var shouldShow = true
    var title = "抓取資料錯誤"
    var errorMessage = "無法抓取天氣預報和每日一句資料"
    
    if let quoteError = quoteError as? APIError, quoteError == .noNeedToUpdateQuote,
      let forecastError = forecastError as? APIError, forecastError == .noNeedToUpdateForecast {
      shouldShow = false
      title = ""
      errorMessage = "無需更新資料"
    
    } else if let quoteError = quoteError as? APIError, quoteError == .noNeedToUpdateQuote {
      //quote 無需更新
      title = "抓取氣象資料錯誤"
      errorMessage = "無法抓取氣象資料"
    
    } else if let forecastError = forecastError as? APIError, forecastError == .noNeedToUpdateForecast {
      //forecast 無需更新
      title = "抓取每日一句資料錯誤"
      errorMessage = "無法抓取每日一句資料"
    
    }
    
    let displayedQuote: DisplayedQuote
    if let oldQuote = oldQuote {
      displayedQuote = getDisplayedQuote(from: oldQuote)
    } else {
      displayedQuote = DisplayedQuote.empty()
    }
    
    let displayedForecast : DisplayedForecast
    
    if let oldForecast = oldForecast {
      displayedForecast = getDisplayedForecast(from: oldForecast)
    } else {
      displayedForecast = DisplayedForecast.empty()
    }
    
    let displayedError = DisplayedError(shouldShow: shouldShow, title: title, errorMessage: errorMessage)
    let vm = WeatherQuoteViewModel(displayedQuote:  displayedQuote,
                                   displayedForecast: displayedForecast,
                                   displayedError: displayedError)
    return vm
    
  }
  
  private func getQuoteFailedWeatherQuoteVM(quoteError: PLErrorProtocol,
                                            forecast: Forecast) -> WeatherQuoteViewModel {
    let displayedError = DisplayedError(shouldShow: true, title: "無法抓取每日一句", errorMessage: quoteError.localizedDescription)
    let displayedForecast = getDisplayedForecast(from: forecast)
    let vm = WeatherQuoteViewModel(displayedQuote: DisplayedQuote.empty(),
                                   displayedForecast: displayedForecast,
                                   displayedError: displayedError)
    return vm
  }
  
  private func getWeatherFailedWeatherQuoteVM(quote: Quote,
                                              forecastError: PLErrorProtocol) -> WeatherQuoteViewModel {
    let displayedQuote = getDisplayedQuote(from: quote)
    let displayedError = DisplayedError(shouldShow: true, title: "無法抓取氣象資料", errorMessage: forecastError.localizedDescription)
    let vm = WeatherQuoteViewModel(displayedQuote: displayedQuote,
                                   displayedForecast: DisplayedForecast.empty(),
                                   displayedError: displayedError)
    return vm
  }
  
  private func getEmptyWeatherQuoteVM() -> WeatherQuoteViewModel {
    let displayedQuote = DisplayedQuote.empty()
    let displayedForecast = DisplayedForecast.empty()
    let vm = WeatherQuoteViewModel(displayedQuote: displayedQuote,
                                   displayedForecast: displayedForecast,
                                   displayedError: nil)
    return vm
  }
  
  
}
