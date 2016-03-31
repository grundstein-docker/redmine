CLI=./cli.sh

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
	@${CLI} $@

run:
	@${CLI} $@

debug:
	@${CLI} $@

logs:
	@${CLI} $@

rm:
	@${CLI} $@

stop:
	@${CLI} $@

backup:
	@${CLI} $@

ip:
	@${CLI} $@

update:
	@${CLI} $@

status:
	@${CLI} $@

# help output
help:
	@${CLI} $@
