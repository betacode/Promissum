//
//  MultipleErrorTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-12-31.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class MultipleErrorTests: XCTestCase {

  func testValueVoid() {
    var calls = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p.catch { _ in
      calls += 1
    }
    p.catch { _ in
      calls += 1
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

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

    p.catch { _ in
      calls += 1
    }
    let q = p
      .mapError { $0.code + 1 }
      .then { _ in
        calls += 1
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

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

    p.catch { _ in
      calls += 1
    }
    let q = p
      .flatMapError { Promise(value: $0.code + 1) }
      .then { value in
        XCTAssertEqual(value, 43, "Value should be 43")
        calls += 1
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testValueFlatMap2() {
    var calls = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p.catch { _ in
      calls += 1
    }
    let q = p
      .flatMapError { Promise(error: NSError(domain: PromissumErrorDomain, code: $0.code + 1, userInfo: nil))  }
      .catch { _ in
        calls += 1
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testValueFlatMap3() {
    var calls = 0

    let source1 = PromiseSource<Int>()
    let p1 = source1.promise
    let source2 = PromiseSource<Int>()
    let p2 = source2.promise

    p1.catch { _ in
      calls += 1
    }
    let p3 = p1.flatMapError { _ in p2 }
      .then { _ in
        calls += 1
      }

    source1.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
    source2.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p3.finally {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testValueFlatMap4() {
    var calls = 0

    let source1 = PromiseSource<Int>()
    let p1 = source1.promise
    let source2 = PromiseSource<Int>()
    let p2 = source2.promise

    p1.catch { _ in
      calls += 1
    }
    let p3 = p1.flatMapError { _ in p2 }
      .catch { _ in
        calls += 1
      }

    source1.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))
    source2.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p3.finally {
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

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    whenBoth(p, q).finally {
      XCTAssertEqual(calls, 2, "Calls should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }
}
