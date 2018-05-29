//
//  RomoteDataManager.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/18.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSoup

class APIDataStore {
  private(set) var dailyQuoteUrlString = "https://tw.appledaily.com/index/dailyquote/"
  private(set) var weatherUrlString = "https://www.cwb.gov.tw/rss/forecast/36_05.xml"
  let manager = Alamofire.SessionManager.default
  
  deinit {
    deinitMessage(from: self)
  }
  
}

extension Alamofire.SessionManager {
  func requestWithoutCache(
    _ url: URLConvertible,
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = URLEncoding.default,
    headers: HTTPHeaders? = nil)// also you can add URLRequest.CachePolicy here as parameter
    -> DataRequest
  {
    do {
    
      var urlRequest = try URLRequest(url: url, method: method, headers: headers)
      urlRequest.cachePolicy = .reloadIgnoringCacheData
      let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
      return request(encodedURLRequest)
    } catch {
      // TODO: find a better way to handle error
      print(error)
      return request(URLRequest(url: URL(string: "http://example.com/wrong_request")!))
    }

  }
}


extension APIDataStore: ForecastStoreProtocol {
  
  func fetchForecast(completion: @escaping (Forecast?, PLErrorProtocol?) -> Void) {
    fetchforecastXMLByAF { (xmlString, error) in
      guard let xmlString = xmlString else {
        DispatchQueue.main.async {
          completion(nil, error)
        }
        return
      }
      
      do {
        let forecast = try ForecastParser.getParsedForecast(from: xmlString)
        sleep(3)
        DispatchQueue.main.async {
          completion(forecast, nil)
        }
        
      } catch {
        let e = error as! PLErrorProtocol
        DispatchQueue.main.async {
          completion(nil, e) //return parsing error
        }
        
      }
    
    }
  }
  
  func fetchDaliyQuote(completion: @escaping (Quote?, PLErrorProtocol?) -> Void) {
    fetchDailyQuoteHtmlStringByAF { (htmlString, error) in
      guard let htmlString = htmlString else {
        DispatchQueue.main.async {
          completion(nil, error)
        }
        return
      }
      
      do {
        let quote = try ForecastParser.getParsedDailyQuote(from: htmlString)
        sleep(5)
        DispatchQueue.main.async {
          completion(quote, nil)
        }
        
      } catch {
        let e = error as! PLErrorProtocol
        DispatchQueue.main.async {
          completion(nil, e) //return parsing error
        }
        
      }
      
    }
  }
  
}
// MARK: - network

//network private
extension APIDataStore {
  private func fetchDailyQuoteHtmlStringByAF(completion: @escaping (String?, PLErrorProtocol?) -> Void) {
    manager.request(dailyQuoteUrlString).validate().responseString(queue: DispatchQueue.global()) { (response) in
      if let value = response.result.value {
        completion(value, nil)
      } else if let error = response.result.error {
        completion(nil, NetworkError.error(from: error))
      } else {
        assertionFailure("both value and error are nil")
      }
    }
  }
  
  private func fetchforecastXMLByAF(completion: @escaping (String?, PLErrorProtocol?) -> Void) {
    //.request(weatherUrlString).validate().responseString(encoding: .utf8) { (response) in
    manager.requestWithoutCache(weatherUrlString, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
      .validate().responseString(queue: DispatchQueue.global(), encoding: .utf8) { (response) in
      if let value = response.result.value {
        completion(value, nil)
      } else if let error = response.result.error {
        completion(nil, NetworkError.error(from: error))
      } else {
        assertionFailure("both value and error are nil")
      }
    }
  }
  
}



//MARK: - dependency injection
struct APIDataStoreInjectionWrapper {
  var dailyQuoteUrlString: String?
  var weatherUrlString: String?
  
  init(dailyQuoteUrlString: String? = nil, weatherUrlString: String? = nil) {
    self.dailyQuoteUrlString = dailyQuoteUrlString
    self.weatherUrlString = weatherUrlString
  }
}

extension APIDataStore: Injectable {
  typealias T = APIDataStoreInjectionWrapper
  
  func inject(_ injected: APIDataStoreInjectionWrapper) {
    if let inject = injected.dailyQuoteUrlString {
      self.dailyQuoteUrlString = inject
    }
    
    if let inject = injected.weatherUrlString {
      self.weatherUrlString = inject
    }
    
  }
}
