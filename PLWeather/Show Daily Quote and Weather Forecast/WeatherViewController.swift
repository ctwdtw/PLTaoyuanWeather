//
//  ViewController.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/18.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {
  
  @IBOutlet weak var dailyQuoteLabel: UILabel!
  
  @IBOutlet weak var authorLabel: UILabel!
  
  @IBOutlet weak var dateTimeLabel: UILabel!
  @IBOutlet private weak var dailyQuoteTableHeaderView: UIView!
  @IBOutlet private weak var forecastTableView: UITableView!
  private let weatherController = WeatherController()
  private var displayedForecast: DisplayedForecast?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureForcastTableView()
    
    weatherController.fetchDataOnLoad { [unowned self] (weatherQuoteVM) in
      if let error = weatherQuoteVM.displayedError {
        self.displayError(error)
      
      }
      self.reloadQuoteViews(with: weatherQuoteVM)
      self.reloadForecastTableView(with: weatherQuoteVM)
      
    }
    
  }
  
  func displayError(_ error: DisplayedError) {
    if error.shouldShow {
      showAlertError(error)
    
    } else {
      print("\(error.title):\(error.errorMessage)")
    
    }
  }
  
  //TODO:// MOVE TO UIVIewController + Alert
  private func showAlertError(_ error: DisplayedError) {
    let alert = UIAlertController(title: error.title,
                                  message: error.errorMessage,
                                  preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK",
                                 style: .default) { (_) in
      alert.dismiss(animated: true, completion: nil)
                                  
    }
    
    alert.addAction(okAction)
    present(alert, animated: true, completion: nil)
  }
  
  
  private func configureForcastTableView() {
    //delegate
    forecastTableView.delegate = self
    forecastTableView.dataSource = self
    
    //layout
    forecastTableView.register(R.nib.forecastTableViewCell)
    forecastTableView.estimatedRowHeight = 200
    forecastTableView.rowHeight = UITableViewAutomaticDimension
    
    //refresh control
    forecastTableView.refreshControl = UIRefreshControl()
    forecastTableView.refreshControl?.tintColor = UIColor.red
    forecastTableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    
    //selection
    forecastTableView.allowsSelection = false
  }
  
  private func reloadQuoteViews(with vm: WeatherQuoteViewModel) {
    dailyQuoteLabel.text = vm.displayedQuote?.quote
    authorLabel.text = vm.displayedQuote?.author
    dateTimeLabel.text = vm.displayedQuote?.displayedDate
  }
  
  private func reloadForecastTableView(with vm: WeatherQuoteViewModel) {
    displayedForecast = vm.displayedForecast
    forecastTableView.reloadData()
  }
  
  @objc @IBAction func refreshData() {
    weatherController.pullToRefreshData { [unowned self] (weatherQuoteVM) in
      self.forecastTableView.refreshControl?.endRefreshing()
      
      if let error = weatherQuoteVM.displayedError {
        self.displayError(error)
      }
      
      self.reloadQuoteViews(with: weatherQuoteVM)
      self.reloadForecastTableView(with: weatherQuoteVM)
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard let headerView = forecastTableView.tableHeaderView else {
      return
    }
    
    let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    
    if headerView.frame.size.height != size.height {
      headerView.frame.size.height = size.height
      
      forecastTableView.tableHeaderView = headerView
      forecastTableView.layoutIfNeeded()
    }
    
  }
  
  
}

extension WeatherViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      
      weatherController.deleteWeather(at: indexPath) { (displayedForecast, displayedError) in
        guard displayedError == nil else {
          self.displayError(displayedError!)
          return
        }
        
        self.displayedForecast = displayedForecast
        //delete UI
        tableView.deleteRows(at: [indexPath], with: .fade)
      }
      
    }
  }
  
  
  
}


extension WeatherViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return displayedForecast?.displayedWeathers.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.forecastTableViewCell,
                                             for: indexPath)!
    cell.weekDayLabel.text = displayedForecast?.displayedWeathers[indexPath.row].displayedWeekDay
    
    cell.dayOrNightLabel.text = displayedForecast?.displayedWeathers[indexPath.row].displayedDayOrNight
    
    cell.weatherDescriptionLabel.text = displayedForecast?.displayedWeathers[indexPath.row].displayedIconDescription
    cell.highestTempratureLabel.text = displayedForecast?.displayedWeathers[indexPath.row].displayedHighestTemprature
    cell.lowestTempratureLabel.text = displayedForecast?.displayedWeathers[indexPath.row].displayedLowetstTemprature
    return cell
  }
}
