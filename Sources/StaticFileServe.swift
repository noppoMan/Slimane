//
//  StaticFileServe.swift
//  slimane
//
//  Created by Yuki Takei on 1/16/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

import Core
import Suv
import CLibUv

public struct StaticFileServe: MiddlewareType {
    let root: String
    
    public init(_ root: String){
        self.root = root
    }
    
    public func handleRequest(req: Request, res: Response, next: MiddlewareChain) {
        guard let path = req.uri.path else {
            return next(.Next)
        }
        
        let ext = path.splitBy(".").last!
        
        if !MimeType.matchWithAnyStaticFileExtension(ext) {
            return next(.Next)
        }
        
        FS.readFile(root + path) { data in
            switch(data) {
            case .Success(let buffer):
                res.setHeader("Content-Type", MimeType.mimeTypeFromExtension(ext))
                res.write(buffer)
                
            case .Error(let err):
                next(.Error(err))
            }
        }
    }
}