//
//  Result.swift
//  Promissum
//
//  Created by Tom Lokhorst on 2015-01-07.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import Foundation

public enum Result<T> {
  case Value(Box<T>)
  case Error(NSError)

  public var value: T? {
    switch self {
    case .Value(let boxed):
      let val = boxed.unbox
      return val
    case .Error:
      return nil
    }
  }

  public var error: NSError? {
    switch self {
    case .Error(let error):
      return error
    case .Value:
      return nil
    }
  }

  internal var state: State<T> {
    switch self {
    case .Value(let boxed):
      return .Resolved(boxed)
    case .Error(let error):
      return .Rejected(error)
    }
  }
}

extension Result: Printable {

  public var description: String {
    switch self {
    case .Value(let boxed):
      let val = boxed.unbox
      return "Value(\(val))"
    case .Error(let error):
      return "Error(\(error))"
    }
  }
}
