#!/bin/bash

VERSION=3.2.1-2

source ./ENV.sh
source ../../bin/tasks.sh

echo "container: $CONTAINER_NAME"

function install-plugin() {
  plugin_dir=$DATA_DIR/redmine/data/plugins/$1
  plugin_url=https://github.com/$2

  if [ -d $plugin_dir ]; then
    echo "$plugin_dir already installed"
  else
    git clone \
     $plugin_url  \
     $plugin_dir
  fi
}

function build() {
  echo-start "build"

  docker pull sameersbn/redmine:$VERSION

  mkdir -p $DATA_DIR/plugins

  install-plugin "redmine_multi_calendar" "ksfltd/redmine_multi_calendar.git"

  install-plugin "redmine_kanban" "edavis10/redmine_kanban.git"

  install-plugin "redmine_tags" "ixti/redmine_tags.git"

  install-plugin "redmine-budget-plugin" "edavis10/redmine-budget-plugin.git"

  install-plugin "redmine_rage" "edavis10/redmine_rate.git"

  install-plugin "redmine_milestones" "k41n/redmine_milestones.git"

  echo-finished "build"
}

function run() {
  remove

  echo-start "run"

  docker run \
    --detach \
    --hostname $HOSTNAME \
    --publish $HOST_PORT_80:$CONTAINER_PORT_80 \
    --name $CONTAINER_NAME \
    --volume=$DATA_DIR/redmine/data:/home/redmine/data \
    --volume=$DATA_DIR/redmine/logs:/home/redmine/redmine/log/ \
    --link $POSTGRES_CONTAINER_NAME:postgres \
    --env="DB_NAME=$REDMINE_DB_NAME" \
    --env="DB_USER=$REDMINE_DB_USER" \
    --env="DB_PASS=$REDMINE_DB_PASS" \
    --env="DB_ADAPTER=postgresql" \
    --env="DB_HOST=$(cat ../postgres/SERVER_IP)" \
    --env="DB_PORT=$POSTGRES_PORT" \
    --env='REDMINE_SUDO_MODE_ENABLED=true' \
    --env='REDMINE_FETCH_COMMITS=hourly' \
    --env='REDMINE_BACKUP_SCHEDULE=daily' \
    sameersbn/redmine:$VERSION

  ip

  echo-finished "run"
}

function backup() {
  echo-start "backup"

  remove

  docker run \
    --name $CONTAINER_NAME \
    --interactive \
    --tty \
    --rm \
    --volume=$DATA_DIR/redmine/data:/home/redmine/data \
    --volume=$DATA_DIR/redmine/logs:/home/redmine/redmine/log/ \
    --link $POSTGRES_CONTAINER_NAME:postgres \
    --env="DB_NAME=$REDMINE_DB_NAME" \
    --env="DB_USER=$REDMINE_DB_USER" \
    --env="DB_PASS=$REDMINE_DB_PASS" \
    --env="DB_ADAPTER=postgresql" \
    --env="DB_HOST=$(cat ../postgres/SERVER_IP)" \
    --env="DB_PORT=$POSTGRES_PORT" \
    sameersbn/redmine:$VERSION app:backup:create

  build
  run

  echo-finished "backup"
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
