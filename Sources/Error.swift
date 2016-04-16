//
//  Error.swift
//  Slimane
//
//  Created by Yuki Takei on 4/16/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

public enum Error: ErrorProtocol, CustomStringConvertible {
    case RouteNotFound(path: String)
    case ResourceNotFound(String)
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
        case InvalidArgument(let message):
            return message
        case Unexpected(let message):
            return message
        }
    }
}
