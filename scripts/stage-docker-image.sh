#!/usr/bin/env bash

docker buildx build --platform linux/amd64,linux/arm64 -t gtliu99/elg5164-web:latest --push .
