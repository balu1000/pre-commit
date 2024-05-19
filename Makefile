APP=${shell basename $(shell git remote get-url origin)}
REGISTRY=balu1000
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
ifeq ($(TARGETOS), windows)
	NAME=kbot.exe
else 
	NAME=kbot
endif
TARGETARCH=amd64

.PHONY: linux linux/arm macos macos/arm windows windows/arm 

format:
	gofmt -s -w ./

vet:
	go vet

test:
	go test -v	
	
get:
	go get

build: format get
		CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o ${NAME} -ldflags "-X="github.com/balu1000/kbot.git/cmd.appVersion=${VERSION}

linux: format get
		GOOS=linux GOARCH=amd64 go build -v -o kbot -ldflags "-X="github.com/balu1000/kbot.git/cmd.appVersion=${VERSION}

linux/arm: format get
		CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -v -o kbot -ldflags "-X="github.com/balu1000/kbot.git/cmd.appVersion=${VERSION}

windows: format get
		CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -v -o kbot.exe -ldflags "-X="github.com/balu1000/kbot.git/cmd.appVersion=${VERSION}

windows/arm: format get
		CGO_ENABLED=0 GOOS=windows GOARCH=arm64 go build -v -o kbot.exe -ldflags "-X="github.com/balu1000/kbot.git/cmd.appVersion=${VERSION}

macos: format get
		CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -v -o kbot -ldflags "-X="github.com/balu1000/kbot.git/cmd.appVersion=${VERSION}

macos/arm: format get
		CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -v -o kbot -ldflags "-X="github.com/balu1000/kbot.git/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean:
	rm -rf kbot
	rm -rf kbot.exe
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}