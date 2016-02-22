#!/bin/bash

source ./ENV.sh
source ./IPS.sh
source ../bin/tasks.sh

echo "container: $CONTAINER_NAME"

function build() {
  echo "building: $CONTAINER_NAME"

  docker pull sameersbn/redmine:3.2.0-4

  mkdir -p ./data/plugins

  if [ -d "./data/plugins/redmine_milestones" ]; then
    echo "redmine_milestones already installed"
  else
    #git clone \
      git://github.com/k41n/redmine_milestones.git \
      ./data/plugins/redmine_milestones \
    || echo "milestones plugin already downloaded"
  fi

  echo "build finished"
}

function run() {
  remove

  echo "run $CONTAINER_NAME"

  docker run \
    --detach \
    --hostname $HOSTNAME \
    --publish $HOST_PORT_80:$CONTAINER_PORT_80 \
    --name $CONTAINER_NAME \
    --volume=$PWD/data:/home/redmine/data \
    --volume=$PWD/logs:/home/redmine/redmine/log/ \
    --link $POSTGRES_CONTAINER_NAME:postgres \
    --env="DB_NAME=$REDMINE_DB_NAME" \
    --env="DB_USER=$REDMINE_DB_USER" \
    --env="DB_PASS=$REDMINE_DB_PASS" \
    --env="DB_ADAPTER=postgresql" \
    --env="DB_HOST=$MAGIC_POSTGRES_IP" \
    --env="DB_PORT=$POSTGRES_PORT" \
    --env='REDMINE_SUDO_MODE_ENABLED=true' \
    --env='REDMINE_FETCH_COMMITS=hourly' \
    --env='REDMINE_BACKUP_SCHEDULE=daily' \
    sameersbn/redmine:3.2.0-4

  echo "started docker container"
}

function backup() {
  echo "backup $CONTAINER_NAME"

  remove

  docker run \
    --name $CONTAINER_NAME \
    --interactive \
    --tty \
    --rm \
    --volume=$PWD/data:/home/redmine/data \
    --volume=$PWD/logs:/home/redmine/redmine/log/ \
    --link $POSTGRES_CONTAINER_NAME:postgres \
    --env="DB_NAME=$REDMINE_DB_NAME" \
    --env="DB_USER=$REDMINE_DB_USER" \
    --env="DB_PASS=$REDMINE_DB_PASS" \
    --env="DB_ADAPTER=postgresql" \
    --env="DB_HOST=$MAGIC_POSTGRES_IP" \
    --env="DB_PORT=$POSTGRES_PORT" \
    sameersbn/redmine:3.2.0-4 app:backup:create

  run
}

function help() {
  echo "Container: $CONTAINER_NAME"
  echo ""
  echo "Usage:"
  echo ""
  echo './cli.sh $command'
  echo ""
  echo "commands:"
  echo "build  - build docker container"
  echo "run    - run docker container"
  echo "backup - restart container and backup data"
  echo "remove - remove container"
  echo "logs   - tail the container logs"
  echo "debug  - connect to container debug session"
  echo "stop   - stop container"
  echo "help   - this help text"
}

if [ $1 ]
then
  function=$1
  shift
  $function $@
else
  help $@
fi
