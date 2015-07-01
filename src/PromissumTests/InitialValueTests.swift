//
//  InitialValueTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-12-31.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class InitialValueTests: XCTestCase {

  func testValue() {
    var value: Int?

    let p = Promise(value: 42)

    value = p.value

    XCTAssert(value == 42, "Value should be set")
  }

  func testValueVoid() {
    var value: Int?

    let p = Promise(value: 42)

    p.then { x in
      value = x
    }

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(value == 42, "Value should be set")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testValueMap() {
    var value: Int?

    let p = Promise(value: 42)
      .map { $0 + 1 }

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

  func testValueFlatMap() {
    var value: Int?

    let p = Promise(value: 42)
      .flatMap { Promise(value: $0 + 1) }

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

  func testFinally() {
    var finally: Bool = false

    let p = Promise<Int>(value: 42)

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
