//
//  LocalDataManager.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/18.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
import CoreData
class CoreDataStore {
  lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "PLWeather")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  private(set) var lastupdateDate: LastupdateTime
  
  init() {
    
    do {
      self.lastupdateDate = try Storage.retrieve("lastupdate", from: Storage.Directory.documents, as: LastupdateTime.self)
    } catch {
      self.lastupdateDate = LastupdateTime(forQuote: nil, forForecast: nil)
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(saveData),
                                           name: .UIApplicationWillResignActive,
                                           object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(saveData),
                                           name: .UIApplicationWillTerminate,
                                           object: nil)
  }
  
  deinit {
    deinitMessage(from: self)
    NotificationCenter.default.removeObserver(self)
  }
  
}

extension CoreDataStore {
  @objc func saveData() {
    saveContext()
    saveStorage()
  }
  
  private func saveStorage() {
    Storage.store(lastupdateDate, to: .documents, as: "lastupdate")
  }
  
  private func saveContext()  {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        print(nserror)
      }
    }
  }
  
}

extension CoreDataStore {
  func cleanCoreDataStore() {
    persistentContainer.viewContext.perform {
      //TODO;// delete all
      
    }
  }
}

extension CoreDataStore: ForecastLocalStoreProtocol {
  func deleteWeather(at index: Int, of forecast: Forecast,
                     completion: @escaping (_ updatedForecast: Forecast?, PLErrorProtocol?) -> Void) {
    let lastupdate = forecast.lastupdate as NSDate
    persistentContainer.performBackgroundTask { [weak self] (context) in
      let request = ManagedForecast.defaultSortedFetchRequest
      request.predicate = NSPredicate(format: "lastupdate == %@", lastupdate)
      do {
        if let forecast = try context.fetch(request).first {
          let weatherForDelete = forecast.managedWeathers[index]
          context.delete(weatherForDelete)
          try context.save()
          let updatedForecast = forecast.toForecast()
          self?.saveData()
          DispatchQueue.main.async {
            completion(updatedForecast, nil)
          }
          
        }
        
      } catch {
        
        DispatchQueue.main.async {
          completion(nil, CoreDataError.cannotDelete(error))
        }
        
        
        
      }
      
    }
    
    
  }
  
  
  func fetchForecast(completion: @escaping (Forecast?, PLErrorProtocol?) -> Void) {
    persistentContainer.performBackgroundTask { (context) in
      let request = ManagedForecast.defaultSortedFetchRequest
      
      do {
        let resultSet = try context.fetch(request)
        let count = resultSet.count
        print("forecastCount:\(count)")
        
        
        if let managedForecast = try context.fetch(request).first {
          let forecast = managedForecast.toForecast()
          
          DispatchQueue.main.async {
            completion(forecast, nil)
          }
          
        } else {
          DispatchQueue.main.async {
            completion(nil, nil)
          }
          
        }
        
      } catch {
        DispatchQueue.main.async {
          completion(nil, CoreDataError.cannotFetch(error))
        }
        
      }
      
    }
    
  }
  
  private func shouldUpdateForecast(_ forecast: Forecast) -> Bool {
    if let lastupdate = self.lastupdateDate.forForecast,
      lastupdate == forecast.lastupdate {
      return false
    } else {
      return true
    }
  }
  
  func insertForecast(_ forecast: Forecast, completion: @escaping (_ insertedForecast: Forecast?, PLErrorProtocol?) -> Void ) {
    guard shouldUpdateForecast(forecast) else {
      completion(nil, CoreDataError.noNeedToUpdateForecast)
      return
    }
    
    persistentContainer.performBackgroundTask { [weak self] (context) in
      let managedForecast = ManagedForecast(context: context)
      managedForecast.fromForecast(forecast)
      
      let _: [ManagedWeather] = forecast.weathers.map {
        let managedWeather = ManagedWeather(context: context)
        managedWeather.fromWeather($0)
        managedWeather.managedForecast = managedForecast
        
        return managedWeather
      }
      
      
      
      do {
        try context.save()
        self?.lastupdateDate.forForecast = forecast.lastupdate
        self?.saveData()
        DispatchQueue.main.async {
          //預留空間, 傳回插入的 quote, 將來也許可以對 quote 加點料, 例如插入的 timeStamp 什麼的。
          completion(forecast, nil)
        }
        
      } catch {
        DispatchQueue.main.async {
          completion(nil, CoreDataError.cannotInsert(error))
        }
        
      }
      
    }
    
  }
  
  
  func fetchDaliyQuote(completion: @escaping (Quote?, PLErrorProtocol?) -> Void) {
    persistentContainer.performBackgroundTask { (context) in
      let request = ManagedQuote.dateSortedFetchRequest
      
      do {
        
        if let managedQuote = try context.fetch(request).first {
          let quote = managedQuote.toQuote()
          sleep(2)
          DispatchQueue.main.async {
            completion(quote, nil)
          }
          
        } else {
          DispatchQueue.main.async {
            completion(nil, nil)
          }
          
        }
        
        
      } catch {
        DispatchQueue.main.async {
          completion(nil, CoreDataError.cannotFetch(error))
        }
        
      }
    }
  }
  
  private func shouldUpdateDailyQuote(_ quote: Quote) -> Bool {
    if let lasupdate = lastupdateDate.forQuote,
      lasupdate == quote.date {
      return false
    } else {
      return true
    }
  }
  
  func insertDailyQuote(_ quote: Quote, completion: @escaping (_ insertedQuote: Quote? ,PLErrorProtocol?) -> Void ) {
    guard shouldUpdateDailyQuote(quote) else {
      completion(nil, CoreDataError.noNeedToUpdateQuote)
      return
    }
  
    persistentContainer.performBackgroundTask { [weak self] (context) in
      let managedQuote = ManagedQuote(context: context)
      managedQuote.fromQuote(quote: quote)
      
      do {
        try context.save()
        self?.lastupdateDate.forQuote = quote.date
        self?.saveData()
        DispatchQueue.main.async {
          //預留空間, 傳回插入的 quote, 將來也許可以對 quote 加點料, 例如插入的 timeStamp 什麼的。
          completion(quote , nil)
        }
        
      } catch {
        DispatchQueue.main.async {
          completion(nil, CoreDataError.cannotInsert(error))
        }
        
      }
      
    }
  }
  
}
