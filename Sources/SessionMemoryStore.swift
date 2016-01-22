//
//  SessionMemoryStore.swift
//  slimane
//
//  Created by Yuki Takei on 2/6/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

private var sessionMap = [String: [String: Any?]]()

public struct SessionMemoryStore: SessionStoreType {
    
    public func reload(sessionId: String, completion: ([String: Any?]?) -> Void) {
        guard let sesValues = sessionMap[sessionId] else {
            return completion(nil)
        }
        completion(sesValues)
    }
    
    public func store(key: String, values: [String: Any?], completion: () -> Void) {
        sessionMap[key] = values
        completion()
    }
    
    public func destroy(sessionId: String) {
        sessionMap[sessionId] = nil
    }
}
