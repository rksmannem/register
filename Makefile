PROJECT?=github.com/rksmannem/register
APP?=registerd
PORT?=8000

RELEASE?=v0.1.0
COMMIT?=$(shell git rev-parse --short HEAD)
BUILD_TIME?=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
DOCKER_IMAGE_NAME?=docker.io/rksmannem/${APP}

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
	docker run --name ${APP} -p ${PORT}:${PORT} --rm \
		-e "PORT=${PORT}" \
		$(APP):$(RELEASE)

test:
	go test -v -race ./...

push-image: docker-image
	docker push $(DOCKER_IMAGE_NAME):$(RELEASE)

#minikube: push
#	for t in $(shell find ./kubernetes/advent -type f -name "*.yaml"); do \
#        cat $$t | \
#        	gsed -E "s/\{\{(\s*)\.Release(\s*)\}\}/$(RELEASE)/g" | \
#        	gsed -E "s/\{\{(\s*)\.ServiceName(\s*)\}\}/$(APP)/g"; \
#        echo ---; \
#    done > tmp.yaml
#	kubectl apply -f tmp.yaml
