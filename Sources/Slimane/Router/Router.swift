//
//  Router.swift
//  Slimane
//
//  Created by Yuki Takei on 2016/10/05.
//
//

struct Router {
    var routes = [Route]()
    
    public func matchedRoute(for request: Request) -> (Route, Request)? {
        guard let path = request.path else {
            return nil
        }
        
        //let request = request
        for route in routes {
            if route.regexp.matches(path) && request.method == route.method {
                var request = request
                request.params = route.params(request)
                return (route, request)
            }
        }
        
        return nil
    }
}
