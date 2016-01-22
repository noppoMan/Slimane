//
//  callbacks.swift
//  slimane
//
//  Created by Yuki Takei on 2/8/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

import HTTP

public typealias BeforeWriteCallback = () -> ()
public typealias AfterWriteCallback = HTTP.Response? -> ()

extension Request {
    
    public var beforeWriteCallbacks: [BeforeWriteCallback] {
        initBeforeWriteCallbacksIfNeeded()
        return self.context["beforeWriteCallback"] as! [BeforeWriteCallback]
    }
    
    public var afterWriteCallbacks: [AfterWriteCallback] {
        initAfterWriteCallbacksIfNeeded()
        return self.context["afterWriteCallbacks"] as! [AfterWriteCallback]
    }
    
    public func appendBeforeWriteCallback(callback: BeforeWriteCallback){
        initBeforeWriteCallbacksIfNeeded()
        self.context["beforeWriteCallback"] = (self.context["beforeWriteCallback"] as! [BeforeWriteCallback]) + [callback]
    }
    
    public func appendAfterWriteCallback(callback: AfterWriteCallback){
        initAfterWriteCallbacksIfNeeded()
        self.context["afterWriteCallbacks"] = (self.context["afterWriteCallbacks"] as! [AfterWriteCallback]) + [callback]
    }
    
    private func initBeforeWriteCallbacksIfNeeded(){
        if self.context["beforeWriteCallback"] == nil {
            self.context["beforeWriteCallback"] = [BeforeWriteCallback]()
        }
    }
    
    private func initAfterWriteCallbacksIfNeeded(){
        if self.context["afterWriteCallbacks"] == nil {
           self.context["afterWriteCallbacks"] = [AfterWriteCallback]()
        }
    }
    
}