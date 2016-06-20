import PackageDescription

let package = Package(
	name: "Slimane",
	dependencies: [
      .Package(url: "https://github.com/slimane-swift/Skelton.git", majorVersion: 0, minor: 7),
      .Package(url: "https://github.com/slimane-swift/Time.git", majorVersion: 0, minor: 2),
      .Package(url: "https://github.com/Zewo/POSIXRegex.git", majorVersion: 0, minor: 7),
      .Package(url: "https://github.com/slimane-swift/AsyncResponderConvertible.git", majorVersion: 0, minor: 4),
      .Package(url: "https://github.com/noppoman/AsyncHTTPSerializer.git", majorVersion: 0, minor: 1),
  ]
)
