# Slimane Install Guide

## Dependent Libraries
* noppoMan/Suv
* noppoMan/CLibUV
* noppoMan/COpenSSL
* noppoMan/SlimaneHTTP
* noppoMan/HTTPParser
* Zewo/CURIParser
* Zewo/CHTTPParser
* Zewo/Core

## Package.swift

Here is Package.swift of minimum requirements

```swift
import PackageDescription

#if os(OSX)
    let openSSLRepo = "https://github.com/noppoMan/COpenSSL-OSX.git"
#else
    let openSSLRepo = "https://github.com/noppoMan/COpenSSL.git"
#endif

let package = Package(
    name: "SlimaneExample",
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
```


## Install Guide

### Linux

#### Install build tools for native libraries

#### apt-get
```sh
# Install build tools and libssl-dev
apt-get install build-essential libtool libssl-dev
```

#### yum
```sh
yum groupinstall "Development Tools"
yum install kernel-devel kernel-headers libtool-ltdl* openssl-devel
```

#### Build and Install native libraries

```sh
# build and install libuv
git clone https://github.com/libuv/libuv.git cd libuv
sh autogen.sh
./configure
make
make install

# Install uri-parser
git clone https://github.com/Zewo/uri_parser.git && cd uri_parser
make
make install

# Install http-parser
git clone https://github.com/Zewo/http_parser.git && cd http_parser
make
make install
```


### Mac OS X

#### brew

```sh
brew tap zewo/tap
brew install http_parser uri_parser
brew install libuv openssl
brew link libuv --force
brew link openssl --force
```

## Build
```sh
swift build
```

### LD_LIBRARY_PATH
If You got `error while loading shared libraries: libuv.so.1: cannot open shared object file: No such file or directory`,
Add /usr/local/lib into LD_LIBRARY_PATH

```sh
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
```
