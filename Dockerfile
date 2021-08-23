FROM golang:1.16 AS builder

RUN mkdir /app
WORKDIR /app

#ADD . /app
COPY . .

ENV CGO_ENABLED=0

ARG TARGETOS=linux
ARG PROJECT=register
ARG APP=registerd
ARG RELEASE=v0.1.0

ENV API_PORT=8000

#RUN go build -a -o registerd ./cmd/registerd
RUN CGO_ENABLED=0 GOOS=${TARGETOS} go build -a -work \
    		-ldflags "-s -w -X ${PROJECT}/version.Release=${RELEASE}" \
    		-o ${APP}  ./cmd/registerd

FROM scratch

COPY --from=builder /app .

ENTRYPOINT ["./registerd"]

EXPOSE $API_PORT