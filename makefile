CLibUv=CLibUv-*
COpenSSL=COpenSSL-*
HTTPParser=HTTPParser-*
CURIParser=CURIParser-*

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
	COpenSSL=COpenSSL-OSX-*
endif

all: release

debug:
	$(SWIFT) build -v $(BUILDOPTS)

release:
	$(SWIFT) build -v $(BUILDOPTS) --configuration=release

test:
	$(SWIFT) test
