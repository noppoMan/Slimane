//
//  Static.swift
//  Slimane
//
//  Created by Yuki Takei on 4/19/16.
//
//

extension Slimane {
    public struct Static: AsyncMiddleware {
        let root: String
        
        let ignoreNotFoundInterruption: Bool

        public init(root: String, ignoreNotFoundInterruption: Bool = false){
            self.root = root
            self.ignoreNotFoundInterruption = ignoreNotFoundInterruption
        }
        
        public func respond(to request: Request, chainingTo next: AsyncResponder, result: ((Void) throws -> Response) -> Void) {
            guard let path = request.path , ext = path.split(byString: ".").last, mediaType = mediaType(forFileExtension: ext) else {
                return next.respond(to: request, result: result)
            }
            
            FS.readFile(root + path) { getData in
                do {
                    var response = Response(body: try getData())
                    response.contentType = mediaType
                    result {
                        response
                    }
                } catch {
                    if self.ignoreNotFoundInterruption {
                        next.respond(to: request, result: result)
                    } else {
                        result {
                            throw error
                        }
                    }
                }
            }
        }
    }
}
