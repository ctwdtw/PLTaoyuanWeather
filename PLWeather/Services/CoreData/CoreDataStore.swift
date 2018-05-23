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

extension CoreDataStore: WeatherQuoteLocalStoreProtocol {
  func fetchForecast(completion: @escaping (Forecast?, PLErrorProtocol?) -> Void) {
    persistentContainer.performBackgroundTask { (context) in
      let request = ManagedForecast.defaultSortedFetchRequest
      
      do {
        
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
  
  func insertForecast(_ forecast: Forecast, completion: @escaping (PLErrorProtocol?) -> Void ) {
    persistentContainer.performBackgroundTask { (context) in
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
        self.lastupdateDate.forForecast = forecast.lastupdate
        DispatchQueue.main.async {
          completion(nil)
        }
        
      } catch {
        DispatchQueue.main.async {
          completion(CoreDataError.cannotInsert(error))
        }
        
      }
      
    }
    
  }
  
  
  func fetchDaliyQuote(completion: @escaping (Quote?, PLErrorProtocol?) -> Void) {
    persistentContainer.performBackgroundTask { (context) in
      let request = ManagedQuote.dateSortedFetchRequest
      
      do {
        
        let resultSet = try context.fetch(request)
        print(resultSet.count)
        
        if let managedQuote = try context.fetch(request).first {
          let quote = managedQuote.toQuote()
          DispatchQueue.main.async {
            completion(quote, nil)
          }
          
        } else {
          DispatchQueue.main.async {
            completion(nil, nil)
          }
          
        }
        
        try context.save() // propagate managedObject to view context
        
      } catch {
        DispatchQueue.main.async {
          completion(nil, CoreDataError.cannotFetch(error))
        }
        
      }
    }
  }
  
  func insertDailyQuote(_ quote: Quote, completion: @escaping (PLErrorProtocol?) -> Void ) {
    persistentContainer.performBackgroundTask { (context) in
      let managedQuote = ManagedQuote(context: context)
      managedQuote.fromQuote(quote: quote)
      
      do {
        try context.save()
        self.lastupdateDate.forQuote = quote.date
        DispatchQueue.main.async {
          completion(nil)
        }
        
      } catch {
        DispatchQueue.main.async {
          completion(CoreDataError.cannotInsert(error))
        }
        
      }
      
    }
  }
  
}
