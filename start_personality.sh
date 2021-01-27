#!/bin/bash

until docker-compose -f docker-compose.override.yml up; do sleep 5; done

