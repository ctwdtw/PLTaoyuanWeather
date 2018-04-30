//
//  PLErrorProtocol.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/28.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
protocol PLErrorProtocol: Error {
  var domain: String { get }
  var code: Int { get }
  var localizedDescription: String { get }
  func toNSError() -> NSError
}
