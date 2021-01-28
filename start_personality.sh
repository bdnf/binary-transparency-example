#!/bin/bash

echo "Waiting for services to initialize ..."
sleep 30
docker-compose logs --tail=20
sleep 30

docker-compose -f docker-compose.override.yml up
