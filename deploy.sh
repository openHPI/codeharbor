#!/bin/bash
USERNAME="codeharbor"
HOST="10.210.0.51"
C1='web1'
scp docker/docker-compose.production.yml $USERNAME@$HOST:/home/codeharbor/docker-compose.yml
ssh $USERNAME@$HOST docker-compose -f docker/docker-compose.production.yml -p codeharbor up -d
ssh $USERNAME@$HOST export CURRENT_CONTAINER=$C1
ssh $USERNAME@$HOST export CURRENT_PORT=3000