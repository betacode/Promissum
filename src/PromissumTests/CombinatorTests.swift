//
//  CombinatorTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-07.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class CombinatorTests: XCTestCase {

  func testFlattenValueValue() {
    var value: Int?

    let source1 = PromiseSource<Promise<Int>>()
    let source2 = PromiseSource<Int>()
    let outer = source1.promise
    let inner = source2.promise

    let p = flatten(outer)
      .then { x in
        value = x
      }

    source1.resolve(inner)
    source2.resolve(42)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(value == 42, "Value should be 42")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testFlattenValueError() {
    var error: NSError?

    let source1 = PromiseSource<Promise<Int>>()
    let source2 = PromiseSource<Int>()
    let outer = source1.promise
    let inner = source2.promise

    let p = flatten(outer)
      .catch { e in
        error = e
      }

    source1.resolve(inner)
    source2.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(error?.code == 42, "Error should be 42")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testFlattenErrorError() {
    var error: NSError?

    let source1 = PromiseSource<Promise<Int>>()
    let source2 = PromiseSource<Int>()
    let outer = source1.promise
    let inner = source2.promise

    let p = flatten(outer)
      .catch { e in
        error = e
      }

    source1.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(error?.code == 42, "Error should be 42")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testBothValue() {
    var value: Int?

    let source1 = PromiseSource<Int>()
    let source2 = PromiseSource<Int>()
    let p1 = source1.promise
    let p2 = source2.promise

    let p = whenBoth(p1, p2)
      .then { (x, y) in
        value = x + y
    }

    source1.resolve(40)
    source2.resolve(2)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(value == 42, "Value should be 42")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testBothError() {
    var error: Int?

    let source1 = PromiseSource<Int>()
    let source2 = PromiseSource<Int>()
    let p1 = source1.promise
    let p2 = source2.promise

    let p = whenBoth(p1, p2)
      .catch { e in
        error = e.code
    }

    source1.resolve(40)
    source2.reject(NSError(domain: PromissumErrorDomain, code: 42, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(error == 42, "Error should be 42")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testEitherLeft() {
    var value: Int?

    let source1 = PromiseSource<Int>()
    let source2 = PromiseSource<Int>()
    let p1 = source1.promise
    let p2 = source2.promise

    let p = whenEither(p1, p2)
      .then { x in
        value = x
      }
      .catch { e in
        value = e.code
    }

    source1.resolve(1)
    source2.reject(NSError(domain: PromissumErrorDomain, code: 2, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(value == 1, "Value should be 1")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testEitherRight() {
    var value: Int?

    let source1 = PromiseSource<Int>()
    let source2 = PromiseSource<Int>()
    let p1 = source1.promise
    let p2 = source2.promise

    let p = whenEither(p1, p2)
      .then { x in
        value = x
      }
      .catch { e in
        value = e.code
    }

    source1.reject(NSError(domain: PromissumErrorDomain, code: 1, userInfo: nil))
    source2.resolve(2)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(value == 2, "Value should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testEitherError() {
    var value: Int?

    let source1 = PromiseSource<Int>()
    let source2 = PromiseSource<Int>()
    let p1 = source1.promise
    let p2 = source2.promise

    let p = whenEither(p1, p2)
      .then { x in
        value = x
      }
      .catch { e in
        value = e.code
    }

    source1.reject(NSError(domain: PromissumErrorDomain, code: 1, userInfo: nil))
    source2.reject(NSError(domain: PromissumErrorDomain, code: 2, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(value == 2, "Value should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testWhenAllResolved() {
    var values: [Int]?

    let source1 = PromiseSource<Int>()
    let source2 = PromiseSource<Int>()
    let p1 = source1.promise
    let p2 = source2.promise

    let p = whenAll([p1, p2])
      .then { xs in
        values = xs
      }

    source2.resolve(2)
    source1.resolve(1)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(values != nil && values! == [1, 2], "Values should be [1, 2]")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testWhenAnyResolved() {
    var value: Int?

    let source1 = PromiseSource<Int>()
    let source2 = PromiseSource<Int>()
    let p1 = source1.promise
    let p2 = source2.promise

    let p = whenAny([p1, p2])
      .then { x in
        value = x
      }

    source2.resolve(2)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(value == 2, "Value should be 2")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testWhenAllEmpy() {
    var values: [Int]?

    let promises: [Promise<Int>] = []

    let p = whenAll(promises)
      .then { xs in
        values = xs
      }

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(values != nil && values! == [], "Values should be [1]")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testWhenAnyEmpty() {
    var error: NSError?

    let promises: [Promise<Int>] = []

    let p = whenAny(promises)
      .catch { e in
        error = e
      }

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(error != nil, "Error should be set")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testWhenAllFinalized() {
    var finalized = false

    let source1 = PromiseSource<Int>()
    let source2 = PromiseSource<Int>()
    let p1 = source1.promise
    let p2 = source2.promise

    let p = whenAllFinalized([p1, p2])
      .then {
        finalized = true
      }

    source1.resolve(1)
    source2.reject(NSError(domain: PromissumErrorDomain, code: 2, userInfo: nil))

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(finalized, "Finalized should be set")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testWhenAnyFinalized() {
    var finalized = false

    let source1 = PromiseSource<Int>()
    let source2 = PromiseSource<Int>()
    let p1 = source1.promise
    let p2 = source2.promise

    let p = whenAnyFinalized([p1, p2])
      .then {
        finalized = true
      }

    source1.resolve(1)

    // Check assertions
    let expectation = expectationWithDescription("Promise didn't finish")
    p.finally {
      XCTAssert(finalized, "Finalized should be set")
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }
}
