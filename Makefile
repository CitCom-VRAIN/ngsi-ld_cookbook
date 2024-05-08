SHELL := /bin/bash

################################################################################
# GLOBALS                                                                      #
################################################################################

GREEN := \e[32m
NC := \e[0m

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROFILE = default
PROJECT_NAME = fiware_examples_upv-valencia
PYTHON_INTERPRETER = python3

ifeq (,$(shell which conda))
HAS_CONDA=False
else
HAS_CONDA=True
endif

################################################################################
# COMMANDS                                                                     #
################################################################################

.PHONY: clean 

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete


.PHONY: get_jupyter_server

## Get the Jupyter server URL
get_jupyter_server:
	@docker logs orionld-jupyter 2>&1 | grep -v '^\[' | grep -E 'http://|/lab\?token'

################################################################################
# PROJECT RULES                                                                #
################################################################################

DOCKER_STATUS_FILE := .docker_status

.PHONY: docker

## Up or Down all available docker-compose in docker folder.
docker:
	@cd docker/containers && \
		if [ ! -f ../$(DOCKER_STATUS_FILE) ]; then \
				touch ../$(DOCKER_STATUS_FILE); \
		fi; \
		echo -e "\e[34mWhich container to deploy?\e[0m" && \
		ls -d */ | grep -v -E '^_' | cat -n | \
		while read -r line; do \
			folder=$$(echo $$line | awk '{print $$2}'); \
			if grep -q -F "$$folder" ../$(DOCKER_STATUS_FILE); then \
				echo -e "$(GREEN)$$line$(NC)"; \
			else \
				echo "$$line"; \
			fi; \
		done; \
		while true; do \
			read -n1 -p ">> Container number: " folder_number && echo -e "" && \
			selected_folder=$$(ls -d */ | grep -v -E '^_' | sed -n $${folder_number}p); \
			if [ -d "$${selected_folder}" ]; then \
				break; \
			else \
				echo -e "\e[31mInvalid container number. Please try again.\e[0m"; \
			fi; \
		done; \
		cd $${selected_folder} && \
		if [ -f pth_envs ]; then \
			env_files=$$(cat pth_envs); \
		else \
			echo -e "\e[31mpth_envs file not found. Aborting.\e[0m"; \
			exit 1; \
		fi; \
		docker_compose_command="docker-compose" && \
		for env_file in $${env_files}; do \
			docker_compose_command="$${docker_compose_command} --env-file $${env_file}"; \
		done; \
		read -n1 -p ">> Up (u) o Down (d) services?: " action && echo -e "" && \
		action_lower=$$(echo $$action | tr '[:upper:]' '[:lower:]') && \
		if [[ $$action_lower == "u" ]]; then \
			$$docker_compose_command up -d; \
			echo -e "[$(GREEN)DONE!$(NC)] Docker $${selected_folder} successfully deployed."; \
			grep -q -F "$${selected_folder}" ../../$(DOCKER_STATUS_FILE) || echo "$${selected_folder}" >> ../../$(DOCKER_STATUS_FILE); \
		elif [[ $$action_lower == "d" ]]; then \
			$$docker_compose_command down; \
			sed -i.bak "\#$${selected_folder}#d" ../../$(DOCKER_STATUS_FILE); \
			rm -f ../../$(DOCKER_STATUS_FILE).bak; \
			echo -e "[$(GREEN)DONE!$(NC)] Docker $${selected_folder} stopped and removed."; \
		else \
			echo -e "\e[31mAction not recognized. Aborting.\e[0m"; \
			exit 1; \
		fi;
################################################################################
# Self Documenting Commands                                                    #
################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
