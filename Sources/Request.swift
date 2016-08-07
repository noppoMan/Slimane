//
//  Request.swift
//  Slimane
//
//  Created by Yuki Takei on 4/17/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

extension Request {
    public var params: [String: String] {
        get {
            guard let params = storage["params"] as? [String: String] else {
                return [:]
            }
            
            return params
        }
        
        set {
            storage["params"] = newValue
        }
    }
    
    public var isKeepAlive: Bool {
        if version.minor == 0 {
            return connection?.lowercased().index(of: "keep-alive") != nil
        }
        
        return connection?.lowercased().index(of: "close") == nil
    }
}
