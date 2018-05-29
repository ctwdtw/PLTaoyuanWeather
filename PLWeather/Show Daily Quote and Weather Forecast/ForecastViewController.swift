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
  
  @IBOutlet private weak var forecastTableView: UITableView!
  private let forecastController = ForecastController()
  private var displayedForecast: DisplayedForecast?
  private var errorsToBeDisplayed: [DisplayedError] = []
  deinit {
    deinitMessage(from: self)
  }
}

//MARK: - Life Cycle
extension ForecastViewController {
  override func loadView() {
    super.loadView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureForcastTableView()
    forecastTableView.showLoadingView()
    
    forecastController.fetchLocalData { [weak self] (forecastQuoteVM) in
      if let error = forecastQuoteVM.displayedError {
        self?.displayError(error)
        
      } else {
        self?.reloadQuoteViews(with: forecastQuoteVM)
        self?.reloadForecastTableView(with: forecastQuoteVM)
        
      }
      
      self?.forecastTableView.hideLoadingView()
      self?.refreshDataBtnDidPressed()
      
    }
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    layoutTableHeaderView()
  }
  
  private func layoutTableHeaderView() {
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
  
  
  private func configureForcastTableView() {
    //delegate
    forecastTableView.delegate = self
    forecastTableView.dataSource = self
    
    //layout
    forecastTableView.register(R.nib.forecastTableViewCell)
    forecastTableView.estimatedRowHeight = 200
    forecastTableView.rowHeight = UITableViewAutomaticDimension
    
    //refresh control
    /*
    forecastTableView.refreshControl = UIRefreshControl()
    forecastTableView.refreshControl?.tintColor = UIColor.blue
    forecastTableView.refreshControl?.addTarget(self, action: #selector(pullToRefreshData), for: .valueChanged)*/
    
    //selection
    forecastTableView.allowsSelection = false
  }
  
  
}

//MARK: - Display logic
extension ForecastViewController {
  
  func displayError(_ error: DisplayedError) {
    
    guard error.shouldShow else {
      print("\(error.title):\(error.errorMessage)")
      return
    }
    
    let okHandler = {
      self.errorsToBeDisplayed.remove(at: 0)
      if let nextError = self.errorsToBeDisplayed.first {
        self.displayError(nextError)
      }
    }
    
    if errorsToBeDisplayed.count == 0 { //隊伍裡沒人
      errorsToBeDisplayed.append(error)
      showAlertError(error, okHandler: okHandler)
      
    } else if errorsToBeDisplayed.index(of: error) == 0 { //隊伍裡我第一個
      showAlertError(error, okHandler: okHandler)
      
    } else { //隊伍中有其他人
      guard isContentDuplicated(for: error) == false else { //沒人跟我顯示一樣的錯誤訊息
        return
      }
      errorsToBeDisplayed.append(error) //去排隊
      
    }
    
  }
  
  private func isContentDuplicated(for error: DisplayedError) -> Bool {
    var isDuplicated = false
    for e in errorsToBeDisplayed {
      if e.isContentEqual(to: error) {
        isDuplicated = true
        break
      }
      
    }
    return isDuplicated
  }
  
  private func showRemoteLoadingView() {
    guard let navigationBar = navigationController?.navigationBar else {
      return
    }
    navigationBar.showLoadingView()
    
  }
  
  private func hideRemoteLoadingView() {
    guard let navigationBar = navigationController?.navigationBar else {
      return
    }
    navigationBar.hideLoadingView()
  }
  

}

//MARK: - User Request
extension ForecastViewController {
  @IBAction func refreshDataBtnDidPressed() {
    showRemoteLoadingView()
    forecastController.refreshData { [weak self] (forecastQuoteVM) in
      if let error = forecastQuoteVM.displayedError,
        forecastQuoteVM.erroredDataType == .quote {
        self?.displayError(error)
      
      } else if let error = forecastQuoteVM.displayedError,
        forecastQuoteVM.erroredDataType == .forecast {
        self?.displayError(error)
        
      } else {
        self?.reloadQuoteViews(with: forecastQuoteVM)
        self?.reloadForecastTableView(with: forecastQuoteVM)
        
      }
      self?.hideRemoteLoadingView()
      
    }
  }
  
  
  @objc func pullToRefreshData() {
    
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

//MARK: - Table View Delegate
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

//MARK: - Table View Data Source
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
