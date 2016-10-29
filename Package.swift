import PackageDescription

let package = Package(
    name: "Slimane",
    targets: [
        Target(name: "Performance", dependencies: ["Slimane"]),
        Target(name: "WebAppExample", dependencies: ["Slimane"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/noppoMan/Skelton.git", majorVersion: 0, minor: 10)
    ]
)
