//
//  MultipleValueTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-12-31.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class MultipleValueTests: XCTestCase {

  func testValueVoid() {
    var calls = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p.then { _ in
      calls += 1
    }
    p.then { _ in
      calls += 1
    }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testValueMap() {
    var calls = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p.then { _ in
      calls += 1
    }
    let q = p
      .map { $0 + 1 }
      .then { _ in
        calls += 1
      }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    whenBoth(p, q).finally {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testValueFlatMap() {
    var calls = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p.then { _ in
      calls += 1
    }
    let q = p
      .flatMap { Promise(value: $0 + 1) }
      .then { _ in
        calls += 1
      }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    whenBoth(p, q).finally {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testFinally() {
    var calls = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p.finally {
      calls += 1
    }
    let q = p
      .map { $0 + 1 }
      .finally {
        calls += 1
      }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    whenBoth(p, q).finally {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }
}
