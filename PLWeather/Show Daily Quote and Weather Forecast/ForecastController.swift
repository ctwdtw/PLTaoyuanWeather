//
//  WeatherController.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/18.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation

protocol ForecastControllerProtocol {
  var forecast: Forecast? { get }
  var quote: Quote? { get }
}

class ForecastController {
  private var localStore: ForecastLocalStoreProtocol = CoreDataStore()
  private var remoteStore: ForecastStoreProtocol = APIDataStore()
  var forecast: Forecast?
  var quote: Quote?
  
  private let presenter = ForecastPresenter()
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
  
  deinit {
    deinitMessage(from: self)
  }
  
}


//業務邏輯
//a. fetchOnLoad
//  1. show local 資料給 view, 打包好 Local Quote & Local Forecast 給 View
//  2. 由 remote 端抓取資料, 若比 Local 端新, 就插入資料進入 CoreData
//  3. 將最新資料傳遞給 View
//b. pull to fetch
//  1. 由 remote 端抓取資料，若比資料目前的新，就更新資料並展示，否則return掉。

extension ForecastController: ForecastControllerProtocol {
  
  func deleteWeather(at indexPath: IndexPath, completion: @escaping (_ updatedForecast: DisplayedForecast?, DisplayedError?) -> Void) {
    guard let forecast = forecast else {
      fatalError()
    }
    
    localStore.deleteWeather(at: indexPath.row, of: forecast) { [weak self] (updatedForecast, error) in
      self?.forecast = updatedForecast
      
      guard let updatedForecast = updatedForecast else {
        let displayedError = DisplayedError(shouldShow: true,
                                            title: error!.domain,
                                            errorMessage: error!.localizedDescription)
        
        completion(nil, displayedError)
        return
      }
      
      let displayedForecast = self?.presenter.getDisplayedForecast(from: updatedForecast)
      completion(displayedForecast, nil)
      
    }
    
  }
  
  func fetchDataOnLoad(completion: @escaping (ForecastQuoteViewModel) -> Void) {
    fetchLocalQuoteAndForecast { (vm) in
      completion(vm)
    }
  }
  
  func refreshData(completion: @escaping (ForecastQuoteViewModel) -> Void) {
    updateLocalData { [weak self] updatedQuote, quoteUpdatedError, updatedForecast, forecastUpdatedError in
      
      if let vm = self?.presenter.getForecastQuoteViewModel(updatedQuote: updatedQuote,
                                                            oldQuote: self?.quote,
                                                            quoteError: quoteUpdatedError,
                                                            updatedForecast: updatedForecast,
                                                            oldForecast: self?.forecast,
                                                            forecastError: forecastUpdatedError) {
        
        completion(vm)
      }
    }
  }
  
  private func fetchLocalQuoteAndForecast(completion: @escaping (ForecastQuoteViewModel) -> Void) {
    localStore.fetchDaliyQuote { [weak self] (quote, quoteError) in
      
      self?.localStore.fetchForecast { [weak self] (forecast, forecastError) in
        
        self?.quote = quote
        self?.forecast = forecast
        if let vm = self?.presenter.getForecastQuoteViewModel(updatedQuote: quote,
                                                              oldQuote: self?.quote,
                                                              quoteError: quoteError,
                                                              updatedForecast: forecast,
                                                              oldForecast: self?.forecast,
                                                              forecastError: forecastError) {
          completion(vm)
        }
      }
    }
  }
  
  private func updateLocalData(completion: @escaping (Quote?, PLErrorProtocol?, Forecast?, PLErrorProtocol?) -> Void) {
//    guard isUpdatingLocaldata == false else {
//      print("cancle update this time")
//      return //cancel upate for this time
//    }
    
    var quote: Quote? = nil
    var forecast: Forecast? = nil
    var quoteUpdatedError: PLErrorProtocol? = nil
    var forecastUpdatedError: PLErrorProtocol? = nil
    
    //asynchronously fire remoteRequest
    updateLocalQuote { [weak self] updatedQuote, error in
      guard self?.isUpdatingLocalQuote == false else {
        print("cancel update local quote this time")
        return
      }
      
      quoteUpdatedError = error
      quote = updatedQuote
      
      completion(quote, quoteUpdatedError, forecast, forecastUpdatedError)
      print("updatedLocalQuote with completion executed.")
      
    }
    
    updateLocalForecast { [weak self] updatedForecast, error in
      guard self?.isUpdatingLocalForecast == false else {
        print("cancel update local forecast this time")
        return
      }
      
      forecastUpdatedError = error
      forecast = updatedForecast
      
      completion(quote, quoteUpdatedError, forecast, forecastUpdatedError)
      print("updatedLocalForecast with completion executed")
      
    }
    
  }
  
  private func updateLocalForecast(completion: @escaping (Forecast?, PLErrorProtocol?) -> Void) {
    isUpdatingLocalForecast = true
    remoteStore.fetchForecast { [weak self] (forecast, error) in
      guard let remoteForecast = forecast else {
        self?.isUpdatingLocalForecast = false
        completion(nil, error) //web related error
        return
      }
      
      self?.localStore.insertForecast(remoteForecast) { [weak self] (insteredForecast, error) in
        guard error == nil else {
          self?.isUpdatingLocalForecast = false
          completion(nil, error) //local data store related error
          return
        }
        
        //happy path
        self?.isUpdatingLocalForecast = false
        self?.forecast = insteredForecast
        completion(remoteForecast, nil)
        
      }
      
    }
  }
  
  private func updateLocalQuote(completion: @escaping (Quote?, PLErrorProtocol?) -> Void) {
    isUpdatingLocalQuote = true
    remoteStore.fetchDaliyQuote { [weak self] (quote, error) in
      guard let remoteQuote = quote else {
        self?.isUpdatingLocalQuote = false
        completion(nil, error) //web related error
        return
      }
      
      self?.localStore.insertDailyQuote(remoteQuote) { [weak self] (insertedQuote, error) in
        guard error == nil else {
          self?.isUpdatingLocalQuote = false
          completion(nil, error) //local store related error
          return
        }
        
        //happy path
        self?.isUpdatingLocalQuote = false
        self?.quote = insertedQuote
        completion(remoteQuote, nil)
        
      }
      
    }
  }
  
}


//MARK: - dependency injection
struct WatherControllerInjectionWrapper {
  var localStore: ForecastLocalStoreProtocol? = nil
  var remoteStore: ForecastStoreProtocol? = nil
  
  init(localStore: ForecastLocalStoreProtocol? = nil, remoteStore: ForecastStoreProtocol? = nil) {
    self.localStore = localStore
    self.remoteStore = remoteStore
  }
}

extension ForecastController: Injectable {
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
