//
//  InitialErrorTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-12-31.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class InitialErrorTests: XCTestCase {

  func testError() {
    var error: NSError?

    let p = Promise<Int>(error: NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    error = p.error

    XCTAssert(error?.code == 42, "Error should be set")
  }

  func testErrorVoid() {
    var error: NSError?

    let p = Promise<Int>(error: NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    p.catch { e in
      error = e
    }

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(error?.code == 42, "Error should be set")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testErrorMap() {
    var value: Int?

    let p = Promise<Int>(error: NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
      .mapError { $0.code + 1 }

    p.then { x in
      value = x
    }

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(value == 43, "Value should be set")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testErrorFlatMap() {
    var value: Int?

    let p = Promise<Int>(error: NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
      .flatMapError { Promise(value: $0.code + 1) }

    p.then { x in
      value = x
    }

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(value == 43, "Value should be set")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testErrorFlatMap2() {
    var error: NSError?

    let p = Promise<Int>(error: NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
      .flatMapError { Promise(error: NSError(domain: PromissumErrorDomain, code: $0.code + 1, userInfo: nil)) }

    p.catch { e in
      error = e
    }

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(error?.code == 43, "Error should be set")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testFinally() {
    var finally: Bool = false

    let p = Promise<Int>(error: NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    p.finally {
      finally = true
    }

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(finally, "Finally should be set")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }
}
