import PackageDescription

let package = Package(
	name: "Slimane",
	dependencies: [
      .Package(url: "https://github.com/slimane-swift/Middleware.git", majorVersion: 0, minor: 4),
      .Package(url: "https://github.com/slimane-swift/Skelton.git", majorVersion: 0, minor: 5),
      .Package(url: "https://github.com/slimane-swift/Time.git", majorVersion: 0, minor: 2),
      .Package(url: "https://github.com/slimane-swift/POSIXRegex.git", majorVersion: 0, minor: 7),
      .Package(url: "https://github.com/slimane-swift/AsyncResponderConvertible.git", majorVersion: 0, minor: 3),
  ]
)
