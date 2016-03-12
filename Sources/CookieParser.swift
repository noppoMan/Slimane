//
//  CookieParser.swift
//  slimane
//
//  Created by Yuki Takei on 2/6/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

import Suv

extension Request {
    public var cookies: [String: String]? {
        return context["cookie"] as? [String: String]
    }
}

public struct CookieParser:  MiddlewareType {
    let secret: String  
    
    public init(secret: String){
        self.secret = secret
    }
    
    public func handleRequest(req: Request, res: Response, next: MiddlewareChain) {
        guard let cookieStr = req.getHeader("cookie") else {
            return next(.Next)
        }
        
        Process.qwork(onThread: {
            let cookie = CookieParser.parse(cookieStr)
            req.context["cookie"] = cookie
            req.context["signedCookie"] = CookieParser.signedCookies(cookie, secret: self.secret)
        }, onFinish: {
            next(.Next)
        })
    }
    
    public static func parse(cookieStr: String) -> [String: String] {
        let cookies = cookieStr.splitBy(";").flatMap { return $0.trim() }
        var cookieValues = [String: String]()
        
        for pairs in cookies {
            let splited = pairs.characters.split(1, allowEmptySlices: false) { $0 == "=" }.map { String($0) }
            let key = splited.first!
            let val = splited.count > 1 ? splited[1].urlDecodedValue! : ""
            
            cookieValues[key] = val
        }
        
        return cookieValues
    }
}


extension CookieParser {
    public static func signedCookies(cookie: [String: String], secret: String) -> [String: String] {
        var signedCookie = [String: String]()
        
        cookie.forEach { k,v in
            do {
                signedCookie[k] = try self.signedCookie(v, secret: secret)
            } catch {
                // noop
            }
        }
        
        return signedCookie
    }
    
    public static func decode(val: String) throws -> String {
        let str = val.substringWithRange(Range<String.Index>(start: val.startIndex.advancedBy(2), end: val.endIndex))
        let searchCharacter: Character = "."
        guard let index = str.lowercaseString.characters.indexOf(searchCharacter) else {
            throw Error.InvalidArgument("Invalid cookie value")
        }
        return str.substringWithRange(Range<String.Index>(start: str.startIndex, end: index))
    }
    
    public static func signedCookie(val: String, secret: String) throws -> String? {
        let signedPrefix = val.substringWithRange(Range<String.Index>(start: val.startIndex, end: val.startIndex.advancedBy(2)))
        if signedPrefix != "s:" {
            return nil
        }
        
        return try unsignSync(val, secret: secret)
    }
    
    public static func signSync(val: String, secret: String) throws -> String {
        let encrypted = try Crypto(.SHA256).hashSync(secret)
        
        return "s:\(val).\(encrypted.toString(.Base64)!)"
    }
    
    public static func unsignSync(val: String, secret: String) throws -> String {
        let str = try decode(val)
        
        let sha1 = Crypto(.SHA1)
        let mac = try signSync(str, secret: secret)
        
        let sha1mac = try sha1.hashSync(mac)
        let sha1val = try sha1.hashSync(val)
        
        if sha1mac.bytes != sha1val.bytes {
            throw Error.InvalidArgument("Invalid session value")
        }
        
        return str
    }
}
