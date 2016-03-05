CLibUv=CLibUv-0.1.0
COpenSSL=COpenSSL-0.1.0
HTTPParser=HTTPParser-0.1.2
CURIParser=CURIParser-0.1.0

BUILDOPTS=-Xlinker -L/usr/lib \
	-Xcc -IPackages/$(CLibUv) \
	-Xcc -IPackages/$(COpenSSL) \
	-Xcc -IPackages/$(HTTPParser) \
	-Xcc -IPackages/$(CURIParser)

SWIFTC=swiftc
SWIFT=swift
ifdef SWIFTPATH
  SWIFTC=$(SWIFTPATH)/bin/swiftc
  SWIFT=$(SWIFTPATH)/bin/swift
endif
OS := $(shell uname)
ifeq ($(OS),Darwin)
  SWIFTC=xcrun -sdk macosx swiftc
	BUILDOPTS=-Xlinker -L/usr/local/lib -Xcc -I/usr/local/include
	COpenSSL=COpenSSL-OSX-0.1.0
endif

all: release

debug:
	$(SWIFT) build -v $(BUILDOPTS)

release:
	$(SWIFT) build -v $(BUILDOPTS) --configuration=release

test:
	$(SWIFT) test
