//
//  APIDataStoreTest.swift
//  PLWeatherTests
//
//  Created by Paul Lee on 2018/4/23.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//

import XCTest
@testable import PLWeather

class APIDataStoreTest: XCTestCase {
  var sut: APIDataStore!
  override func setUp() {
    super.setUp()
    sut = APIDataStore()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func test_fetchDailyQoute_whenSuccess_getQuote() {
    //given
    
    //when
    let exp = expectation(description: "getQuoteWhenFetchSuccess")
    sut.fetchDaliyQuote { (quote, error) in
      guard let fetchedQuote = quote else {
        XCTFail("success fetch should not return nil quote")
        return
      }
      
      //then
      XCTAssertNotNil(fetchedQuote.id)
      XCTAssertNotNil(fetchedQuote.date)
      XCTAssertNotNil(fetchedQuote.author)
      XCTAssertNotNil(fetchedQuote.quote)
      
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 5)
  }
  
  //休刊
  func test_fetchDailyQuote_whenPublisherSuspend_getSuspendedQuote() {
    //given 休刊連結
    let injected = APIDataStoreInjectionWrapper(dailyQuoteUrlString: "https://tw.appledaily.com/index/dailyquote/date/20160419")
    sut.inject(injected)
    
    //when
    let exp = expectation(description: "getSuspendedQuote")
    sut.fetchDaliyQuote { (quote, error) in
      guard let fetchedQuote = quote else {
        XCTFail("success fetch should not return nil quote")
        return
      }
      
      //then
      XCTAssertNotNil(fetchedQuote.id)
      XCTAssertNotNil(fetchedQuote.date)
      XCTAssertNil(fetchedQuote.author)
      XCTAssertEqual(fetchedQuote.quote, "每日一句停刊一天")
      exp.fulfill()
      
    }
    
    wait(for: [exp], timeout: 5)
    
  }
  
  func test_fetchWeather_whenSuccess_getsWeathers() {
    //given
    
    //when
    let exp = expectation(description: "getWeathers")
    sut.fetchForecast { (forecast, error) in
      guard let fetchedForecast = forecast else {
        XCTFail("success fetch should not return nil forecast")
        return
      }
      
      XCTAssert(fetchedForecast.weathers.count == 14)
      
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 5)
  }
  
  
}




