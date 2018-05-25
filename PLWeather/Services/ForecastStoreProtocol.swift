//
//  WeatherQuoteStoreProtocol.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/5/21.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
//protocol for remote store
protocol ForecastStoreProtocol {
  func fetchForecast(completion: @escaping (Forecast?, PLErrorProtocol?) -> Void)
  func fetchDaliyQuote(completion: @escaping (Quote?, PLErrorProtocol?) -> Void)
  
}

struct LastupdateTime: Codable {
  var forQuote: Date?
  var forForecast: Date?
}

//protocol for local store
protocol ForecastLocalStoreProtocol: ForecastStoreProtocol {
  var lastupdateDate: LastupdateTime { get }
  func insertDailyQuote(_ quote: Quote, completion: @escaping (_ insertedQuote: Quote?, PLErrorProtocol?) -> Void )
  func insertForecast(_ forecast: Forecast, completion: @escaping (_ insertedForecast: Forecast? ,PLErrorProtocol?) -> Void )
  func deleteWeather(at index: Int, of forecast: Forecast,
                     completion: @escaping (_ updatedForecast: Forecast?, PLErrorProtocol?) -> Void)
}
