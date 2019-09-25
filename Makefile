.PHONY: all prepare clean

DEB_TARGET_ARCH ?= armel

ifeq ($(DEB_TARGET_ARCH),armel)
GO_ENV := GOARCH=arm GOARM=5 CC_FOR_TARGET=arm-linux-gnueabi-gcc CC=$$CC_FOR_TARGET CGO_ENABLED=1
endif
ifeq ($(DEB_TARGET_ARCH),armhf)
GO_ENV := GOARCH=arm GOARM=6 CC_FOR_TARGET=arm-linux-gnueabihf-gcc CC=$$CC_FOR_TARGET CGO_ENABLED=1
endif
ifeq ($(DEB_TARGET_ARCH),amd64)
GO_ENV := GOARCH=amd64 CC=x86_64-linux-gnu-gcc
endif
ifeq ($(DEB_TARGET_ARCH),i386)
GO_ENV := GOARCH=386 CC=i586-linux-gnu-gcc
endif

all: clean shm2mqtt_

clean:
	rm -rf shm2mqtt

amd64:
	$(MAKE) DEB_TARGET_ARCH=amd64

shm2mqtt: *_.go
	$(GO_ENV) go get github.com/eclipse/paho.mqtt.golang
	$(GO_ENV) go get golang.org/x/sys/unix
	$(GO_ENV) go get golang.org/x/text/encoding/charmap  
	$(GO_ENV) go build

install:
	mkdir -p $(DESTDIR)/usr/bin/ $(DESTDIR)/etc/init.d/
	install -m 0755 shm2mqtt $(DESTDIR)/usr/bin/
	install -m 0755 ping_s1 $(DESTDIR)/usr/bin/
	install -m 0755 initscripts/shm2mqtt $(DESTDIR)/etc/init.d/


deb: prepare
	CC=arm-linux-gnueabi-gcc dpkg-buildpackage -b -aarmel -us -uc
