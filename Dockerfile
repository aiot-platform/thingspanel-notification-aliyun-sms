# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM golang:1.23-alpine AS builder
WORKDIR /src
COPY . ./
ARG TARGETOS
ARG TARGETARCH
# 模块不依赖外部库（SDK 为内置快照），因此可完全离线构建。
RUN GOPROXY=off GOSUMDB=off CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -trimpath -o /out/plugin ./cmd/plugin

FROM alpine:latest
RUN apk update && apk add --no-cache tzdata
WORKDIR /app
COPY --from=builder /out/plugin ./plugin
# 插件默认监听 NOTIFICATION_PLUGIN_LISTEN（127.0.0.1:5004）；容器内需设为 0.0.0.0:5004 才可被外部访问。
EXPOSE 5004
ENTRYPOINT ["./plugin"]
