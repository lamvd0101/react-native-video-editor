//
//  TKRNEmitter.swift
//  TikiReactNative
//
//  Created by LAP01378 on 2/2/21.
//

import React

@objc(VideoEditEmitter)
public class VideoEditEmitter: RCTEventEmitter {
    public override class func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    static var emitter: RCTEventEmitter?
    
    override init() {
        super.init()
        VideoEditEmitter.emitter = self
    }
    
    public override func supportedEvents() -> [String] {
      ["logEvent"]
    }
    
    public static func releaseEmitter() -> Void {
        VideoEditEmitter.emitter = nil
    }
    
    public static func logEvent(params: Any) -> Void {
        guard VideoEditEmitter.emitter?.bridge != nil else {
            return
        }
        VideoEditEmitter.emitter?.sendEvent(withName: "logEvent", body: params)
    }
}

