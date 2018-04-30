//
//  ManagedQuote+CoreDataProperties.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/19.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//
//

import Foundation
import CoreData

extension ManagedQuote {
  @NSManaged var id: String
  @NSManaged var date: NSDate
  @NSManaged var quote: String
  @NSManaged var author: String!
}

extension ManagedQuote {
  class func fetchRequest() -> NSFetchRequest<ManagedQuote> {
    return NSFetchRequest<ManagedQuote>(entityName: "ManagedQuote")
  }
  static var defaultSortDescriptor: [NSSortDescriptor] {
    return [NSSortDescriptor(key: "date", ascending: false)]
  }
  static var dateSortedFetchRequest: NSFetchRequest<ManagedQuote> {
    let request: NSFetchRequest<ManagedQuote> = ManagedQuote.fetchRequest()
    request.sortDescriptors = defaultSortDescriptor
    return request
  }
}
