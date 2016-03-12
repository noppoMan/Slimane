import PackageDescription

let package = Package(
    name: "Slimane",
    dependencies: [
        .Package(url: "https://github.com/noppoMan/SlimaneMiddleware.git", majorVersion: 0, minor: 1),
    ]
)
