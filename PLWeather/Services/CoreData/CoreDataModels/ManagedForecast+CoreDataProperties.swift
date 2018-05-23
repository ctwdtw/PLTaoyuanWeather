//
//  ManagedForecast+CoreDataProperties.swift
//  
//
//  Created by Paul Lee on 2018/4/26.
//
//

import Foundation
import CoreData


extension ManagedForecast {
  //@NSManaged var id: String
  @NSManaged var lastupdate: NSDate
  @NSManaged var managedWeather: NSSet
}

extension ManagedForecast {
  var managedWeathers: [ManagedWeather] {
    let managedWeathers = managedWeather.sortedArray(using: ManagedWeather.defaultSortDescriptor)
                          as! [ManagedWeather]
    return managedWeathers
  }
}

extension ManagedForecast {
  class func fetchRequest() -> NSFetchRequest<ManagedForecast> {
    return NSFetchRequest<ManagedForecast>(entityName: "ManagedForecast")
  }
  static var defaultSortDescriptor: [NSSortDescriptor] {
    return [NSSortDescriptor(key: "lastupdate", ascending: false)]
  }
  static var defaultSortedFetchRequest: NSFetchRequest<ManagedForecast> {
    let request: NSFetchRequest<ManagedForecast> = ManagedForecast.fetchRequest()
    request.sortDescriptors = defaultSortDescriptor
    return request
  }
  
}

// MARK: Generated accessors for managedWeather
//extension ManagedForecast {
//
//  @objc(addManagedWeatherObject:)
//  @NSManaged func addToManagedWeather(_ value: ManagedWeather)
//
//  @objc(removeManagedWeatherObject:)
//  @NSManaged func removeFromManagedWeather(_ value: ManagedWeather)
//
//  @objc(addManagedWeather:)
//  @NSManaged func addToManagedWeather(_ values: NSSet)
//
//  @objc(removeManagedWeather:)
//  @NSManaged func removeFromManagedWeather(_ values: NSSet)
//}
