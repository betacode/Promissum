//
//  ResolveRejectTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-12-31.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class ResolveRejectTests: XCTestCase {

  func testResolveReject() {
    var state = ""

    let source = PromiseSource<Int>()
    let p = source.promise

    p.then { _ in
      state = "resolved"
    }
    p.catch { _ in
      state = "rejected"
    }

    source.resolve(42)
    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssertEqual(state, "resolved", "State should be resolved")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testRejectResolve() {
    var state = ""

    let source = PromiseSource<Int>()
    let p = source.promise

    p.then { _ in
      state = "resolved"
    }
    p.catch { _ in
      state = "rejected"
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssertEqual(state, "rejected", "State should be rejected")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testResolveFinally() {
    var state = ""

    let source = PromiseSource<Int>()
    let p = source.promise

    p.then { _ in
      state = "resolved"
    }
    p.finally {
      state = "finally"
    }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssertEqual(state, "finally", "State should be finally")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testFinallyResolve() {
    var state = ""

    let source = PromiseSource<Int>()
    let p = source.promise

    p.finally {
      state = "finally"
    }
    p.then { _ in
      state = "resolved"
    }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssertEqual(state, "resolved", "State should be resolved")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }
}
