PROJECT?=github.com/rksmannem/register
APP?=registerd
API_PORT?=8000

RELEASE?=v0.1.0
COMMIT?=$(shell git rev-parse --short HEAD)
BUILD_TIME?=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
DOCKER_IMAGE_NAME?=rksmannem/${APP}

GOOS?=linux
GOARCH?=amd64

clean:
	rm -f ${APP}

build: clean
	CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} go build \
		-a \
		-work \
		-ldflags "-s -w -X ${PROJECT}/version.Release=${RELEASE} \
		-X ${PROJECT}/version.Commit=${COMMIT} -X ${PROJECT}/version.BuildTime=${BUILD_TIME}" \
		-o ${APP}  ${PROJECT}/cmd/registerd

docker-image: build
	docker build -t $(DOCKER_IMAGE_NAME):$(RELEASE) .

run-container: docker-image
	docker stop $(APP):$(RELEASE) || true && docker rm $(APP):$(RELEASE) || true
	docker run --name ${APP} -p ${API_PORT}:${API_PORT} --rm \
		-e "API_PORT=${API_PORT}" \
		$(DOCKER_IMAGE_NAME):$(RELEASE)

test:
	go test -v -race ./...

push-image: docker-image
	docker push $(DOCKER_IMAGE_NAME):$(RELEASE)
	#docker push <REGISTRY_HOST>:<REGISTRY_PORT>/<APPNAME>:<APPVERSION>

deploy: push-image
	for t in $(shell find ./k8s -type f -name "*.yaml"); do \
        cat $$t | \
        	sed -E "s/\{\{\.ServiceName\}\}/${APP}/g" | \
        	sed -E "s/\{\{\.Release\}\}/${RELEASE}/g"; \
        echo "\n---"; \
    done > tmp.yaml
	kubectl apply -f tmp.yaml
