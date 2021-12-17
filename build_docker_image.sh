#!/bin/bash
# Build base ISLA image from neurodocker image
docker run --rm kaczmarj/neurodocker:0.6.0 generate docker \
    --pkg-manager apt \
    --base debian:buster \
    --run "apt-get update && apt-get install -y multiarch-support" \
    --ants version=2.3.1 \
    --fsl version=6.0.1 \
    | docker build -t neurodocker:isla -

# Build ISLA image from base image and Dockerfile
docker build -t isla:main .