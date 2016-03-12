//
//  BodyParser.swift
//  slimane
//
//  Created by Yuki Takei on 1/16/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//
import Core

public extension Request {
    public var jsonBody : JSON? {
        return context["jsonBody"] as? JSON
    }

    public var formData: [String: String]? {
        return context["formData"] as? [String: String]
    }
}

public struct BodyParser: MiddlewareType {

    public init(){}

    public func handleRequest(req: Request, res: Response, next: MiddlewareChain) {

        guard let body = req.bodyString else {
            next(.Next)
            return
        }

        guard let contentType = req.contentType else {
            next(.Next)
            return
        }

        switch(contentType.type) {
        case "application/json":
            do {
                req.context["jsonBody"] = try JSONParser.parse(body)
            } catch {
                return next(.Error(error))
            }

        case "application/xml":
            Logger.warn("Xml parser has not been implemented.")

        case "application/x-www-form-urlencoded":
            req.context["formData"] = parseURLEncodedString(body)

        case "multipart/form-data":
            Logger.warn("Multipart parser has not been implemented.")

        default:
            Logger.warn("Unkown content type. Applied parseURLEncodedString")
            req.context["formData"] = parseURLEncodedString(body)
        }

        next(.Next)
    }
}


private func parseURLEncodedString(string: String) -> [String: String] {
    var parameters: [String: String] = [:]

    for parameter in string.splitBy("&") {
        let tokens = parameter.splitBy("=")

        if tokens.count >= 2 {
            let key = String(URLEncodedString: tokens[0])
            let value = String(URLEncodedString: tokens[1])

            if let key = key, value = value {
                parameters[key] = value
            }
        }
    }

    return parameters
}
