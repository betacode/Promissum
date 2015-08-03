//
//  PromiseSource.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2014-10-11.
//  Copyright (c) 2014 Tom Lokhorst. All rights reserved.
//

import Foundation

// This Notifier is used to implement Promise.map
protocol OriginalSource {
  func registerHandler(dispatch: DispatchMethod, handler: () -> Void)
}

public class PromiseSource<T> : OriginalSource {
  typealias ResultHandler = Result<T> -> Void

  public var state: State<T>
  public var warnUnresolvedDeinit: Bool

  private let originalSource: OriginalSource?
  internal let dispatchMethod: DispatchMethod

  private var handlers: [(Result<T> -> Void, DispatchMethod)] = []

  // MARK: Initializers & deinit

  public convenience init(value: T) {
    self.init(state: .Resolved(Box(value)), dispatch: .Unspecified, originalSource: nil, warnUnresolvedDeinit: false)
  }

  public convenience init(error: NSError) {
    self.init(state: .Rejected(error), dispatch: .Unspecified, originalSource: nil, warnUnresolvedDeinit: false)
  }

  public convenience init(dispatch: DispatchMethod = .Unspecified, warnUnresolvedDeinit: Bool = true) {
    self.init(state: .Unresolved, dispatch: dispatch, originalSource: nil, warnUnresolvedDeinit: warnUnresolvedDeinit)
  }

  internal init(state: State<T>, dispatch: DispatchMethod, originalSource: OriginalSource?, warnUnresolvedDeinit: Bool) {
    self.state = state
    self.dispatchMethod = dispatch
    self.originalSource = originalSource
    self.warnUnresolvedDeinit = warnUnresolvedDeinit
  }

  deinit {
    if warnUnresolvedDeinit {
      switch state {
      case .Unresolved:
        println("PromiseSource.deinit: WARNING: Unresolved PromiseSource deallocated, maybe retain this object?")
      default:
        break
      }
    }
  }


  // MARK: Computed properties

  public var promise: Promise<T> {
    return Promise(source: self)
  }


  // MARK: Resolve / reject

  public func resolve(value: T) {

    resolveResult(.Value(Box(value)))
  }

  public func reject(error: NSError) {

    resolveResult(.Error(error))
  }

  internal func resolveResult(result: Result<T>) {

    switch state {
    case .Unresolved:
      state = result.state

      executeResultHandlers(result)
    default:
      break
    }
  }

  private func executeResultHandlers(result: Result<T>) {

    // Call all previously scheduled handlers
    callHandlers(result, handlers)

    // Cleanup
    handlers = []
  }

  // MARK: Adding result handlers

  internal func registerHandler(dispatch: DispatchMethod, handler: () -> Void) {
    addOrCallResultHandler(dispatch, handler: { _ in handler() })
  }

  internal func addOrCallResultHandler(dispatch: DispatchMethod, handler: Result<T> -> Void) {

    switch state {
    case State<T>.Unresolved(let source):
      // Register with original source
      // Only call handlers after original completes
      if let originalSource = originalSource {
        originalSource.registerHandler(dispatch) {

          switch self.state {
          case State<T>.Resolved(let boxed):
            // Value is already available, call handler immediately
            callHandlers(Result.Value(boxed), [(handler, dispatch)])

          case State<T>.Rejected(let error):
            // Error is already available, call handler immediately
            callHandlers(Result.Error(error), [(handler, dispatch)])

          case State<T>.Unresolved(let source):
            assertionFailure("callback should only be called if state is resolved or rejected")
          }
        }
      }
      else {
        // Save handler for later
        handlers.append((handler, dispatch))
      }

    case State<T>.Resolved(let boxed):
      // Value is already available, call handler immediately
      callHandlers(Result.Value(boxed), [(handler, dispatch)])

    case State<T>.Rejected(let error):
      // Error is already available, call handler immediately
      callHandlers(Result.Error(error), [(handler, dispatch)])
    }
  }
}

internal func callHandlers<T>(arg: T, handlers: [(T -> Void, DispatchMethod)]) {

  for (handler, dispatch) in handlers {
    switch dispatch {
    case .Unspecified:

      if NSThread.isMainThread() {
        handler(arg)
      }
      else {
        dispatch_async(dispatch_get_main_queue()) {
          handler(arg)
        }
      }

    case .Synchronous:

      handler(arg)

    case let .OnQueue(targetQueue):
      let currentQueueLabel = String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!
      let targetQueueLabel = String(UTF8String: dispatch_queue_get_label(targetQueue))!

      // Assume on correct queue if labels match, but be conservative if label is empty
      let alreadyOnQueue = currentQueueLabel == targetQueueLabel && currentQueueLabel != ""

      if alreadyOnQueue {
        handler(arg)
      }
      else {
        dispatch_async(targetQueue) {
          handler(arg)
        }
      }

    }
  }
}
