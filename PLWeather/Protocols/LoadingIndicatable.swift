//
//  LoadingIndicatable.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/5/29.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import Foundation
import UIKit
protocol LoadingIndicatable {
  var loadingViewStringTag: String { get }
  var loadingView: LoadingView { get }
  func showLoadingView()
  func hideLoadingView()
}

extension LoadingIndicatable where Self: UIView {
  
  func showLoadingView() {
    bringSubview(toFront: loadingView)
    loadingView.isHidden = false
    
  }
  
  func hideLoadingView() {
    loadingView.isHidden = true
    
  }
  
}

extension UITableView: LoadingIndicatable {
  var loadingViewStringTag: String {
    return "UITableView+LoadingIndicatable"
  }
  
  var loadingViewTag: Int {
    return loadingViewStringTag.hashValue
  }
  
  var loadingView: LoadingView {
    if let view = viewWithTag(loadingViewTag) as? LoadingView {
      return view
      
    } else {
      let frame = self.bounds
      let view = LoadingView(frame: frame)
      view.autoresizingMask = [.flexibleBottomMargin,
                               .flexibleHeight,
                               .flexibleLeftMargin,
                               .flexibleRightMargin,
                               .flexibleTopMargin,
                               .flexibleWidth]
      
      view.backgroundColor = UIColor.groupTableViewBackground
      view.loadingLabel.text = "Loading..."
      view.tag = loadingViewTag
      view.isHidden = true
      addSubview(view)
      return view
      
    }
  }
  
  func showLoadingView() {
    bringSubview(toFront: loadingView)
    loadingView.isHidden = false
    self.separatorColor = UIColor.clear
  }
  
  func hideLoadingView() {
    loadingView.isHidden = true
    self.separatorColor = UIColor(red: 0.783922,
                                  green: 0.780392,
                                  blue: 0.8,
                                  alpha: 1)
    
  }
  
}
  
extension UINavigationBar: LoadingIndicatable {
  var loadingViewStringTag: String {
    return "my awesome tag yeah ~~~~"
  }
  
  var loadingViewTag: Int {
    return loadingViewStringTag.hashValue
  }
  
  var loadingView: LoadingView {
    if let view = viewWithTag(loadingViewTag) as? LoadingView {
      return view
      
    } else {
      let x = self.bounds.width/2 - 30/2
      let y = self.bounds.height/2 - 30/2
      let frame = CGRect(x: x, y: y, width: 30, height: 30)
      let view = LoadingView(frame: frame)
      view.loadingLabel.text = nil
      view.spacing = 0
      view.tag = loadingViewTag
      view.isHidden = true
      addSubview(view)
      return view
      
    }
  }
  
}

