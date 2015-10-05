//
//  AVFoundation+Promise.swift
//  PromissumExtensions
//
//  Created by Tom Lokhorst on 2015-08-22.
//  Copyright (c) 2015 Tom Lokhorst. All rights reserved.
//

import AVFoundation

#if CARTHAGE
  import Promissum
#endif


extension AVCaptureDevice {
  public static func requestAccessForMediaTypePromise(mediaType: String) -> Promise<Bool, NoError> {
    let source = PromiseSource<Bool, NoError>()

    self.requestAccessForMediaType(mediaType) { granted in
      dispatch_async(dispatch_get_main_queue()) {
        source.resolve(granted)
      }
    }

    return source.promise
  }
}
