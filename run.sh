#!/bin/sh

docker run --rm -it -p 3307:3307/tcp \
-e MONGO_URI=host.docker.internal \
-e MONGO_PORT=27017 \
-e MONGO_USERNAME=your-username \
-e MONGO_PASSWORD=your-password \
-e MONGO_DB=your-db \
dodyagung/docker-mongo-bi-connector:latest