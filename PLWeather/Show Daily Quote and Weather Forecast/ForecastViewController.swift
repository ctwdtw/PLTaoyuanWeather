//
//  ViewController.swift
//  PLWeather
//
//  Created by Paul Lee on 2018/4/18.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import UIKit

class ForecastViewController: UIViewController {
  @IBOutlet weak var cultureDateTimeLabel: UILabel!
  @IBOutlet weak var dateTimeLabel: UILabel!
  @IBOutlet weak var dailyQuoteLabel: UILabel!
  @IBOutlet weak var authorLabel: UILabel!
  
  @IBOutlet private weak var dailyQuoteTableHeaderView: UIView!
  @IBOutlet private weak var forecastTableView: UITableView!
  private let forecastController = ForecastController()
  private var displayedForecast: DisplayedForecast?
  
  deinit {
    deinitMessage(from: self)
  }
  
  func displayError(_ error: DisplayedError) {
    if error.shouldShow {
      showAlertError(error)
      
    } else {
      print("\(error.title):\(error.errorMessage)")
      
    }
  }
  
  @objc @IBAction func refreshData() {
    forecastController.refreshData { [weak self] (weatherQuoteVM) in
      self?.forecastTableView.refreshControl?.endRefreshing()
      
      if let error = weatherQuoteVM.displayedError {
        self?.displayError(error)
      }
      
      self?.reloadQuoteViews(with: weatherQuoteVM)
      self?.reloadForecastTableView(with: weatherQuoteVM)
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
    forecastTableView.refreshControl?.tintColor = UIColor.blue
    forecastTableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    
    //selection
    forecastTableView.allowsSelection = false
  }
  
  private func reloadQuoteViews(with vm: ForecastQuoteViewModel) {
    guard  let displayedQuote = vm.displayedQuote else {
      return
    }
    
    cultureDateTimeLabel.text = displayedQuote.displayedCultureDate
    dateTimeLabel.text = displayedQuote.displayedDate
    dailyQuoteLabel.text = displayedQuote.quote
    authorLabel.text = displayedQuote.author
    
  }
  
  private func reloadForecastTableView(with vm: ForecastQuoteViewModel) {
    guard let displayedForecast = vm.displayedForecast else {
      return
    }
    
    self.displayedForecast = displayedForecast
    forecastTableView.reloadData()
  }
  
}

//Life Cycle
extension ForecastViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureForcastTableView()
    
    forecastController.fetchDataOnLoad { [weak self] (weatherQuoteVM) in
      if let error = weatherQuoteVM.displayedError {
        self?.displayError(error)
        
      }
      self?.reloadQuoteViews(with: weatherQuoteVM)
      self?.reloadForecastTableView(with: weatherQuoteVM)
      self?.refreshData() //after local data fetched and displayed, check if there is remote data to be download
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


extension ForecastViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      
      forecastController.deleteWeather(at: indexPath) { (displayedForecast, displayedError) in
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

extension ForecastViewController: UITableViewDataSource {
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
