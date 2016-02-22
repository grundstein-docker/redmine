.PHONY: \
	all \
	dev \
	build \
	run \
	debug \
	logs \
	rm \
	stop \
	backup \
	help


# TASKS

all: help

dev: run logs

build:
	@./cli.sh build

run:
	@./cli.sh run

debug:
	@./cli.sh debug

logs:
	@./cli.sh logs

rm:
	@./cli.sh remove

stop:
	@./cli.sh stop

backup:
	@./cli.sh backup


# help output
help:
	@echo "\
Usage \n\
make TASK\n\

TASKS:
	dev     - build then tail logs
	build   - docker build container
	run     - docker run container
	debug   - connect to docker container
	logs    - tail docker container logs
	rm      - remove docker container
	stop    - stop docker container
	backup  - run gitlab backup task
\n\
	help      - this help text \n\
"
