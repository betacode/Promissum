//
//  DispatchConcurrentTests.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-07-20.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation
import XCTest
import Promissum

class DispatchConcurrentTests: XCTestCase {

  func testSerial() {
    let queueLabel = "dispatchSerial"
    let queue = dispatch_queue_create(queueLabel, DISPATCH_QUEUE_SERIAL)

    var calls = 0

    let source = PromiseSource<Int>(dispatch: .OnQueue(queue))
    let p = source.promise

    let expectation = expectationWithDescription("Promise didn't finish")
    p.then { _ in
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, queueLabel, "Should be on dispatch queue")

      // Sleep current handler
      NSThread.sleepForTimeInterval(0.01)

      XCTAssertEqual(calls, 0, "This is first scheduled serial handler");
      calls += 1;
    }
    p.then { _ in
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, queueLabel, "Should be on dispatch queue")

      XCTAssertEqual(calls, 1, "This is second scheduled serial handler");
      calls += 2;

      expectation.fulfill()
    }

    source.resolve(42)

    waitForExpectationsWithTimeout(0.2, handler: nil)
  }

  func testConcurrent() {
    let queueLabel = "dispatchConcurrent"
    let queue = dispatch_queue_create(queueLabel, DISPATCH_QUEUE_CONCURRENT)

    var calls = 0

    let source = PromiseSource<Int>(dispatch: .OnQueue(queue))
    let p = source.promise

    let expectation = expectationWithDescription("Promise didn't finish")
    p.then { _ in
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, queueLabel, "Should be on dispatch queue")

      // Sleep current handler
      NSThread.sleepForTimeInterval(0.01)

      XCTAssertEqual(calls, 2, "This should be second to execute due to thread sleep");
      calls += 1;

      expectation.fulfill()
    }
    p.then { _ in
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      XCTAssertEqual(currentQueueLabel, queueLabel, "Should be on dispatch queue")

      XCTAssertEqual(calls, 0, "This should be first to execute due to thread sleep in other handler");
      calls += 2;
    }

    source.resolve(42)

    waitForExpectationsWithTimeout(0.2, handler: nil)
  }
}