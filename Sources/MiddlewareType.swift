//
//  MiddlewareType.swift
//  slimane
//
//  Created by Yuki Takei on 1/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//


public enum MiddlewareChainType {
    case Next
    case Error(ErrorType)
}

public typealias MiddlewareChain = (MiddlewareChainType) -> Void

public protocol MiddlewareType {
    func handleRequest(req: Request, res: Response, next: MiddlewareChain) throws
}