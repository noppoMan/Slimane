//
//  Cookie.swift
//  slimane
//
//  Created by Yuki Takei on 2/6/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

internal extension String {
    var urlEncodedValue: String? {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    }
    
    var urlDecodedValue: String? {
        return self.stringByRemovingPercentEncoding
    }
}

public struct Cookie {
    var setCookie: Bool = false
    
    var expires: String? = nil
    
    var domain: String? = nil
    
    var name: String? = nil
    
    var path: String? = nil
    
    var values: [String: String] = [:]
    
    var secure: Bool = false
    
    var httpOnly: Bool = false
}

extension Cookie {
    // should be called when setCookie
    public func serialize() -> String {
        var cookieDict: [String: String?] = [
            "expires": expires,
            "domain": domain,
            "name": name,
            "path": path,
        ]
        
        //"secure": secure ? "true",
        values.forEach { k,v in cookieDict[k] = v }
        
        var serialized = cookieDict.flatMap { k,v in
            if let val = v {
                return "\(k)=\((val).urlEncodedValue!);"
            }
            return nil
        }.joinWithSeparator(" ")
        
        if secure {
            serialized += " secure;"
        }
        
        if httpOnly {
            serialized += " HttpOnly"
        }
        
        return serialized
    }
}
