#!/bin/bash

IMAGE='openhpidev/codeharbor'
C1='web1'
C2='web2'
ADR="127.0.0.1"

function check_status(){
  RES=$(curl -Is $ADR:$CURRENT_PORT | head -1)
  if [ "$RES" == "HTTP/1.1 200 OK" ]
  then
    return 0
  else
    return 1
  fi
}

function start_new_container(){
  # find out which container to create and start
  if [ "$CURRENT_CONTAINER" == "$C1" ]
  then
    NAME=$C2
    PORT=3002
  else
    NAME=$C1
    PORT=3001
  fi
  #echo 'migrate database and remove old version of container'
  run=$(docker-compose -p codeharbor run -d --rm web rake db:migrate)
  docker stop $run
  docker rm $run
  docker rm -f $NAME
  #echo "starting new container $NAME"
  docker run -d --link=codeharbor_db_1:db -e RAILS_ENV='production' \
          -e RACK_ENV='production' \
          -e DATABASE_URL='postgres://postgres@db:5432/' \
          -e RAILS_SERVE_STATIC_FILES='true' \
          --name $NAME \
          -p $PORT:3000 \
          --restart=unless-stopped openhpidev/codeharbor \
          bundle exec rails s
  # Stop old container once the new one is running
  COUNTER=0
  export CURRENT_PORT=$PORT
  echo "polling new container $NAME at $ADR:$CURRENT_PORT"
  while [[ $COUNTER -lt 20 ]]; do
    up="$(check_status)"
    sleep 1
    if [[ $? -eq 0 ]]
    then
      break
    fi
    let COUNTER=COUNTER+1
    if [[ $COUNTER -eq 20 ]]
    then
      echo 'Container did not start properly. Exiting'
      docker stop $NAME
      docker rm -f $NAME 
      exit 1
    fi
  done
  echo "$NAME started successfully. Stopping old container."
  docker stop $CURRENT_CONTAINER
  export CURRENT_CONTAINER=$NAME
}


echo 'Check if a new version of the image is available'
echo 'and start a new container with this image.'
echo 'Once the new container is running, stop the old container.'
echo '**************************************************'

echo 'compare SHA of image before and after docker pull'
export CURRENT_CONTAINER=$(docker ps |grep $IMAGE | awk 'NR==1{print $NF}')
OLD_SHA=$(docker images |grep $IMAGE | awk 'NR==1{print $3}')
#echo "Old SHA: $OLD_SHA"
docker pull $IMAGE
NEW_SHA=$(docker images |grep $IMAGE | awk 'NR==1{print $3}')
#echo "New SHA: $NEW_SHA"
if [ "$OLD_SHA" != "$NEW_SHA" ]; then
  echo 'Image was updated, proceeding to start new container.'
  start_new_container
fi
exit 0


