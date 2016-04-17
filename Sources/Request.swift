//
//  Request.swift
//  Slimane
//
//  Created by Yuki Takei on 4/17/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

let storageKeyForResponse = __SLIMANE_INTERNAL_STORAGE_KEY + "Response"

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
    
    internal var response: Response {
        get {
            return self.storage[storageKeyForResponse] as! Response
        }
        
        set {
            self.storage[storageKeyForResponse] = newValue
        }
    }
}
