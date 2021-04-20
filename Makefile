#!/bin/sh

MAKEFILE_UTILS_DIR := ./scripts/makefile/makefile-utils

include $(MAKEFILE_UTILS_DIR)/docker.mk

default: help

.PHONY: help
help: app-help docker-help

.PHONY: app-help
app-help:
	@echo ""
	@echo "My solution to the exercises from 'Elixir in action - Second Edition.'"
	@echo ""
	@echo "App options:"
	@echo "  app-access        Access the app service"
	@echo "      arguments:"
	@echo "          APP_SHELL: Shell to access the container; default: 'zsh'"
	@echo ""

# Access the app service
# Input:	SHELL -> string	Shell to access the container; default: 'zsh'
.PHONY:app-access
app-access:
	@$(DOCKER_COMPOSE) exec app $(or $(APP_SHELL), zsh)
