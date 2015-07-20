//
//  DispatchMethodsTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-07-19.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class DispatchMethodsTests: XCTestCase {

  func testUnspecified() {
    let resolveQueueLabel = "resolve1"
    let resolveQueue = dispatch_queue_create(resolveQueueLabel, nil)

    let source = PromiseSource<Int>()
    let p = source.promise

    let expectation = expectationWithDescription("Promise didn't finish")
    p.then { _ in
      XCTAssert(NSThread.isMainThread(), "Should be on main queue")

      expectation.fulfill()
    }

    dispatch_async(resolveQueue) {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, resolveQueueLabel, "Should be on resolve queue")
      source.resolve(42)
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testSynchronized() {
    let resolveQueueLabel = "resolve1"
    let resolveQueue = dispatch_queue_create(resolveQueueLabel, nil)

    let source = PromiseSource<Int>()
    let p = source.promise

    let expectation = expectationWithDescription("Promise didn't finish")
    p.dispatchSync().then { _ in
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, resolveQueueLabel, "Should be on resolve queue")

      expectation.fulfill()
    }

    dispatch_async(resolveQueue) {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, resolveQueueLabel, "Should be on resolve queue")
      source.resolve(42)
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testResolvedSynchronized() {
    let resolveQueueLabel = "resolve1"
    let resolveQueue = dispatch_queue_create(resolveQueueLabel, nil)

    let source = PromiseSource<Int>()
    source.resolve(42)

    let p = source.promise

    let expectation = expectationWithDescription("Promise didn't finish")

    dispatch_async(resolveQueue) {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, resolveQueueLabel, "Should be on resolve queue")

      p.dispatchSync().then { _ in
        let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        XCTAssertEqual(currentQueueLabel, resolveQueueLabel, "Should be on resolve queue")

        expectation.fulfill()
      }
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testQueue() {
    let resolveQueueLabel = "resolve1"
    let resolveQueue = dispatch_queue_create(resolveQueueLabel, nil)
    let dispatchQueueLabel = "dispatch1"
    let dispatchQueue = dispatch_queue_create(dispatchQueueLabel, nil)

    let source = PromiseSource<Int>(dispatch: .OnQueue(dispatchQueue))
    let p = source.promise

    let expectation = expectationWithDescription("Promise didn't finish")
    p.then { _ in
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, dispatchQueueLabel, "Should be on dispatch queue")

      expectation.fulfill()
    }

    dispatch_async(resolveQueue) {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, resolveQueueLabel, "Should be on resolve queue")
      source.resolve(42)
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testResolvedQueue() {
    let resolveQueueLabel = "resolve1"
    let resolveQueue = dispatch_queue_create(resolveQueueLabel, nil)
    let dispatchQueueLabel = "dispatch1"
    let dispatchQueue = dispatch_queue_create(dispatchQueueLabel, nil)

    let source = PromiseSource<Int>(dispatch: .OnQueue(dispatchQueue))
    source.resolve(42)

    let p = source.promise

    let expectation = expectationWithDescription("Promise didn't finish")

    dispatch_async(resolveQueue) {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, resolveQueueLabel, "Should be on resolve queue")

      p.then { _ in
        let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
        XCTAssertEqual(currentQueueLabel, dispatchQueueLabel, "Should be on dispatch queue")

        expectation.fulfill()
      }
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testQueueSynchronized() {
    let resolveQueueLabel = "resolve1"
    let resolveQueue = dispatch_queue_create(resolveQueueLabel, nil)
    let dispatchQueueLabel = "dispatch1"
    let dispatchQueue = dispatch_queue_create(dispatchQueueLabel, nil)

    let source = PromiseSource<Int>(dispatch: .OnQueue(dispatchQueue))
    let p = source.promise

    let expectation = expectationWithDescription("Promise didn't finish")
    p.dispatchSync().then { _ in
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, dispatchQueueLabel, "Should be on dispatch queue")

      expectation.fulfill()
    }

    dispatch_async(resolveQueue) {
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, resolveQueueLabel, "Should be on resolve queue")
      source.resolve(42)
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testQueueMain() {
    let resolveQueueLabel = "resolve1"
    let resolveQueue = dispatch_queue_create(resolveQueueLabel, nil)
    let dispatchQueueLabel = "dispatch1"
    let dispatchQueue = dispatch_queue_create(dispatchQueueLabel, nil)

    let source = PromiseSource<Int>(dispatch: .OnQueue(dispatchQueue))
    let p = source.promise

    let expectation = expectationWithDescription("Promise didn't finish")
    p.dispatchMain().then { _ in
      XCTAssert(NSThread.isMainThread(), "Should be on main queue")

      expectation.fulfill()
    }

    dispatch_async(resolveQueue) {
      source.resolve(42)
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }

  func testQueueMainQueue() {
    let resolveQueueLabel = "resolve1"
    let resolveQueue = dispatch_queue_create(resolveQueueLabel, nil)
    let dispatchQueueLabel = "dispatch1"
    let dispatchQueue = dispatch_queue_create(dispatchQueueLabel, nil)

    let source = PromiseSource<Int>()
    let p = source.promise

    let expectation = expectationWithDescription("Promise didn't finish")
    p.dispatchMain().dispatchOn(dispatchQueue).then { _ in
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, dispatchQueueLabel, "Should be on dispatch queue")

      expectation.fulfill()
    }

    dispatch_async(resolveQueue) {
      source.resolve(42)
    }

    waitForExpectationsWithTimeout(0.03, handler: nil)
  }
}