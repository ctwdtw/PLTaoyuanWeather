//
//  APIError.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/28.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
import Alamofire
enum NetworkError: PLErrorProtocol {
  case couldNotConnectToInternet
  case cannotConnectToHost
  case requestTimedOut
  case invalidStatusCode(code: Int)
  case uninterpreatedError(Error)
}

extension NetworkError {
  var domain: String {return PLErrorDomain.apiStore}
}

extension NetworkError {
  var code: Int {
    switch self {
    case .couldNotConnectToInternet:
      return NSURLErrorNotConnectedToInternet
    case .cannotConnectToHost:
      return NSURLErrorCannotConnectToHost
    case .requestTimedOut:
      return NSURLErrorTimedOut
    case .invalidStatusCode(let statusCode):
      return statusCode
    case .uninterpreatedError(let error):
      return (error as NSError).code
    }
  }
}

extension NetworkError {
  func toNSError() -> NSError {
    let userInfo = [NSLocalizedDescriptionKey: localizedDescription]
    return NSError(domain: domain, code: code, userInfo: userInfo)
  }
}

extension NetworkError {
  static func error(from error: Error) -> PLErrorProtocol {
    
    if let aferror = error as? AFError {
      switch aferror {
      case AFError.responseValidationFailed(reason: .unacceptableStatusCode(let code)):
        return NetworkError.invalidStatusCode(code: code)
      default:
        return NetworkError.uninterpreatedError(error)
      }
    }
    
    let nserror = error as NSError
    if nserror.domain == NSURLErrorDomain {
      switch nserror.code {
      case NSURLErrorNotConnectedToInternet:
        return NetworkError.couldNotConnectToInternet
      case NSURLErrorCannotConnectToHost:
        print("")
      case NSURLErrorTimedOut:
        print("")
      default:
        return NetworkError.uninterpreatedError(error)
      }
      
    }
    
    return NetworkError.uninterpreatedError(error)
    
  }
}

//TODO:// - multi langu
extension NetworkError {
  var localizedDescription: String {
    switch self {
    case .couldNotConnectToInternet:
      return "無法連接至Internet，請檢查是否有開啟行動數據或wifi"
    case .cannotConnectToHost:
      return "無法與伺服器連線。"
    case .requestTimedOut:
      return "連線逾時，"
    case .invalidStatusCode(let code):
      return "不正確的 statusCode: \(code)"
    case .uninterpreatedError(let error):
      return error.localizedDescription
    }
  }
}


