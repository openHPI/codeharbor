#!/bin/bash
USERNAME="codeharbor"
HOST="10.210.0.51"
IMAGE='openhpidev/codeharbor'

scp docker/docker-compose.production.yml $USERNAME@$HOST:/home/codeharbor/docker-compose.yml
scp update.sh $USERNAME@$HOST:/home/codeharbor/update.sh
ssh $USERNAME@$HOST docker-compose -p codeharbor stop
ssh $USERNAME@$HOST export RUN=$(docker-compose -p codeharbor run -d --rm web rake db:create db:migrate)
ssh $USERNAME@$HOST docker-compose -p codeharbor up -d