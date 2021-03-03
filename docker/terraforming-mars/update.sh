#!/bin/bash

docker-compose down
cd terraforming-mars

git pull origin main
# cp ../Dockerfile.bak ./Dockerfile

cd .. 
docker-compose up -d --build
