//
//  Serve.swift
//  Slimane
//
//  Created by Yuki Takei on 4/16/16.
//
//

extension Slimane {
    public func listen(loop: Loop = Loop.defaultLoop, host: String = "0.0.0.0", port: Int = 3000) throws {
        var server = HTTPServer(loop: loop, ipcEnable: Cluster.isWorker) { [unowned self] in
            do {
                let (request, stream) = try $0()
                self.dispatch(request, stream: stream)
            } catch {
                print(error)
            }
        }

        server.setNoDelay = self.setNodelay
        server.keepAliveTimeout = self.keepAliveTimeout
        server.backlog = self.backlog
        
        if Cluster.isMaster {
            try server.bind(Address(host: host, port: port))
        }
        try server.listen()
    }
}
