//
//  AsyncRoute.swift
//  Slimane
//
//  Created by Yuki Takei on 4/16/16.
//
//

import POSIXRegex

public protocol AsyncRoute: AsyncResponder {
    var path: String { get }
    var regexp: Regex { get }
    var paramKeys: [String] { get }
    var method: S4.Method { get }
    var handler: AsyncResponder { get }
    var middlewares: [AsyncMiddleware] { get }
}

extension AsyncRoute {
    public func respond(to request: Request, result: @escaping ((Void) throws -> Response) -> Void) {
        result {
            Response(status: .ok)
        }
    }
    
    public func params(_ request: Request) -> [String: String] {
        guard let path = request.path else {
            return [:]
        }
        
        var parameters: [String: String] = [:]
        
        let values = regexp.groups(path)
        
        for (index, key) in paramKeys.enumerated() {
            parameters[key] = values[index]
        }
        
        return parameters
    }
}

public struct BasicRouter: AsyncRoute {
    public let path: String
    public let paramKeys: [String]
    public let regexp: Regex
    public let method: S4.Method
    public let handler: AsyncResponder
    public let middlewares: [AsyncMiddleware]
    
    public init(method: S4.Method, path: String, middlewares: [AsyncMiddleware] = [], handler: AsyncResponder) {
        let parameterRegularExpression = try! Regex(pattern: ":([[:alnum:]_]+)")
        let pattern = parameterRegularExpression.replace(path, withTemplate: "([[:alnum:]_-]+)")
        
        self.method = method
        self.path = path
        self.regexp = try! Regex(pattern: "^" + pattern + "$")
        self.paramKeys = parameterRegularExpression.groups(path)
        self.middlewares = middlewares
        self.handler = handler
    }
}

