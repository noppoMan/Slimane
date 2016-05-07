//
//  Request.swift
//  Slimane
//
//  Created by Yuki Takei on 4/16/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

let CRLF = "\r\n"

extension Response {
    var responseData: Data {
        var bodyData: Data = Data()
        if case .buffer(let data) = body {
            bodyData += data
        }
        return (description + CRLF).data + bodyData
    }
    
    var bodyLength: Int {
        if case .buffer(let data) = body {
            return data.bytes.count
        }
        return 0
    }
    
    func merged(_ target: Response) -> Response {
        var response = self
        for (k,v) in target.headers {
            response.headers[k] = v
        }
        for (k,v) in target.storage {
            response.storage[k] = v
        }
        response.version = target.version
        response.status = target.status
        response.body = target.body
        return response
    }
    
    var shouldDelegate: Bool {
        get {
            if let shouldDelegate = storage["shouldDelegate"] as? Bool {
                return shouldDelegate
            }
            return false
        }
        
        set {
            storage["shouldDelegate"] = newValue
        }
    }
}
