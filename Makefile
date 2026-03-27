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

start:
	docker compose -f docker-compose.yml up -d

## Start dev environment
restart: stop start

## Stop all running traefik
stop:
	docker compose down

###############
# Environment #
###############
generate-cert:
	mkcert -install
	mkcert "127.0.0.1.nip.io" "*.plateforme.127.0.0.1.nip.io" "*.127.0.0.1.nip.io" 127.0.0.1 localhost
	mv 127.0.0.1.nip.io+4.pem ./config/nip/local.pem
	mv 127.0.0.1.nip.io+4-key.pem ./config/nip/local-key.pem

clean-certs:
	rm -f config/ca.* config/nip/server.crt config/nip/server.key config/nip/server.csr

rebuild: clean-certs
	docker compose up --build
