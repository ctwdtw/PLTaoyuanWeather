//
//  ManagedQuote+CoreDataClass.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/19.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//
//

import Foundation
import CoreData

class ManagedQuote: NSManagedObject {}
//convert to struct model
extension ManagedQuote {
  func toQuote() -> Quote {
    return Quote(id: self.id,
                 date: self.date as Date,
                 author: self.author,
                 quote: self.quote)
  }
  
  func fromQuote(quote: Quote) {
    self.id = quote.id
    self.date = quote.date as NSDate
    self.author = quote.author
    self.quote = quote.quote
  }
}
