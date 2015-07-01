//
//  SideEffectOrderTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-11.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class SideEffectOrderTests : XCTestCase {

  func testThen() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p
      .then { _ in
        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .then { _ in
        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
      }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssertEqual(step, 2, "Should be step 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testCatch() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    p
      .catch { _ in
        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .catch { _ in
        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssertEqual(step, 2, "Should be step 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testMap() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .then { value in
        XCTAssertEqual(value, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .map { value in
        XCTAssertEqual(value, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
        return value + 1
      }
      .then { value in
        XCTAssertEqual(value, 43, "Value should be 43")

        step += 1
        XCTAssertEqual(step, 3, "Should be step 3")
      }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssertEqual(step, 3, "Should be step 3")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testMap2() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .map { value in
        XCTAssertEqual(value, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
        return value + 1
      }

    p.then { value in
      XCTAssertEqual(value, 42, "Value should be 42")

      step += 1
      XCTAssertEqual(step, 2, "Should be step 2")
    }

    q.then { value in
      XCTAssertEqual(value, 43, "Value should be 43")

      step += 1
      XCTAssertEqual(step, 3, "Should be step 3")
    }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssertEqual(step, 3, "Should be step 3")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testMapError() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .mapError { error in
        XCTAssertEqual(error.code, 42, "Error should be 42")

        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
        return error.code + 1
      }

    p.catch { error in
      XCTAssertEqual(error.code, 42, "Error should be 42")

      step += 1
      XCTAssertEqual(step, 2, "Should be step 2")
    }

    q.then { value in
      XCTAssertEqual(value, 43, "Value should be 43")

      step += 1
      XCTAssertEqual(step, 3, "Should be step 3")
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssertEqual(step, 3, "Should be step 3")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testErrorMap() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .map { value in
        step += 1
        XCTFail("Shouldn't happen")
        return value
      }

    p.catch { error in
      XCTAssertEqual(error.code, 42, "Error should be 42")

      step += 1
      XCTAssertEqual(step, 1, "Should be step 1")
    }

    q.catch { error in
      XCTAssertEqual(error.code, 42, "Value should be 42")

      step += 1
      XCTAssertEqual(step, 2, "Should be step 2")
    }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssertEqual(step, 2, "Should be step 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testFlatMap() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .then { value in
        XCTAssertEqual(value, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .flatMap { value in
        XCTAssertEqual(value, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
        return Promise(value: value + 1)
      }
      .then { value in
        XCTAssertEqual(value, 43, "Value should be 43")

        step += 1
        XCTAssertEqual(step, 3, "Should be step 3")
      }

    source.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      XCTAssertEqual(step, 3, "Should be step 3")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testFlatMapError() {
    var step = 0

    let source = PromiseSource<Int>()
    let p = source.promise

    let q: Promise<Int> = p
      .catch { error in
        XCTAssertEqual(error.code, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 1, "Should be step 1")
      }
      .flatMapError { error in
        XCTAssertEqual(error.code, 42, "Value should be 42")

        step += 1
        XCTAssertEqual(step, 2, "Should be step 2")
        return Promise(error: NSError(domain: PromissumErrorDomain, code: error.code + 1, userInfo: nil))
      }
      .catch { error in
        XCTAssertEqual(error.code, 43, "Value should be 43")

        step += 1
        XCTAssertEqual(step, 3, "Should be step 3")
      }

    source.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    q.finally {
      XCTAssertEqual(step, 3, "Should be step 3")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }
}