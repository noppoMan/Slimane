//
//  RouteType.swift
//  slimane
//
//  Created by Yuki Takei on 1/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

public protocol RouteType {
    func handleRequest(req: Request, res: Response) throws
}