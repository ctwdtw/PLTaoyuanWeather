//
//  InjectableProtocol.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/30.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
protocol Injectable {
  associatedtype T
  func inject(_ injected: T)
}

