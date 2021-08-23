FROM golang:1.16 AS builder

RUN mkdir /app
WORKDIR /app

#ADD . /app
COPY . .

ARG CGO_ENABLED=0
ARG GOOS=linux
ARG APP=registerd

RUN go build -a -o registerd ./cmd/registerd


FROM scratch

COPY --from=builder /app .

ENTRYPOINT ["./registerd"]