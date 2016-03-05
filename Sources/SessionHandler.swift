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
        
        
        var err: ErrorType? = nil
        
        // other thread
        let onThread = { [unowned self] in
            if self.shouldSetCookie(req) {
                do {
                    let cookie = try self.initCookieForSet()
                    res.setHeader("Set-Cookie", cookie.serialize())
                    let signedCookies = CookieParser.signedCookies(cookie.values, secret: self.session.secret)
                    req.context["sessionId"] = signedCookies[self.session.keyName]
                } catch {
                    err = error
                }
            }
        }
        
        // main loop
        let onFinish = { [unowned self] in
            if let e = err {
                next(e)
                return
            }
            
            if res.getHeader("set-cookie") != nil {
                next(nil)
                return
            }
            
            guard let signedCookie = req.context["signedCookie"] as? [String: String], let sessionId = signedCookie[self.session.keyName] else {
                next(nil)
                return
            }
            
            req.context["sessionId"] = sessionId
            
            req.appendAfterWriteCallback({ _ in
                self.session.store(req.sessionId!) {}
            })
            
            self.session.reload(sessionId) {
                next(nil)
            }
        }
        
        Process.qwork(onThread: onThread, onFinish: onFinish)
    }
    
    private func shouldSetCookie(req: Request) -> Bool {
        guard let cookie = req.cookies, let cookieValue = cookie[session.keyName] else {
            return true
        }
        
        do {
            let dec = try CookieParser.signedCookie(cookieValue, secret: self.session.secret)
            let sesId = try CookieParser.decode(cookieValue)
            return dec != sesId
        } catch {
            return true
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
