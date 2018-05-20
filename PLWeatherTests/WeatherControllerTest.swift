//
//  WeatherControllerTest.swift
//  PLWeatherTests
//
//  Created by Paul Lee on 2018/4/27.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import XCTest
@testable import PLWeather
class WeatherControllerTest: XCTestCase {
  var sut: WeatherController!
  override func setUp() {
    super.setUp()
    sut = WeatherController()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func test_fetchDataOnLoad_whenSuccess_hasData() {
    let exp = expectation(description: "fetch_data_on_load")
    var ithFetch = 0
    sut.fetchDataOnLoad { (viewModel) in
      ithFetch = ithFetch + 1
      if ithFetch == 1 { //fetchFromLocal
        XCTAssertNotNil(viewModel.displayedQuote)
        XCTAssertNotNil(viewModel.displayedForecast)
        XCTAssertNil(viewModel.displayedError)
      
      } else if ithFetch == 2 { //fetchFromRemote
        XCTAssertNotNil(viewModel.displayedQuote)
        XCTAssertNotNil(viewModel.displayedForecast)
        XCTAssertNil(viewModel.displayedError)
        exp.fulfill()
      
      }
    
    }
    
    wait(for: [exp], timeout: 5000)
  }
  
  func test_pullToRefreshData_whenSuccess_hasData() {
    let exp = expectation(description: "pull_to_fresh")
    //when
    sut.pullToRefreshData { (viewModel) in
      //then
      XCTAssertNotNil(viewModel.displayedQuote)
      XCTAssertNotNil(viewModel.displayedForecast)
      XCTAssertNil(viewModel.displayedError)
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 5)
  }

  
  func test_pullToRefreshData_whenQuoteSuspened_returnDisplayedSuspendQuote() {
    //given
    let remoteInjected = APIDataStoreInjectionWrapper(dailyQuoteUrlString: "https://tw.appledaily.com/index/dailyquote/date/20160419")
    let remoteStore = APIDataStore()
    remoteStore.inject(remoteInjected)
    
    let injected = WatherControllerInjectionWrapper(remoteStore: remoteStore)
    sut.inject(injected)
    
    //when
    let exp = expectation(description: "return_suspened_quote")
    sut.pullToRefreshData { (vm) in
      XCTAssertEqual(vm.displayedQuote?.author, "")
      XCTAssertNotNil(vm.displayedQuote?.quote)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 5)
    
  }
  
  
}
