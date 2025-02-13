FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS build
ARG TARGETOS
ARG TARGETARCH

WORKDIR /go/src/github.com/holoplot/registry-creds

# Only invalidate the download layer if the modules changed
COPY ["go.mod", "go.sum", "./"]
RUN go mod download

COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
  CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build

FROM alpine:3.21

RUN apk add --update ca-certificates && rm -rf /var/cache/apk/*
COPY --from=build /go/src/github.com/holoplot/registry-creds/registry-creds registry-creds

ENTRYPOINT ["/registry-creds"]
