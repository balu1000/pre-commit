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
		CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o ${NAME} -ldflags "-X="github.com/balu1000/actions.git/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}
	docker tag ${REGISTRY}/${APP}:${VERSION} ghcr.io/${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}
	docker push ghcr.io/${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean:
	rm -rf kbot
	rm -rf kbot.exe
	docker rmi ${REGISTRY}/${APP}:${VERSION}