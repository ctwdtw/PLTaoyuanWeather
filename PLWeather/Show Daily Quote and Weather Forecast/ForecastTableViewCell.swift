//
//  ForecastTableViewCell.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/5/21.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
  @IBOutlet weak var weekDayLabel: UILabel!
  @IBOutlet weak var weatherDescriptionLabel: UILabel!
  @IBOutlet weak var lowestTempratureLabel: UILabel!
  @IBOutlet weak var highestTempratureLabel: UILabel!
  @IBOutlet weak var dayOrNightLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }

  
}
