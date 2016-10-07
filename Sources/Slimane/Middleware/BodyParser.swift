//
//  BodyParser.swift
//  Slimane
//
//  Created by Yuki Takei on 2016/10/07.
//
//

@_exported import SwiftyJSON

extension Request {
    public var json: SwiftyJSON.JSON? {
        get {
            return self.storage["jsonBody"] as? SwiftyJSON.JSON
        }
        
        set {
            self.storage["jsonBody"] = newValue
        }
    }
    
    public var formData: URLEncodedForm? {
        get {
            return self.storage["formData"] as? URLEncodedForm
        }
        
        set {
            self.storage["formData"] = newValue
        }
    }
}

public struct BodyParser {
    
    public struct URLEncoded: Middleware {
        public init(){}
        
        public func respond(_ request: Request, _ response: Response, _ responder: @escaping (Chainer) -> Void) {
            guard let contentType = request.contentType else {
                return responder(.next(request, response))
            }
            var request = request
            
            do {
                if case .buffer(let data) = request.body {
                    switch (contentType.type, contentType.subtype) {
                    case ("application", "x-www-form-urlencoded"):
                        request.formData = try URLEncodedFormParser().parse(data: data)
                    default:
                        break
                    }
                }
            } catch {
                responder(.error(error))
                return
            }
            
            responder(.next(request, response))
        }
    }
    
    public struct JSON: Middleware {
        public init(){}
        
        public func respond(_ request: Request, _ response: Response, _ responder: @escaping (Chainer) -> Void) {
            guard let contentType = request.contentType else {
                return responder(.next(request, response))
            }
            var request = request
            
            if case .buffer(let data) = request.body {
                switch (contentType.type, contentType.subtype) {
                case ("application", "json"):
                    request.json = SwiftyJSON.JSON(data: data)
                default:
                    break
                }
            }
            
            responder(.next(request, response))
        }
    }
}
