.SILENT:
.PHONY: setup help

## Colors
COLOR_RESET   = \033[0m
COLOR_INFO    = \033[32m
COLOR_COMMENT = \033[33m

## Help
help:
	printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	printf " make [target]\n\n"
	printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	awk '/^[a-zA-Z\-\_0-9\.@]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":") - 1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf " ${COLOR_INFO}%-16s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

###############
# Environment #
###############

traefik:
	docker compose -f docker-compose.yml up -d

## Start dev environment
start: stop traefik

## Stop all running traefik
stop:
	$(eval MY_VAR = $(shell docker ps --all | grep traefik | awk '{print $1}'))
	$(if $(strip $(MY_VAR)),docker ps --filter name=traefik* -aq | xargs docker stop | xargs docker rm,)
