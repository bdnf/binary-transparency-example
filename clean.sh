#!/bin/bash

docker-compose down --remove-orphans

docker delete network trillian-net
