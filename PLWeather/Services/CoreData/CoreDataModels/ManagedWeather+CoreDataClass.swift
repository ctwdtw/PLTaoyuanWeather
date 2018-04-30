//
//  ManagedWeather+CoreDataClass.swift
//  
//
//  Created by Paul Lee on 2018/4/26.
//
//

import Foundation
import CoreData


class ManagedWeather: NSManagedObject {
  
  @NSManaged private var weekDayValue: Int16
  var weekDay: WeekDay {
    get {
      return WeekDay(weekDay: Int(weekDayValue))
    }
    set {
      weekDayValue = Int16(newValue.rawValue)
    }
  }
  
  @NSManaged private var dayOrNightValue: Int16
  var dayOrNight: DayOrNight {
    get {
      guard let dayorNigth = DayOrNight(rawValue: Int(dayOrNightValue)) else {
        fatalError("can not initialized from raw value")
      }
      return dayorNigth
    }
    set {
      dayOrNightValue = Int16(newValue.rawValue)
    }
  }
  
  @NSManaged private var iconDescriptionValue: Int16
  @NSManaged private var iconDescriptionAssociatedValue: String?
  var iconDescription: WeatherDescription {
    get {
      return WeatherDescription(rawValue: Int(iconDescriptionValue),
                                associatedValue: iconDescriptionAssociatedValue)
    }
    set {
      iconDescriptionValue = Int16(newValue.rawValue)
      if case let WeatherDescription.unknown(associatedValue) = newValue {
        iconDescriptionAssociatedValue = associatedValue
      }
      
    }
  }
}


extension ManagedWeather {
  func fromWeather(_ weather: Weather) {
    self.date = weather.date as NSDate
    self.weekDay = weather.weekDay
    self.dayOrNight = weather.dayOrNight
    self.highestTemprature = Int16(weather.highestTemprature)
    self.lowestTemprature = Int16(weather.lowestTemprature)
    self.iconDescription = weather.iconDescription
  }
  
  func toWeather() -> Weather {
    return Weather(date: date as Date,
                   weekDay: weekDay,
                   dayOrNight: dayOrNight,
                   highestTemprature: Int(highestTemprature),
                   lowestTemprature: Int(lowestTemprature),
                   iconDescription: iconDescription)
  }
}
