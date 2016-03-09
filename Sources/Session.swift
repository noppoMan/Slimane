//
//  Session.swift
//  slimane
//
//  Created by Yuki Takei on 2/6/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

import Suv

public struct SessionConfig {
    public private(set) var store: SessionStoreType
    
    public let keyName: String
    
    public let secret: String
    
    public let expires: String?
    
    public init(keyName: String = "slimane_sesid", secret: String, expires: String? = nil, store: SessionStoreType = SessionMemoryStore()){
        self.keyName = keyName
        self.secret = secret
        self.store = store
        self.expires = expires
    }
}

public final class Session {
    
    private var conf: SessionConfig
    
    var values = [String: Any?]()
    
    init(conf: SessionConfig){
        self.conf = conf
    }
    
    public var keyName: String {
        return self.conf.keyName
    }
    
    public var secret: String {
        return self.conf.secret
    }
    
    public var expires: String? {
        return self.conf.expires
    }
    
    public var hashValue: Int {
        return self.conf.keyName.hashValue
    }
    
    public subscript(key: String) -> Any? {
        get {
            guard let value = self.values[key] else {
                return nil
            }
            
            return value
        }
        
        set {
            self.values[key] = newValue
        }
    }
    
    public func reload(sesId: String, completion: () -> Void){
        self.conf.store.reload(sesId, completion: { [unowned self] values in
            if let values = values {
                self.values = values
            }
            completion()
        })
    }
    
    public func store(sessionId: String, completion: () -> Void) {
        self.conf.store.store(sessionId, values: values, completion: completion)
    }
    
    public func destroy(sesId: String){
        self.conf.store.destroy(sesId)
    }
    
    public static func generateId(size: UInt = 12) throws -> Buffer {
        return try Crypto.randomBytesSync(size)
    }
}