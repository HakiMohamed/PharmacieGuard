#!/bin/bash

# Pull the latest image
docker pull $DOCKER_IMAGE:latest

# Stop and remove the existing container
docker stop guardmed || true
docker rm guardmed || true

# Run the new container
docker run -d \
  --name guardmed \
  -p 3000:3000 \
  --env-file .env \
  $DOCKER_IMAGE:latest 