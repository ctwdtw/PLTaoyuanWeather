//
//  UIViewController+Alert.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/5/26.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  func showAlertError(_ error: DisplayedError, okHandler: (()-> Void)? = nil) {
    let alert = UIAlertController(title: error.title,
                                  message: error.errorMessage,
                                  preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
      print("\(action.title!) is selected")
      okHandler?()
      
    }
    
    alert.addAction(okAction)
    
    present(alert, animated: true) {
      print("\(error.title) is presented")
    }
    
  }
}

