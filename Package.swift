import PackageDescription

let package = Package(
	name: "Slimane",
	targets: [
        Target(name: "Performance", dependencies: ["Slimane"])
    ],
	dependencies: [
      .Package(url: "https://github.com/noppoMan/Skelton.git", majorVersion: 0, minor: 8),
      .Package(url: "https://github.com/slimane-swift/Time.git", majorVersion: 0, minor: 2),
      .Package(url: "https://github.com/slimane-swift/POSIXRegex.git", majorVersion: 0, minor: 12),
      .Package(url: "https://github.com/slimane-swift/AsyncResponderConvertible.git", majorVersion: 0, minor: 5),
      .Package(url: "https://github.com/slimane-swift/AsyncHTTPSerializer.git", majorVersion: 0, minor: 2),
      .Package(url: "https://github.com/slimane-swift/HTTPUpgradeAsync.git", majorVersion: 0, minor: 2),
  ]
)
