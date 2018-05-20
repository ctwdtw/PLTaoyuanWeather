//
//  Weather.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/18.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation

enum WeekDay: Int {
  case sun = 1
  case mon
  case tue
  case wed
  case thu
  case fri
  case sat
  
  init(weekDay: Int) {
    switch weekDay {
    case 1: self = .sun
    case 2: self = .mon
    case 3: self = .thu
    case 4: self = .wed
    case 5: self = .thu
    case 6: self = .fri
    case 7: self = .sat
    case 8: self = .sun
    default:
      fatalError()
    }
  }
  
}

//TODO:// multi language
extension WeekDay {
  var stringRep: String {
    switch self {
    case .sun: return "星期日"
    case .mon: return "星期ㄧ"
    case .tue: return "星期二"
    case .wed: return "星期三"
    case .thu: return "星期四"
    case .fri: return "星期五"
    case .sat: return "星期六"
    }
  }
  
}

enum WeatherDescription {
  case sunny
  case sunnyWithCloud
  case cloudyWtihSun
  case cloudyLittleSun
  case cloudy
  case cloudyLittleSunAndRain
  case rainy
  case stormy
  case snowy
  case unknown(String)
  
  init(string: String) {
    if string == "晴" {
      self = .sunny
    } else if string == "晴時多雲" {
      self = .sunnyWithCloud
    } else if string == "多雲時晴" {
      self = .cloudyWtihSun
    } else if string == "多雲" || string == "多雲時陰" {
      self = .cloudyLittleSun
    } else if string == "陰天" || string == "陰時多雲" {
      self = .cloudy
    } else if string == "多雲時陰短暫雨" || string == "多雲短暫雨" {
      self = .cloudyLittleSunAndRain
    } else if string == "陰時有雨" || string == "陰時多雲短暫雨" || string == "陰短暫雨" {
      self = .rainy
    } else if string.contains("暴雨") {
      self = .stormy
    } else if string.contains("雪") {
      self = .snowy
    } else {
      self = .unknown(string)
    }
  }
  
  init(rawValue: Int, associatedValue: Any? = nil) {
    switch rawValue {
    case 0: self = .sunny
    case 1: self = .sunnyWithCloud
    case 2: self = .cloudyWtihSun
    case 3: self = .cloudyLittleSun
    case 4: self = .cloudy
    case 5: self = .cloudyLittleSunAndRain
    case 6: self = .rainy
    case 7: self = .stormy
    case 8: self = .snowy
    case 9: self = .unknown(associatedValue as! String)
    default:
      self = .unknown("未知的天氣")
    }
  }
  
}

extension WeatherDescription {
  var rawValue: Int {
    switch self {
    case .sunny: return 0 // 晴
    case .sunnyWithCloud: return 1  // 晴時多雲
    case .cloudyWtihSun: return 2     // 多雲時晴
    case .cloudyLittleSun: return 3    // 多雲、多雲時陰
    case .cloudy: return 4          // 陰天、陰時多雲
    case .cloudyLittleSunAndRain: return 5  // 多雲時陰短暫雨、多雲短暫雨
    case .rainy: return 6           // 陰時有雨、陰時多雲短暫雨
    case .stormy: return 7          // 有“暴雨”字
    case .snowy: return 8           // 有“雪”字
    case .unknown: return 9
    }
  }
}

extension WeatherDescription {
  var stringRep: String {
    switch self {
    case .sunny: return "☀️" // 晴
    case .sunnyWithCloud: return "🌤"  // 晴時多雲
    case .cloudyWtihSun: return "⛅️"     // 多雲時晴
    case .cloudyLittleSun: return "🌥"    // 多雲、多雲時陰
    case .cloudy: return "☁️"          // 陰天、陰時多雲
    case .cloudyLittleSunAndRain: return "🌦"  // 多雲時陰短暫雨、多雲短暫雨
    case .rainy: return "🌧"           // 陰時有雨、陰時多雲短暫雨
    case .stormy: return "⛈"          // 有“暴雨”字
    case .snowy: return "❄️"           // 有“雪”字
    case .unknown(let value): return "❓：\(value)"
    }
  }
}


enum DayOrNight: Int {
  case day = 0
  case night
  
  init(string: String) {
    if string == "白天" {
      self = .day
    } else {
      self = .night
    }
  }
  
}

extension DayOrNight {
  var stringRep: String {
    switch self {
    case .day: return "Day"
    case .night: return "Night"
    }
  }
}


struct Weather {
  let date: Date
  let weekDay: WeekDay
  let dayOrNight: DayOrNight
  let highestTemprature: Int
  let lowestTemprature: Int
  let iconDescription: WeatherDescription
}

struct Forecast {
  let lastupdate: Date
  let weathers: [Weather]
}

struct Quote {
  let id: String
  let date: Date!
  let author: String!
  let quote: String
  public enum SpecialCases {
    case empty
    case suspen
  }

  static func empty() -> Quote {
    return Quote(id: Quote.SpecialCases.empty.id,
                 date: Quote.SpecialCases.empty.date,
                 author: Quote.SpecialCases.empty.author,
                 quote: Quote.SpecialCases.empty.quote)
  }
  static func suspen() -> Quote {
    return Quote(id: Quote.SpecialCases.suspen.id,
                 date: Quote.SpecialCases.suspen.date,
                 author: Quote.SpecialCases.suspen.author,
                 quote: Quote.SpecialCases.suspen.quote)
  }
}

//MARK: - special case property values
extension Quote.SpecialCases {
  var id: String {
    switch self {
    case .empty:
      return "empty"
    case .suspen:
      return "suspen"
    }
  }

  var date: Date! {
    switch self {
    case .empty:
      return nil
    case .suspen:
      return Date()
    }
  }

  var author: String!{
    switch self {
    case .empty:
      return nil
    case .suspen:
      return nil
    }
  }

  var quote: String {
    switch self {
    case .empty:
      return "尚無資料"
    case .suspen:
      return "每日一句停刊一天"
    }
  }

}




