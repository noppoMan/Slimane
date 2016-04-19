import PackageDescription

let package = Package(
	name: "Slimane",
	dependencies: [
      .Package(url: "https://github.com/slimane-swift/Middleware.git", majorVersion: 0, minor: 1),
      .Package(url: "https://github.com/slimane-swift/Skelton.git", majorVersion: 0, minor: 3),
      .Package(url: "https://github.com/slimane-swift/Time.git", majorVersion: 0, minor: 1),
      .Package(url: "https://github.com/slimane-swift/POSIXRegex.git", majorVersion: 0, minor: 4),
      .Package(url: "https://github.com/slimane-swift/AsyncResponderConvertible.git", majorVersion: 0, minor: 1),
  ]
)
