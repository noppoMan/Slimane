//
//  Error.swift
//  slimane
//
//  Created by Yuki Takei on 1/16/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

public enum Error: ErrorType, CustomStringConvertible {
    case RouteNotFound(path: String)
    case ResourceNotFound(String)
    case RuntimeError(String)
    case InvalidArgument(String)
    case Unexpected(String)
}

extension Error {
    public var description: String {
        switch(self) {
        case .RouteNotFound(let path):
            return "\(path) is not found"
        case .ResourceNotFound(let resourceName):
            return "The resource \(resourceName) is not found"
        case .RuntimeError(let message):
            return message
        case InvalidArgument(let message):
            return message
        case Unexpected(let message):
            return message
        }
    }
}