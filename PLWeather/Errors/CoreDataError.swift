//
//  CoreDataError.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/28.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
enum CoreDataError: PLErrorProtocol {
  //case emptyFetch
  case uninterpretedError(Error)
}

extension CoreDataError {
  var domain: String { return PLErrorDomain.coreData }
}

extension CoreDataError {
  var code: Int {
    switch self {
//    case .emptyFetch:
//      return  -10002
    case .uninterpretedError(let error as NSError):
      return error.code
      
    }
  }
}

extension CoreDataError {
  func toNSError() -> NSError {
    let userInfo = [NSLocalizedDescriptionKey: localizedDescription]
    return NSError(domain: domain, code: code, userInfo: userInfo)
  }
}


extension CoreDataError {
  static func error(from nsCoreDataError: Error) -> PLErrorProtocol {
    return CoreDataError.uninterpretedError(nsCoreDataError)
  }
}


//TODO : - multi language
extension CoreDataError {
  var localizedDescription: String {
    switch self {
//    case .emptyFetch:
//      return  "沒有資料"
    case .uninterpretedError(let error as NSError):
      return error.localizedDescription
      
    }
  }
}






