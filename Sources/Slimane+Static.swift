//
//  Static.swift
//  Slimane
//
//  Created by Yuki Takei on 4/19/16.
//
//

extension Slimane {
    public struct Static: MiddlewareType {
        let root: String

        public init(root: String){
            self.root = root
        }

        public func respond(_ req: Request, res: Response, next: MiddlewareChain) {
            guard let path = req.path , ext = path.split(byString: ".").last, mediaType = mediaType(forFileExtension: ext) else {
                return next(.Chain(req, res))
            }

            FS.readFile(root + path) {
                switch($0) {
                case .Success(let buffer):
                    var res = res
                    res.contentType = mediaType
                    res.body = .buffer(buffer.data)
                    next(.Chain(req, res))
                case .Error(_):
                    next(.Error(Error.ResourceNotFound("\(path) is not found")))
                }
            }
        }
    }
}
