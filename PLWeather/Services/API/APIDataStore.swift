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
  
}

extension APIDataStore: WeatherQuoteStoreProtocol {
  
  func fetchForecast(completion: @escaping (Forecast?, PLErrorProtocol?) -> Void) {
    fetchforecastXMLByAF { (xmlString, error) in
      guard let xmlString = xmlString else {
        completion(nil, NetworkError.error(from: error!))
        return
      }
      
      do {
        let forecast = try self.getParsedForecast(from: xmlString)
        completion(forecast, nil)
      } catch {
        let e = error as! PLErrorProtocol
        completion(nil, e) //return parsing error
      }
    
    }
  }
  
  func fetchDaliyQuote(completion: @escaping (Quote?, PLErrorProtocol?) -> Void) {
    fetchDailyQuoteHtmlStringByAF { (htmlString, error) in
      guard let htmlString = htmlString else {
        completion(nil, NetworkError.error(from: error!))
        return
      }
      
      do {
        let quote = try self.getParsedDailyQuote(from: htmlString)
        completion(quote, nil)
      } catch {
        let e = error as! PLErrorProtocol
        completion(nil, e) //return parsing error
      }
      
    }
  }
  
}
// MARK: - network

//network private
extension APIDataStore {
  private func fetchDailyQuoteHtmlStringByAF(completion: @escaping (String?, PLErrorProtocol?) -> Void) {
    Alamofire.request(dailyQuoteUrlString).validate().responseString(queue: DispatchQueue.global()) { (response) in
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
    Alamofire.request(weatherUrlString).validate().responseString(queue: DispatchQueue.global(), encoding: .utf8) { (response) in
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

//MARK: - parsing, can be stuff into a class
struct ParsingConst {
  //quote
  static let article = "dphs"
  static let quote = "p"
  static let author = "h1"
  static let datetime = "time"
  
  //forecast
  static let lastupdate = "pubDate"
  static let weathers = "description"
}

extension APIDataStore {
  func getParsedDailyQuote(from htmlString: String) throws -> Quote {
    let doc = try SwiftSoup.parse(htmlString)
    guard let body = doc.body() else {
      throw ParsingError.dailyQuoteHtmlHasNoBody
    }
    
    guard let article = try body.getElementsByClass(ParsingConst.article).first() else {
      throw ParsingError.dailyQuoteHtmlHasNoArticle
    }
    
    guard let datetime = try article.select(ParsingConst.datetime).first() else {
      return Quote.suspen()
      //throw ParsingError.dailyQuoteSuspend
    }
    
    guard let author = try article.select(ParsingConst.author).first() else {
      throw ParsingError.dailyQuoteHtmlHasNoArticle
    }
    
    guard let quote = try article.select(ParsingConst.quote).first() else {
      throw ParsingError.dailyQuoteHtmlHasNoArticle
    }
    
    //id
    let dateTimeText = try datetime.text()
    
    //date
    let date = Date.quoteDate(from: dateTimeText)
    
    //author
    let datetimeHTML = try datetime.outerHtml()
    let authorHTML = try author.html()
    let startIdx = authorHTML.startIndex
    let endIdx = authorHTML.range(of: datetimeHTML)!.lowerBound
    let authorText = String(authorHTML[startIdx..<endIdx])
    
    //quote
    let quoteText = try quote.text()
    //quote.id = "20150520", something like this.
    return Quote(id: dateTimeText, date: date, author: authorText, quote: quoteText)
    
  }
    
  func getParsedForecast(from xmlString: String) throws -> Forecast  {
    guard let xml = try? SwiftSoup.parse(xmlString, "", Parser.xmlParser()) else {
      throw ParsingError.cannotParseXML
    }
    
    guard let lastupdateString = try xml.getElementsByTag(ParsingConst.lastupdate).first()?.text() else {
      throw ParsingError.forecastHasNoLastupadate
    }
    
    let date = Date.forecastDate(from: lastupdateString)
    
    guard let weathersRawString = try xml.getElementsByTag(ParsingConst.weathers).last()?.text() else {
      throw ParsingError.cannotParseXML
    }
    
    let weathers = getWeathers(from: weathersRawString, forecastDate: date)
    
    return Forecast(lastupdate: date, weathers: weathers)
  }
  
  //normal case
  //04/25 白天 溫度:21 ~ 22 多雲<BR>
  //04/25 晚上 溫度:19 ~ 21 多雲<BR>
  //04/26 白天 溫度:19 ~ 27 多雲時晴<BR>
  //04/26 晚上 溫度:20 ~ 24 晴時多雲<BR>
  //04/27 白天 溫度:20 ~ 28 多雲<BR>
  //04/27 晚上 溫度:21 ~ 25 多雲<BR>
  
  //edge case:
  //12/31 晚上 溫度:23 ~ 27 多雲<BR>
  //01/01 白天 溫度:23 ~ 27 多雲<BR>
  //01/01 晚上 溫度:23 ~ 27 多雲<BR>
  //01/02 白天 溫度:23 ~ 27 多雲<BR>
  //01/02 晚上 溫度:23 ~ 27 多雲<BR>
  //01/03 白天 溫度:23 ~ 27 多雲<BR>
  private func getWeathers(from weathersRawString: String, forecastDate: Date) -> [Weather] {
    //clean raw data
    let weatherRawStrings = weathersRawString.components(separatedBy: "<BR>").dropLast().map {
      $0.replacingOccurrences(of: "溫度:", with: "")
        .replacingOccurrences(of: " ~", with: "")
        .replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
    }
    
    let forecastYear = forecastDate.year()
    let forecastMonth = forecastDate.month()
    
    let cleanedWeatherRawStrs: [String] = weatherRawStrings.map {
      if getMothInt($0) < forecastMonth {
        return "\(forecastYear+1)/\($0)"
      }
      
      return  "\(forecastYear)/\($0)"
    }
    
    //convert to Weather, each input is like "2018/12/26 白天 21 22 多雲"
    let weathers: [Weather] = cleanedWeatherRawStrs.map { (cleanedRawStr) in
      let inputs = cleanedRawStr.components(separatedBy: " ")
      let date = Date.weatherDate(from: inputs[0])
      let weekDay = WeekDay(weekDay: date.weekDay())
      let dayOrnight = DayOrNight(string: inputs[1])
      guard let lowestTemprature = Int(inputs[2]) else { fatalError() }
      guard let hightestTemprature = Int(inputs[3]) else { fatalError() }
      let weatherDescription = WeatherDescription(string: inputs[4])
      return Weather(date: date,
                     weekDay: weekDay,
                     dayOrNight: dayOrnight,
                     highestTemprature: hightestTemprature,
                     lowestTemprature: lowestTemprature,
                     iconDescription: weatherDescription)
    }
    
    return weathers
  }
  
  private func getMothInt(_ weatherRawStr: String) -> Int {
    let startIdx = weatherRawStr.startIndex
    let endIdx = weatherRawStr.index(startIdx, offsetBy: 2)
    guard let monthInt = Int(weatherRawStr[..<endIdx]) else { fatalError("paringError") }
    return monthInt
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
