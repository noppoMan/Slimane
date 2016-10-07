//
//  Static.swift
//  Slimane
//
//  Created by Yuki Takei on 4/19/16.
//
//

//import CLibUv
//
public enum StaticMiddlewareError: Error {
    case resourceNotFound(path: String)
}

extension StaticMiddlewareError: CustomStringConvertible {
    public var description: String {
        switch(self) {
        case .resourceNotFound(let resourceName):
            return "\(resourceName) is not found"
        }
    }
}

extension Slimane {
    public struct Static: Middleware {

        let root: String
        
        let ignoreNotFoundInterruption: Bool

        public init(root: String, ignoreNotFoundInterruption: Bool = false){
            self.root = root
            self.ignoreNotFoundInterruption = ignoreNotFoundInterruption
        }
        
        public func respond(_ request: Request, _ response: Response, _ responder: @escaping (Chainer) -> Void) {
            guard let path = request.path , let ext = path.split(separator: ".").last, let mediaType = mediaType(forFileExtension: ext) else {
                return responder(.next(request, response))
            }
            
            var response = response
            
            File.read(path: root + path) { result in
                switch result {
                case .success(let data):
                    response.contentType = mediaType
                    response.data(data)
                    responder(.respond(response))
                case .failure(let error):
                    switch error {
                    case UVError.rawUvError(let code):
                        let e: Error
                        if code == -2 {
                            e = StaticMiddlewareError.resourceNotFound(path: path)
                        } else {
                            e = UVError.rawUvError(code: code)
                        }
                        responder(.error(e))
                    default:
                        if self.ignoreNotFoundInterruption {
                            return responder(.next(request, response))
                        }
                        responder(.error(error))
                    }
                }
            }
        }
    }
}
