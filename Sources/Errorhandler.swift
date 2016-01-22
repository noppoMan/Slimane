//
//  Errorhandler.swift
//  slimane
//
//  Created by Yuki Takei on 1/16/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

public protocol ErrorHandler {
    func handle(req req: Request, res: Response, error: ErrorType)
}