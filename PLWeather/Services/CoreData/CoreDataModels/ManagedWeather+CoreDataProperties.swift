//
//  ManagedWeather+CoreDataProperties.swift
//  
//
//  Created by Paul Lee on 2018/4/26.
//
//

import Foundation
import CoreData

extension ManagedWeather {
  //@NSManaged var id: String
  @NSManaged var date: NSDate
  @NSManaged var highestTemprature: Int16
  @NSManaged var lowestTemprature: Int16
  @NSManaged var managedForecast: ManagedForecast
}


extension ManagedWeather {
  class func fetchRequest() -> NSFetchRequest<ManagedWeather> {
    return NSFetchRequest<ManagedWeather>(entityName: "ManagedWeather")
  }
  
  static var defaultSortDescriptor: [NSSortDescriptor] {
    let sortDescriptorForDate = NSSortDescriptor(key: "date", ascending: true)
    let sortDescriptorForDayOrNight = NSSortDescriptor(key: "dayOrNightValue", ascending: true)
    return [sortDescriptorForDate, sortDescriptorForDayOrNight]
  }
  static var defaultSortedFetchRequest: NSFetchRequest<ManagedWeather> {
    let request: NSFetchRequest<ManagedWeather> = ManagedWeather.fetchRequest()
    request.sortDescriptors = defaultSortDescriptor
    return request
  }

}
