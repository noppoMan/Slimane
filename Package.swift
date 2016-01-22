import PackageDescription

#if os(OSX)
    let openSSLRepo = "https://github.com/noppoMan/COpenSSL-OSX.git"
#else
    let openSSLRepo = "https://github.com/noppoMan/COpenSSL.git"
#endif

let package = Package(
    name: "Slimane",
    dependencies: [
        .Package(url: "https://github.com/noppoMan/CLibUv.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/noppoMan/Suv.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/noppoMan/SlimaneHTTP.git", majorVersion: 0, minor: 1),
        .Package(url: openSSLRepo, majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/noppoMan/HTTPParser.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/Core.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/CURIParser.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/CHTTPParser.git", majorVersion: 0, minor: 1)
    ]
 )
