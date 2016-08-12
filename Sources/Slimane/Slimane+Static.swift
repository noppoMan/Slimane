//
//  Static.swift
//  Slimane
//
//  Created by Yuki Takei on 4/19/16.
//
//

import CLibUv

extension Slimane {
    public struct Static: AsyncMiddleware {
        let root: String
        
        let ignoreNotFoundInterruption: Bool

        public init(root: String, ignoreNotFoundInterruption: Bool = false){
            self.root = root
            self.ignoreNotFoundInterruption = ignoreNotFoundInterruption
        }
        
        public func respond(to request: Request, chainingTo next: AsyncResponder, result: @escaping ((Void) throws -> Response) -> Void) {
            guard let path = request.path , let ext = path.split(separator: ".").last, let mediaType = mediaType(forFileExtension: ext) else {
                return next.respond(to: request, result: result)
            }
            
            FS.readFile(root + path) { getData in
                do {
                    var response = Response(body: try getData())
                    response.contentType = mediaType
                    result {
                        response
                    }
                } catch UVError.rawUvError(let code) {
                    let e: Error
                    if code == -2 {
                        e = RoutingError.resourceNotFound(path: path)
                    } else {
                        e = UVError.rawUvError(code: code)
                    }
                    
                    result {
                        throw e
                    }
                } catch {
                    if self.ignoreNotFoundInterruption {
                        return next.respond(to: request, result: result)
                    }
                    
                    result {
                        throw error
                    }
                }
            }
        }
    }
}
