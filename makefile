CLibUv=CLibUv-*

BUILDOPTS=-Xlinker -L/usr/lib -Xcc -IPackages/$(CLibUv)

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
	$(SWIFT) build $(BUILDOPTS)

release:
	$(SWIFT) build $(BUILDOPTS) --configuration=release

test:
	$(SWIFT) test $(BUILDOPTS)

xcode:
	$(SWIFT) package generate-xcodeproj $(BUILDOPTS)
