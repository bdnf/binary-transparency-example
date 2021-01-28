#!/bin/bash

docker-compose down --remove-orphans

docker-compose -f docker-compose-example.yml down

docker network rm trillian-net

echo "Cleaning up artefacts ..."
rm -rf ./test-device

echo "Cleanup finished successfully"
