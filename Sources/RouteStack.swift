//
//  RouteStack.swift
//  slimane
//
//  Created by Yuki Takei on 1/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

import Core
import HTTP
import HTTPParser

private struct FunctionHandlerWrapper: RouteType {
    var handler: (Request, Response) throws -> ()
    
    func handleRequest(req: Request, res: Response) throws {
        try handler(req, res)
    }
}

struct RouteStack {
    let path: String?
    let method: HTTP.Method
    let paramKeys: [String]
    let regexp: Regex
    let handler: RouteType

    init(path _path: String?, method: HTTP.Method = .GET, handler: RouteType) {
        let path = [_path].flatMap { $0 }.joinWithSeparator("")
        let regexpForParams = try! Regex(pattern: ":([[:alnum:]]+)")
        let pattern = regexpForParams.replace(path, withTemplate: "([[:alnum:]_-]+)")
        
        self.path = path
        self.method = method
        self.paramKeys = regexpForParams.groups(path)
        self.regexp = try! Regex(pattern: "^\(pattern)$")
        self.handler = handler
    }
    
    init(path _path: String?, method: HTTP.Method = .GET, functionHandler: Route) {
        self.init(path: _path, method: method, handler: FunctionHandlerWrapper(handler: functionHandler))
    }
}

extension RouteStack {
    func shouldHandle(req: Request) -> Bool {
        guard let path = req.uri.path else {
            return false
        }

        let shouldHandle = regexp.matches(path) && method == req.method

        if shouldHandle {
            let values = regexp.groups(path)
            for (index, key) in paramKeys.enumerate() {
                req.params[key] = values[index]
            }
        }

        return shouldHandle
    }
}
