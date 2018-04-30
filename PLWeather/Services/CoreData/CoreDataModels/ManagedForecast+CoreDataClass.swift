//
//  ManagedForecast+CoreDataClass.swift
//  
//
//  Created by Paul Lee on 2018/4/26.
//
//

import Foundation
import CoreData

class ManagedForecast: NSManagedObject {

}

extension ManagedForecast {
  func toForecast() -> Forecast {
    //TODO:// performance issue
    let weathers = managedWeathers.map { $0.toWeather() }
    let forecast = Forecast(lastupdate: lastupdate as Date, weathers: weathers)
    return forecast
  }
  
  func fromForecast(_ forecast: Forecast) {
    self.lastupdate = forecast.lastupdate as NSDate
  }
}
