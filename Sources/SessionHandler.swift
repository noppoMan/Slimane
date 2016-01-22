//
//  SessionHandler.swift
//  slimane
//
//  Created by Yuki Takei on 2/6/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

import Suv

public extension Request {
    var session: Session? {
        guard let session = self.context["session"] else {
            return nil
        }
        
        return session as? Session
    }
    
    var sessionId: String? {
        guard let sessionId = self.context["sessionId"] else {
            return nil
        }
        
        return sessionId as? String
    }
}

public final class SessionHandler: MiddlewareType {
    var session: Session
    
    public init(_ conf: SessionConfig){
        self.session = Session(conf: conf)
    }
    
    public func handleRequest(req: Request, res: Response, next: MiddlewareChain) {
        req.context["session"] = session
        
        if shouldSetCookie(req) {
            do {
                let cookie = try initCookieForSet()
                res.setHeader("Set-Cookie", cookie.serialize())
                let signedCookies = CookieParser.signedCookies(cookie.values, secret: self.session.secret)
                req.context["sessionId"] = signedCookies[self.session.keyName]
                next(nil)
            } catch {
                next(error)
            }
            return
        }
        
        guard let signedCookie = req.context["signedCookie"] as? [String: String], let sessionId = signedCookie[session.keyName] else {
            return next(nil)
        }
        
        req.context["sessionId"] = sessionId
        
        req.appendAfterWriteCallback({ [unowned self] _ in
            self.session.store(req.sessionId!) {}
        })
        
        session.reload(sessionId) {
            next(nil)
        }
    }
    
    private func shouldSetCookie(req: Request) -> Bool {
        guard let cookie = req.cookies, let cookieValue = cookie[session.keyName] else {
            return true
        }
        
        do {
            let result = try CookieParser.signedCookie(cookieValue, secret: self.session.secret)
            return result != cookieValue
        } catch {
            return false
        }
    }
    
    private func initCookieForSet() throws -> Cookie {
        var cookieValues = [String: String]()
        
        let sessionId = try CookieParser.signSync(Session.generateId().toString(.Hex)!, secret: session.secret)
        cookieValues[session.keyName] = "s:" + sessionId
        
        var cookie = Cookie()
        cookie.values = cookieValues
        cookie.expires = session.expires
        
        cookie.httpOnly = true
        
        return cookie
    }
}
