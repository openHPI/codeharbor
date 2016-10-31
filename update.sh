#!/bin/bash
IMAGE='openhpidev/codeharbor'
C1='web1'
C2='web2'
ADR='192.168.99.100:$CURRENT_PORT'

function check_status(){
  RES=$(curl -Is $ADR | head -1)
  if [ "$RES" == "HTTP/1.1 200 OK" ]
  then
    return 1
  else
    return 0
  fi
}

function start_new_container(){
  # find out which container to create and start
  if [ "$CURRENT_CONTAINER" == "$C1" ]
  then
    NAME=$C2
    PORT=3001
  else
    NAME=$C1
    PORT=3000
  fi
  echo 'migrate database and remove old version of container'
  docker-compose -f docker/docker-compose.production.yml -p codeharbor run -d --rm web rake db:migrate
  docker rm -f $NAME
  echo "starting new container $NAME"
  docker run -d --link=codeharbor_db_1:db -e RAILS_ENV='production' \
          -e RACK_ENV='production' \
          -e DATABASE_URL='postgres://postgres@db:5432/' \
          --name $NAME \
          -p $PORT:3000 \
          --restart=unless-stopped openhpidev/codeharbor \
          bundle exec rails s -b 0.0.0.0
  # Stop old container once the new one is running
  COUNTER=0
  echo "polling new container $NAME"
  while [[ $COUNTER -lt 20 ]]; do
    up=$(check_status)
    if [[ $up -eq 1 ]]
    then
      break
    fi
    let COUNTER=COUNTER+1
    if [[ $COUNTER -eq 20 ]]
    then
      echo 'Container did not start properly. Exiting'
      exit 1
    fi
    sleep 1
  done
  echo "$NAME started successfully. Stopping old container."
  docker stop $CURRENT_CONTAINER
  export CURRENT_CONTAINER=$NAME
  export CURRENT_PORT=$PORT
}
echo 'Check if a new version of the image is available'
echo 'and start a new container with this image.'
echo 'Once the new container is running, stop the old container.'
echo '**************************************************'
echo 'compare SHA of image before and after docker pull'
OLD_SHA=$(docker images |grep $IMAGE | awk 'NR==1{print $3}')
echo "Old SHA: $OLD_SHA"
docker pull $IMAGE
NEW_SHA=$(docker images |grep $IMAGE | awk 'NR==1{print $3}')
echo "New SHA: $NEW_SHA"
if [ "$OLD_SHA" != "$NEW_SHA" ]; then
  echo 'Image was updated, proceeding to start new container.'
  start_new_container
fi
exit 0


