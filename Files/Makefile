# Set variables
PLATFORM ?= linux/amd64
IMAGE_NAME = flink-web-traffic-processing
TARGET_MAX_CHAR_NUM=30

# Colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

## Show help with `make help`
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

.PHONY: build
## Builds the Flink base image with PyFlink and connectors installed
build:
	docker build --platform ${PLATFORM} -t ${IMAGE_NAME} .

.PHONY: up
## Builds the Docker image and starts Flink cluster
up:
	docker-compose -f docker-compose.yml up --build -d

.PHONY: down
## Shuts down the Flink cluster
down:
	docker-compose down --remove-orphans

.PHONY: start
## Starts the Flink job
start:
	docker-compose exec jobmanager flink run -py /opt/flink/web_traffic_pyspark.py

.PHONY: stop
## Stops the Flink job
stop:
	docker-compose exec jobmanager flink cancel

.PHONY: clean
## Clean up containers, images, and volumes
clean:
	docker-compose down --volumes --rmi all
