#!/bin/sh

ENV ?= dev

DOCKER := docker
DOCKER_COMPOSE := docker-compose

.PHONY: docker-help
docker-help:
	@echo ""
	@echo "Docker options:"
	@echo "  docker-build                       Build images"
	@echo "      arguments:"
	@echo "          ENV: Target environment; default: 'dev'"
	@echo "  docker-build-up                    Build images, start all and clean"
	@echo "      arguments:"
	@echo "          ENV: Target environment; default: 'dev'"
	@echo "          FORCE_RECREATE: Recreate containers when 'y' or 'yes'; default: 'n'"
	@echo "  docker-clean                       Remove all unused container"
	@echo "  docker-clean-all                   Remove all unused data"
	@echo "  docker-container-id                Get the container id from a service id"
	@echo "      arguments:"
	@echo "          SERVICE: Name of the docker compose service; Required"
	@echo "  docker-down                        Stop and remove services"
	@echo "      arguments:"
	@echo "          SERVICE: Name of the docker compose service"
	@echo "  docker-help                        Print list of commands"
	@echo "  docker-images                      Show a list of images"
	@echo "  docker-logs                        Show logs of services and follow from the last 20 lines"
	@echo "      arguments:"
	@echo "          SERVICE: Name of the docker compose service"
	@echo "  docker-restart                     Restart services"
	@echo "      arguments:"
	@echo "          SERVICE: Name of the docker compose service"
	@echo "  docker-start                       Start services"
	@echo "      arguments:"
	@echo "          SERVICE: Name of the docker compose service"
	@echo "  docker-stop                        Stop services"
	@echo "      arguments:"
	@echo "          SERVICE: Name of the docker compose service"
	@echo "  docker-prune-volumes               Clean unused volumes"
	@echo "  docker-ps                          Show status of services"
	@echo "      arguments:"
	@echo "          SERVICE: Name of the docker compose service"
	@echo "  docker-pull                        Pull images"
	@echo "      arguments:"
	@echo "          ENV: Target environment; default: 'dev'"
	@echo "  docker-rm-container-with-volumes   Remove all containers with volumes"
	@echo "      arguments:"
	@echo "          NAME: Name of the container; Required"
	@echo "  docker-rm-stopped-containers       Remove all non running containers, else show errors"
	@echo "  docker-rm-dangling-images          Delete all untagged/dangling (<none>) images, else show errors"
	@echo "  docker-rm-dangling-volumes         Delete all untagged/dangling (<none>) volumes, else show errors"
	@echo "      arguments:"
	@echo "          NAME: Name of the container; Required"
	@echo "  docker-up                          Start services"
	@echo "      arguments:"
	@echo "          ENV: Target environment; default: 'dev'"
	@echo "          FORCE_RECREATE: Recreate containers when 'y' or 'yes'; default: 'n'"
	@echo ""

# Build images, start all and clean
# Input:	ENV -> string							Target environment; default: 'dev'
# 				FORCE_RECREATE -> string	Recreate containers when 'y' or 'yes'
# 																	default: 'n'
.PHONY: docker-build-up
docker-build-up: docker-pull docker-build docker-up docker-clean-all

# Pull images
# Input:	ENV -> string	Target environment; default: 'dev'
.PHONY: docker-pull
docker-pull:
	@$(DOCKER_COMPOSE) \
	--file docker-compose.yml \
	--file docker-compose.$(ENV).yml \
	pull --include-deps

# Build images
# Input:	ENV -> string	Target environment; default: 'dev'
.PHONY: docker-build
docker-build:
	@$(DOCKER_COMPOSE) \
	--file docker-compose.yml \
	--file docker-compose.$(ENV).yml \
	build --parallel --compress --force-rm

# Start all containers
# Input:	ENV -> string							Target environment; default: 'dev'
# 				FORCE_RECREATE -> string	Recreate containers when 'y' or 'Y'
# 																	default: 'n'
.PHONY: docker-up
docker-up:
	@force_recreate_flag=; \
	\
	if [ "$(FORCE_RECREATE)" != "$${FORCE_RECREATE#[yY]}" ]; then \
		force_recreate_flag="--force-recreate"; \
	fi; \
	\
	$(DOCKER_COMPOSE) \
	--file docker-compose.yml \
	--file docker-compose.$(ENV).yml \
	up --detach --remove-orphans $${force_recreate_flag}

# Start services
# Input:	SERVICE -> string	Name of the docker compose service
.PHONY: docker-start
docker-start:
	@$(DOCKER_COMPOSE) start $(SERVICE)

# Stop services
# Input:	SERVICE -> string	Name of the docker compose service
.PHONY: docker-stop
docker-stop:
	@$(DOCKER_COMPOSE) stop $(SERVICE)

# Stop and remove services
# Input:	SERVICE -> string	Name of the docker compose service
.PHONY: docker-down
docker-down:
	@$(DOCKER_COMPOSE) down $(SERVICE)

# Restart services
# Input:	SERVICE -> string	Name of the docker compose service
.PHONY: docker-restart
docker-restart:
	@$(DOCKER_COMPOSE) restart $(SERVICE)

# Clean unused volumes
.PHONY: docker-prune-volumes
docker-prune-volumes:
	@$(DOCKER) system prune --volumes --force

# Remove all docker unused container
.PHONY: docker-clean
docker-clean:
	@$(DOCKER) system prune --force

# Remove all unused container
.PHONY: docker-clean-all
docker-clean-all: docker-clean docker-prune-volumes

# Remove all non running containers, else show errors
.PHONY: docker-rm-stopped-containers
docker-rm-stopped-containers:
	@echo "- Remove all non running containers"
	-$(DOCKER) rm `$(DOCKER) ps --quiet --filter status=exited`

# Remove all containers with volumes, else show errors
# Input:	NAME -> string	Name of the container
.PHONY: docker-rm-container-with-volumes
docker-rm-container-with-volumes:
	@echo "- Remove $(NAME) container"
	-$(DOCKER) rm --volumes `$(DOCKER) ps --quiet --all --filter name=$(NAME)`

# Delete all untagged/dangling (<none>) images, else show errors
.PHONY: docker-rm-dangling-images
docker-rm-dangling-images:
	@echo "- Delete all untagged/dangling (<none>) images"
	-$(DOCKER) rmi `$(DOCKER) images --quiet --filter dangling=true`

# Delete all untagged/dangling (<none>) volumes, else show errors
.PHONY: docker-rm-dangling-volumes
docker-rm-dangling-volumes:
	@echo "- Delete all untagged/dangling (<none>) volumes"
	-$(DOCKER) rmi `$(DOCKER) volumes --quiet --filter dangling=true`

# Get the container id from a service id
# Input:	SERVICE -> string	Name of the docker compose service
.PHONY: docker-container-id
docker-container-id:
	@$(DOCKER_COMPOSE) ps -q $(SERVICE)

# Show status of services
# Input:	SERVICE -> string	Name of the docker compose service
.PHONY: docker-ps
docker-ps:
	@$(DOCKER_COMPOSE) ps $(SERVICE)

# Show a list of images
.PHONY: docker-images
docker-images:
	@$(DOCKER_COMPOSE) images

# Show logs of services and follow from the last 20 lines
# Input:	SERVICE -> string	Name of the docker compose service
.PHONY: logs
docker-logs:
	@$(DOCKER_COMPOSE) logs --follow --timestamp --tail=20 $(SERVICE)
