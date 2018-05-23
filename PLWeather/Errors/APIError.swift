//
//  APIError.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/5/22.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
enum APIError: PLErrorProtocol {
  case noNeedToUpdateQuote
  case noNeedToUpdateForecast
}

extension APIError {
  var domain: String { return PLErrorDomain.apiStore }
}

extension APIError {
  var code: Int {
    switch self {
    case .noNeedToUpdateQuote:
      return -1001
    case .noNeedToUpdateForecast:
      return -1002
    }
  }
}

extension APIError {
  func toNSError() -> NSError {
    let userInfo = [NSLocalizedDescriptionKey: localizedDescription]
    return NSError(domain: domain, code: code, userInfo: userInfo)
  }
}

//TODO;//multi langue
extension APIError {
  var localizedDescription: String {
    switch self {
    case .noNeedToUpdateForecast:
      return "不需更新氣象資料"
    case .noNeedToUpdateQuote:
      return "不需更新每日一句"
    }
  }
}

