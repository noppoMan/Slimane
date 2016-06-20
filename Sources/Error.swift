//
//  Error.swift
//  Slimane
//
//  Created by Yuki Takei on 4/16/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

public enum Error: ErrorProtocol, CustomStringConvertible {
    case routeNotFound(path: String)
    case resourceNotFound(String)
    case invalidArgument(String)
    case unexpected(String)
}

extension Error {
    public var description: String {
        switch(self) {
        case .routeNotFound(let path):
            return "\(path) is not found"
        case .resourceNotFound(let resourceName):
            return "The resource \(resourceName) is not found"
        case invalidArgument(let message):
            return message
        case unexpected(let message):
            return message
        }
    }
}
