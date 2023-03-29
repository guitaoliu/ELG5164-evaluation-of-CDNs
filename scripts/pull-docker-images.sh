#!/usr/bin/env bash

# This script pulls some popular docker images from docker hub, then saves them to a tar file.
# Path to save the tar file: statics/docker-images/<image_name>-<image_tag>.tar

# The images to pull
IMAGES=(
    "busybox:latest"
    "alpine:latest"
    "ubuntu:latest"
    "centos:latest"
    "debian:latest"
    "fedora:latest"
    "opensuse/leap:latest"
    "opensuse/tumbleweed:latest"
    "archlinux:latest"
    "golang:latest"
    "python:latest"
    "node:latest"
    "ruby:latest"
    "php:latest"
    "mysql:latest"
    "postgres:latest"
    "mongo:latest"
    "redis:latest"
    "nginx:latest"
    "httpd:latest"
    "traefik:latest"
    "gtliu99/elg5164-web:latest"
)

# The path to save the tar file
SAVE_PATH="statics/docker-images"

# Pull the images
for image in "${IMAGES[@]}"; do
    docker pull "$image" &
done

# Wait for all the images to be pulled
wait

# Save the images
for image in "${IMAGES[@]}"; do
    image_name=$(echo "$image" | cut -d: -f1 | sed 's/\//-/g')
    image_tag=$(echo "$image" | cut -d: -f2)
    echo "Saving $image_name:$image_tag ..."
    docker save "$image" -o "$SAVE_PATH/$image_name-$image_tag.tar" &
done

# Wait for all the images to be saved
wait
