//
//  CoreDataError.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/28.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
enum CoreDataError: PLErrorProtocol {
  case cannotFetch(Error)
  case cannotInsert(Error)
  case cannotDelete(Error)
  case noNeedToUpdateForecast
  case noNeedToUpdateQuote
  case noNeedToUpdateData
}

extension CoreDataError {
  var domain: String { return PLErrorDomain.coreData }
}

extension CoreDataError {
  var code: Int {
    switch self {
    case .cannotFetch(let error as NSError):
      return error.code
      
    case .cannotInsert(let error as NSError):
      return error.code

    case .cannotDelete(let error as NSError):
      return error.code
    
    case .noNeedToUpdateForecast:
      return -1002
    
    case .noNeedToUpdateQuote:
      return -1001
    
    case .noNeedToUpdateData:
      return -1003
    }
    
  }
}

extension CoreDataError {
  func toNSError() -> NSError {
    let userInfo = [NSLocalizedDescriptionKey: localizedDescription]
    return NSError(domain: domain, code: code, userInfo: userInfo)
  }
}

//TODO : - multi language
extension CoreDataError {
  var localizedDescription: String {
    switch self {
    case .cannotFetch(let error as NSError):
      return error.localizedDescription
    case .cannotInsert(let error as NSError):
      return error.localizedDescription
    case .cannotDelete(let error as NSError):
      return error.localizedDescription
    case .noNeedToUpdateForecast:
      return "不需更新氣象資料"
    case .noNeedToUpdateQuote:
      return "不需更新每日一句"
    case .noNeedToUpdateData:
      return "不需更新資料"
    }
  }
}






