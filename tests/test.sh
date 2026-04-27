#!/bin/bash

curl -f http://localhost:8081 || exit 1
echo "Container is reachable"

