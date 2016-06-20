//
//  Request.swift
//  Slimane
//
//  Created by Yuki Takei on 4/16/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

extension Response {
    
    public init(redirect location: String) {
        let headers: Headers = ["Location": location]
        self.init(status: .movedPermanently, headers: headers, body: [])
    }
    
    var bodyLength: Int {
        if case .buffer(let data) = body {
            return data.bytes.count
        }
        return 0
    }
    
    public var shouldKeepAlive: Bool {
        return connection?.lowercased() == "keep-alive"
    }
}
