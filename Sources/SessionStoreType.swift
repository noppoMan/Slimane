//
//  SessionStoreType.swift
//  slimane
//
//  Created by Yuki Takei on 2/6/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

public protocol SessionStoreType {
    func destroy(key: String)
    func reload(sessionId: String, completion: ([String: Any?]?) -> Void)
    func store(sessionId: String, values: [String: Any?], completion: () -> Void)
}