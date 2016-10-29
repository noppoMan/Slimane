//
//  Route.swift
//  Slimane
//
//  Created by Yuki Takei on 2016/10/05.
//
//

protocol Route: Responder {
    var path: String { get }
    var regexp: Regex { get }
    var paramKeys: [String] { get }
    var method: HTTPCore.Method { get }
    var handler: Respond { get }
    var middlewares: [Middleware] { get }
}

extension Route {
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

struct BasicRoute: Route {
    let path: String
    let regexp: Regex
    let method: HTTPCore.Method
    let handler: Respond
    let paramKeys: [String]
    let middlewares: [Middleware]
    
    init(method: HTTPCore.Method, path: String, middlewares: [Middleware] = [], handler: @escaping Respond){
        let parameterRegularExpression = try! Regex(pattern: ":([[:alnum:]_]+)")
        let pattern = parameterRegularExpression.replace(path, withTemplate: "([[:alnum:]_-]+)")
        
        self.method = method
        self.path = path
        self.regexp = try! Regex(pattern: "^" + pattern + "$")
        self.paramKeys = parameterRegularExpression.groups(path)
        self.middlewares = middlewares
        self.handler = handler
    }
    
    func respond(_ request: Request, _ response: Response, _ responder: @escaping (Chainer) -> Void) {
        self.handler(request, response, responder)
    }
}
