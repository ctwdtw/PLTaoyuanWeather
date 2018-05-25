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
    
    if let quote = updatedQuote, let forecast = updatedForecast {
      let vm = getSuccessForecastQuoteVM(quote: quote, forecast: forecast)
      return vm
      
    } else if let quote = updatedQuote, let forecastError = forecastError {
      let vm = getWeatherFailedForecastQuoteVM(quote: quote,
                                               oldForecast: oldForecast,
                                               forecastError: forecastError)
      return vm
      
    } else if let quoteError = quoteError, let forecast = updatedForecast {
      let vm = getQuoteFailedForecastQuoteVM(oldQuote: oldQuote,
                                             quoteError: quoteError,
                                             forecast: forecast)
      return vm
      
    } else if let quoteError = quoteError, let forecastError = forecastError {
      let vm = getFailedWeatherQuoteVM(oldQuote: oldQuote,
                                       quoteError: quoteError,
                                       oldForecast: oldForecast,
                                       forecastError: forecastError)
      return vm
      
    } else if updatedQuote == nil, updatedForecast == nil, quoteError == nil, forecastError == nil {
      let vm = getEmptyForecastQuoteVM()
      return vm
      
    } else {
      fatalError()
      //unexpectPath
    }
    
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
  
  private func getSuccessForecastQuoteVM(quote: Quote, forecast: Forecast) -> ForecastQuoteViewModel {
    
    let displayedQuote = getDisplayedQuote(from: quote)
    let displayedForecast = getDisplayedForecast(from: forecast)
    
    let vm = ForecastQuoteViewModel(displayedQuote:displayedQuote,
                                    displayedForecast: displayedForecast,
                                    displayedError: nil)
    return vm
  }
  
  //both forecast and quote contains error
  private func getFailedWeatherQuoteVM(oldQuote: Quote?,
                                       quoteError: PLErrorProtocol,
                                       oldForecast: Forecast?,
                                       forecastError: PLErrorProtocol) -> ForecastQuoteViewModel {
    
    //debug info for developer
    //let forecastDebugInfo = "\(forecastError.domain):code\(forecastError.code)"
    //let quoteDebugInfo = "\(quoteError.domain):code\(quoteError.code)"
    
    var shouldShow = true
    var title = ""
    var errorMessage = ""
    
    let matchError = (quoteError as? CoreDataError, forecastError as? CoreDataError)
    switch matchError {
    case (.some(.noNeedToUpdateQuote), .some(.noNeedToUpdateForecast)):
      let error = CoreDataError.noNeedToUpdateData
      shouldShow = false
      title = error.domain
      errorMessage = error.localizedDescription
      
    case (.some(.noNeedToUpdateQuote), nil):
      shouldShow = true
      title = forecastError.domain
      errorMessage = forecastError.localizedDescription
      
    case (nil, .some(.noNeedToUpdateForecast)):
      
      shouldShow = true
      title = quoteError.domain
      errorMessage = quoteError.localizedDescription
      
    case (nil, nil):
      if let qe = quoteError as? NetworkError,
        case NetworkError.couldNotConnectToInternet = qe,
        let fe = forecastError as? NetworkError,
        case NetworkError.couldNotConnectToInternet = fe {
        
        shouldShow = true
        title = qe.domain
        errorMessage = qe.localizedDescription
        
      } else {
        print(quoteError)
        print(forecastError)
        
      }
      
    default:
      print(quoteError)
      print(forecastError)
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
    
    let displayedError = DisplayedError(shouldShow: shouldShow,
                                        title: title,
                                        errorMessage: errorMessage)
    
    let vm = ForecastQuoteViewModel(displayedQuote:  displayedQuote,
                                    displayedForecast: displayedForecast,
                                    displayedError: displayedError)
    return vm
    
  }
  
  // quote contains error
  private func getQuoteFailedForecastQuoteVM(oldQuote: Quote?,
                                             quoteError: PLErrorProtocol,
                                             forecast: Forecast) -> ForecastQuoteViewModel {
    var shouldShow = true
    var title = ""
    var errorMessage = ""
    if let qe = quoteError as? CoreDataError,
      case .noNeedToUpdateQuote = qe {
      shouldShow = false
      title = qe.domain
      errorMessage = qe.localizedDescription
      
    } else {
      shouldShow = true
      title = "無法抓取每日一句"
      errorMessage = quoteError.localizedDescription
      
    }
    
    let displayedError = DisplayedError(shouldShow: shouldShow,
                                        title: title,
                                        errorMessage: errorMessage)
    
    let displayedForecast = getDisplayedForecast(from: forecast)
    
    var displayedQuote: DisplayedQuote
    if let quote = oldQuote {
      displayedQuote = getDisplayedQuote(from: quote)
    } else {
      displayedQuote = DisplayedQuote.empty()
    }
    
    let vm = ForecastQuoteViewModel(displayedQuote: displayedQuote,
                                    displayedForecast: displayedForecast,
                                    displayedError: displayedError)
    return vm
  }
  
  //forecast contains error
  private func getWeatherFailedForecastQuoteVM(quote: Quote,
                                               oldForecast: Forecast?,
                                               forecastError: PLErrorProtocol) -> ForecastQuoteViewModel {
    var shouldShow = true
    var title = ""
    var errorMessage = ""
    if let fe = forecastError as? CoreDataError,
      case .noNeedToUpdateQuote = fe {
      shouldShow = false
      title = fe.domain
      errorMessage = fe.localizedDescription
      
    } else {
      shouldShow = true
      title = "無法抓取氣象資料"
      errorMessage = forecastError.localizedDescription
      
    }
    
    let displayedError = DisplayedError(shouldShow: shouldShow,
                                        title: title,
                                        errorMessage: errorMessage)
    
    let displayedQuote = getDisplayedQuote(from: quote)
    
    var displayedForecast: DisplayedForecast
    
    if let forecast = oldForecast {
      displayedForecast = getDisplayedForecast(from: forecast)
    } else {
      displayedForecast = DisplayedForecast.empty()
    }
    
    let vm = ForecastQuoteViewModel(displayedQuote: displayedQuote,
                                    displayedForecast: displayedForecast,
                                    displayedError: displayedError)
    return vm
  }
  
  //empty data
  private func getEmptyForecastQuoteVM() -> ForecastQuoteViewModel {
    let displayedQuote = DisplayedQuote.empty()
    let displayedForecast = DisplayedForecast.empty()
    let vm = ForecastQuoteViewModel(displayedQuote: displayedQuote,
                                    displayedForecast: displayedForecast,
                                    displayedError: nil)
    return vm
  }
  
  deinit {
    deinitMessage(from: self)
  }
  
}
