//
//  ParsingError.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/28.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation

enum ParsingError: Int, PLErrorProtocol {
  //quote
  case cannotParseHtml = -10001
  case dailyQuoteHtmlHasNoBody = -1003
  case dailyQuoteHtmlHasNoArticle = -1005
  //case dailyQuoteSuspend = -1006
  //weather
  case cannotParseXML = -1002
  case forecastHasNoLastupadate = -1004
  case forecastDoesNotContainWeathers = 1006
}

extension ParsingError {
  var domain: String {
    return PLErrorDomain.xmlParser
  }
}

extension ParsingError {
  var code: Int {
    return self.rawValue
  }
}

extension ParsingError {
  func toNSError() -> NSError {
    let userInfo = [NSLocalizedDescriptionKey: localizedDescription]
    return NSError(domain: domain, code: code, userInfo: userInfo)
  }
}

//TODO: - multi language
extension ParsingError {
  var localizedDescription: String {
    switch self {
    case .cannotParseHtml, .dailyQuoteHtmlHasNoBody, .dailyQuoteHtmlHasNoArticle:
      return "無法解析每日一句資料。"
    case .cannotParseXML, .forecastHasNoLastupadate, .forecastDoesNotContainWeathers:
      return "無法解析天氣資料。"
//    case .dailyQuoteSuspend:
//      return "每日一句今日休刊"
    }
  }
}
