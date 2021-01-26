#!/bin/bash

git clone https://github.com/google/trillian ./trillian || true
git clone https://github.com/google/trillian-examples ./trillian-examples || true

docker network create  trillian-net

docker-compose -f docker-compose.yml up -d
