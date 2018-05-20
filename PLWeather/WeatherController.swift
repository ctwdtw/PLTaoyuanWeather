//
//  WeatherController.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/18.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
//實作在 Model 層上, 由 Controller 呼叫
protocol WeatherQuoteStoreProtocol {
  func fetchForecast(completion: @escaping (Forecast?, PLErrorProtocol?) -> Void)
  func fetchDaliyQuote(completion: @escaping (Quote?, PLErrorProtocol?) -> Void)
  
}

protocol WeatherQuoteLocalStoreProtocol: WeatherQuoteStoreProtocol {
  var lastupdateDateForQuote: Date? { get }
  var lastupdateDateForForecast: Date? { get }
  func insertDailyQuote(_ quote: Quote, completion: @escaping (PLErrorProtocol?) -> Void )
  func insertForecast(_ forecast: Forecast, completion: @escaping (PLErrorProtocol?) -> Void )
  //func deleteWeather(`for` ids: [String], completion: @escaping (Error) -> Void )
}

//實作在Controller上, 由 VC 呼叫
protocol WeatherQuoteControllerProtocol {
  //var localStore: WeatherQuoteLocalStoreProtocol { get }
  //var remoteStore: WeatherQuoteStoreProtocol { get }
}

enum WeatherSortingType {
  case temprature
  case weatherType
}

//business logic here
//delegate remote data logic to remoteDataManager
//delegate local data logic to localdDataManager
//business logic include:
//1./sync data between remote and local
//2./formate data from model struct to viewModel structs to be displayed on ViewController (presentation logic)

//this is a mediator, it mediate dataformate between view (IndexPath for example) and model (id for example)...例如從 tableview(viewController) fire 一個刪除 row 的 message, 這層 controller 吃到 NSIndexPath 後會把轉換成 id 給下一層的 localDataManager 去真的執行刪除動作, 然後才把reload 的指令包成 IndexPath 給tableView(ViewController) 讓他去 reload Data.....

class WeatherController {
  private var localStore: WeatherQuoteLocalStoreProtocol = CoreDataStore()
  private var remoteStore: WeatherQuoteStoreProtocol = APIDataStore()
  private var isUpdatingLocalQuote = false
  private var isUpdatingLocalForecast = false
  private var isUpdatingLocaldata: Bool {
    
    if isUpdatingLocalQuote == false && isUpdatingLocalForecast == false {
      return false
    } else {
      return true
    }
    
  }
  
  private var updateLocalQuoteError: PLErrorProtocol? = nil
  private var updateLocalForecast: PLErrorProtocol? = nil
  
}

extension WeatherController: WeatherQuoteControllerProtocol {  
  //業務邏輯
  //a. fetchOnLoad
  //1. show local 資料給 view, 打包好 Local Quote & Local Forecast 給 View
  //2. 由 remote 端抓取資料, 若比 Local 端新, 就插入資料進入 CoreData
  //3. 將最新資料傳遞給 View
  
  //b. pull to fetch
  //1. 由 remote 端抓取資料，若比資料目前的新，就更新資料並展示，否則return掉。
  
  func fetchDataOnLoad(completion: @escaping (WeatherQuoteViewModel) -> Void) {
    fetchLocalQuoteAndForecast { (vm) in
      completion(vm)
      self.pullToRefreshData(completion: completion)
    }
  }
  
  func pullToRefreshData(completion: @escaping (WeatherQuoteViewModel) -> Void) {
    updateLocalData { updatedQuote, quoteUpdatedError, updatedForecast, forecastUpdatedError in
      
      let vm = self.getWeatherQuoteViewModel(quote: updatedQuote,
                                             quoteError: quoteUpdatedError,
                                             forecast: updatedForecast,
                                             forecastError: forecastUpdatedError)
      completion(vm)
      
    }
  }
  
  //FIXME :- performance issue: use `objectForID` to reduce frequency of fetching
  //fetch is expensive
  private func fetchLocalQuoteAndForecast(completion: @escaping (WeatherQuoteViewModel) -> Void) {
  
    localStore.fetchDaliyQuote { (quote, error) in
      guard let localQuote = quote else {
        //TODO: - hanlde error
        //return vm with error
        
        let displayedError = DisplayedError(title: "PLError", errorMessage: "PLMessage")
        let vm = WeatherQuoteViewModel(displayedQuote: nil, displayedForecast: nil, displayedError: displayedError)
        completion(vm)
        return
      }
      
      let displayedQuote = self.getDisplayedQuote(from: localQuote)
      
      self.localStore.fetchForecast { (forecast, error) in
        guard let localForecast = forecast else {
          //TODO: - hanlde error
          //return vm with error
          let displayedError = DisplayedError(title: "PLError", errorMessage: "PLMessage")
          let vm = WeatherQuoteViewModel(displayedQuote: nil, displayedForecast: nil, displayedError: displayedError)
          completion(vm)
          return
        }
        
        let displayedForecast = self.getDisplayedForecast(from: localForecast)
        
        let vm = WeatherQuoteViewModel(displayedQuote: displayedQuote,
                                       displayedForecast: displayedForecast,
                                       displayedError: nil)
        
        completion(vm)
        
      }
      
    }
  }
  
  //TODO:// improved error handling, 只有其中一個 request 發生 error 的時候不結束整個抓取資料的程序
  //例如 dailyQuote 崩潰的時候，仍然顯示天氣預報。
  //
  private func updateLocalData(completion: @escaping (Quote?, PLErrorProtocol?, Forecast?, PLErrorProtocol?) -> Void) {
    guard isUpdatingLocaldata == false else {
      return //cancel upate for this time
    }
    
    var quote: Quote? = nil
    var forecast: Forecast? = nil
    var quoteUpdatedError: PLErrorProtocol? = nil
    var forecastUpdatedError: PLErrorProtocol? = nil
    
    //asyncly fire remoteRequest
    updateLocalQuote { updatedQuote, error in
      
      quoteUpdatedError = error
      quote = updatedQuote
      
      if self.isUpdatingLocaldata == false {
        completion(quote, quoteUpdatedError, forecast, forecastUpdatedError)
      } else {
        print("wait for update local forecast")
      }
    }
    updateLocalForecast { updatedForecast, error in
      
      forecastUpdatedError = error
      forecast = updatedForecast
      
      if self.isUpdatingLocaldata == false {
        completion(quote, quoteUpdatedError, forecast, forecastUpdatedError)
      } else {
        print("wait for update local quote")
      }
    }
    
  }
  
  private func updateLocalForecast(completion: @escaping (Forecast?, PLErrorProtocol?) -> Void) {
    isUpdatingLocalForecast = true
    remoteStore.fetchForecast { (forecast, error) in
      guard let remoteForecast = forecast else {
        self.isUpdatingLocalForecast = false
        completion(nil, error) //web related error
        return
      }
      
      if let lastupdate = self.localStore.lastupdateDateForForecast,
        lastupdate >= remoteForecast.lastupdate {
        self.isUpdatingLocalForecast = false
        completion(nil, nil)
        return
      }
      
      self.localStore.insertForecast(remoteForecast) { (error) in
        guard error == nil else {
          self.isUpdatingLocalForecast = false
          completion(nil, error) //local data store related error
          return
        }
        
        //happy path
        self.isUpdatingLocalForecast = false
        completion(remoteForecast, nil)
        
      }
      
    }
  }
  
  private func updateLocalQuote(completion: @escaping (Quote?, PLErrorProtocol?) -> Void) {
    isUpdatingLocalQuote = true
    remoteStore.fetchDaliyQuote { (quote, error) in
      guard let remoteQuote = quote else {
        self.isUpdatingLocalQuote = false
        completion(nil, error) //web related error
        return
      }
      
      if let lastupdate = self.localStore.lastupdateDateForQuote,
        lastupdate >= remoteQuote.date {
        //no need for update
        self.isUpdatingLocalQuote = false
        completion(nil, nil)
        return
      }
      
      self.localStore.insertDailyQuote(remoteQuote) { (error) in
        guard error == nil else {
          self.isUpdatingLocalQuote = false
          completion(nil, error) //local store related error
          return
        }
        
        //happy path
        self.isUpdatingLocalQuote = false
        completion(remoteQuote, nil)
        
      }
      
    }
  }
  
}

// MARK: - Presentation logic such as formatting string/Date into string user will see
extension WeatherController {
  func getDisplayedQuote(from quote: Quote) -> DisplayedQuote {
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
  
  func getDisplayedWeather(from weather: Weather) -> DisplayedWeather {
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
                            hightestTemprature: displayedHighestTempratrue,
                            lowestTemprature: displayedLowestTemprature,
                            iconDescription: weather.iconDescription.stringRep)
    
  }
  
  func getWeatherQuoteViewModel(quote: Quote?,
                                quoteError: PLErrorProtocol?,
                                forecast: Forecast?,
                                forecastError: PLErrorProtocol?) -> WeatherQuoteViewModel {
    
    if let quote = quote, let forecast = forecast {
      let vm = getSuccessWeatherQuoteVM(quote: quote, forecast: forecast)
      return vm
      
    } else if let quote = quote, let forecastError = forecastError {
      let vm = getWeatherFailedWeatherQuoteVM(quote: quote, forecastError: forecastError)
      return vm
      
    } else if let quoteError = quoteError, let forecast = forecast {
      let vm = getQuoteFailedWeatherQuoteVM(quoteError: quoteError, forecast: forecast)
      return vm
      
    } else if let quoteError = quoteError, let forecastError = forecastError {
      let vm = getFailedWeatherQuoteVM(quoteError: quoteError, forecastError: forecastError)
      return vm
    
    } else {
      fatalError() //unexpect path
    }
    
    
    return WeatherQuoteViewModel()
  }
  
  private func getSuccessWeatherQuoteVM(quote: Quote, forecast: Forecast) -> WeatherQuoteViewModel {
    
    let displayedQuote = getDisplayedQuote(from: quote)
    let displayedForecast = getDisplayedForecast(from: forecast)
    
    let vm = WeatherQuoteViewModel(displayedQuote:displayedQuote,
                                   displayedForecast: displayedForecast,
                                   displayedError: nil)
    return vm
  }
  
  private func getFailedWeatherQuoteVM(quoteError: PLErrorProtocol,
                                       forecastError: PLErrorProtocol) -> WeatherQuoteViewModel {
    
    //let forecastDebugInfo = "\(forecastError.domain):code\(forecastError.code)"
    //let quoteDebugInfo = "\(quoteError.domain):code\(quoteError.code)"
    
    let displayedError = DisplayedError(title: "抓取資料錯誤", errorMessage: "無法抓取天氣預報和每日一句資料")
    // TODO:// displayedQuote, displayedForecast 不該回傳nil, 應該回傳 UI 上的 edge case
    let vm = WeatherQuoteViewModel(displayedQuote: nil, displayedForecast: nil, displayedError: displayedError)
    
    return vm
    
  }
  
  private func getQuoteFailedWeatherQuoteVM(quoteError: PLErrorProtocol,
                                            forecast: Forecast) -> WeatherQuoteViewModel {
    let displayedError = DisplayedError(title: "無法抓取每日一句", errorMessage: quoteError.localizedDescription)
    let displayedForecast = getDisplayedForecast(from: forecast)
    // TODO:// displayedQuote 不該回傳nil, 應該回傳 UI 上的 edge case
    let vm = WeatherQuoteViewModel(displayedQuote: nil,
                                   displayedForecast: displayedForecast,
                                   displayedError: displayedError)
    
    return vm
  }
  
  private func getWeatherFailedWeatherQuoteVM(quote: Quote,
                                      forecastError: PLErrorProtocol) -> WeatherQuoteViewModel {
    let displayedQuote = getDisplayedQuote(from: quote)
    let displayedError = DisplayedError(title: "無法抓取氣象資料", errorMessage: forecastError.localizedDescription)
    // TODO:// displayedForecast 不該回傳nil, 應該回傳 UI 上的 edge case
    let vm = WeatherQuoteViewModel(displayedQuote: displayedQuote,
                                   displayedForecast: nil,
                                   displayedError: displayedError)
    
    return vm
  }
  
  
}


//MARK: - dependency injection
struct WatherControllerInjectionWrapper {
  var localStore: WeatherQuoteLocalStoreProtocol? = nil
  var remoteStore: WeatherQuoteStoreProtocol? = nil
  
  init(localStore: WeatherQuoteLocalStoreProtocol? = nil, remoteStore: WeatherQuoteStoreProtocol? = nil) {
    self.localStore = localStore
    self.remoteStore = remoteStore
  }
}

extension WeatherController: Injectable {
  typealias T = WatherControllerInjectionWrapper
  func inject(_ injected: WatherControllerInjectionWrapper) {
    if let localStore = injected.localStore {
      self.localStore = localStore
    }
    
    if let remoteStore = injected.remoteStore {
      self.remoteStore = remoteStore
    }
    
  }
}


