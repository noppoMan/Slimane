////
////  Request.swift
////  Slimane
////
////  Created by Yuki Takei on 4/16/16.
////  Copyright © 2016 MikeTOKYO. All rights reserved.
////

extension Response {
    
    public init(redirect location: String) {
        let headers: Headers = ["Location": location, "Cache-Control": "max-age=0, no-cache, no-store"]
        self.init(status: .movedPermanently, headers: headers, body: [])
    }
    
    public init(status: Status = .ok, headers: Headers = [:], body: String) {
        self.init(
            status: status,
            headers: headers,
            body: .buffer(body.data)
        )
    }
    
    var bodyLength: Int {
        if case .buffer(let data) = body {
            return data.count
        }
        return 0
    }
    
    public var isKeepAlive: Bool {
        if version.minor == 0 {
            return connection?.lowercased().index(of: "keep-alive") != nil
        }
        
        return connection?.lowercased().index(of: "close") == nil
    }
    
    public mutating func status(_ status: HTTPCore.Status) {
        self.status = status
    }
    
    public mutating func json(_ json: SwiftyJSON.JSON) {
        self.headers["Content-Tyoe"] = "application/json"
        do {
            self.data(try json.rawData())
        } catch {
            self.data("{}".data)
        }
    }
    
    public mutating func redirect(to location: String){
        self.status = .movedPermanently
        self.headers["Location"] = location
        self.headers["Cache-Control"] = "max-age=0, no-cache, no-store"
    }
    
    public mutating func text(_ body: String) {
        let data = body.data
        self.body = .buffer(data)
        self.headers["Content-Length"] = data.count.description
    }
    
    public mutating func data(_ body: Data) {
        self.body = .buffer(body)
        self.headers["Content-Length"] = body.count.description
    }
    
    public mutating func stream(_ body: @escaping (WritableStream, @escaping (Result<Void>) -> Void) -> Void) {
        self.body = .writer(body)
        self.headers["Transfer-Encoding"] = "chunked"
    }
}
