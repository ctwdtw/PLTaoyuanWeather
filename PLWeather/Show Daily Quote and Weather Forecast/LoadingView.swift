//
//  LoadingView.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/5/27.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import UIKit
@IBDesignable
class LoadingView: UIView {
  @IBOutlet private(set) weak var loadingIndicatorView: UIActivityIndicatorView!
  @IBOutlet private(set) weak var loadingLabel: UILabel!
  
  @IBOutlet private weak var loadingStackView: UIStackView!
  
  var spacing: CGFloat {
    get {
      return loadingStackView.spacing
    }
    set {
      loadingStackView.spacing = newValue
    }
  }
  
  private weak var contentView: UIView!
  
  deinit {
    deinitMessage(from: self)
  
    
  
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    xibView()
    setContentAppearance()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    xibView()
    setContentAppearance()
  }
  
  private func xibView() {
    contentView = R.nib.loadingView.firstView(owner: self, options: nil)!
    addSubview(contentView)
    
    //layout
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }
  
  func setContentAppearance() {
    contentView.backgroundColor = UIColor.clear
    loadingLabel.textColor = UIColor.darkGray
    loadingIndicatorView.color = UIColor.blue
    //...
    //...
    //... other customized appearance setting.
    
    
  }
  
}









