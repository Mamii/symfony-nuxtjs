include .env

.PHONY: up down webapp api consume

.env: ## Setup .env from dist
	cp .env.dist .env

up: .env ## Start the Docker Compose stack.
	docker-compose up -d

down: ## Stop the Docker Compose stack.
	docker-compose down

webapp: ## Run bash in the webapp service.
	docker-compose exec webapp bash

api: ## Run bash in the api service.
	docker-compose exec api bash

consume: ## Consume messages from the queue.
	docker-compose exec api php bin/console messenger:consume async -vv

.PHONY: create-migrate
create-migrate: ## Create a new migration file
	docker-compose exec api bin/console doctrine:database:drop --force
	docker-compose exec api bin/console doctrine:database:create -n
	docker-compose exec api bin/console doctrine:migrations:migrate -n
	docker-compose exec api bin/console make:migration
	docker-compose exec api bin/console doctrine:migrations:migrate -n

.PHONY: test-% lint-%
test-api: ## Launch test in api
	docker-compose exec api composer yaml-lint
	docker-compose exec api composer cscheck
	docker-compose exec api composer phpstan
	docker-compose exec api composer pest
	docker-compose exec api composer deptrac

test-webapp: ## Launch test in webapp
	docker-compose exec webapp yarn lint

lint-api: ## Launch linter in api
	docker-compose exec api composer yaml-lint
	docker-compose exec api composer csfix
	docker-compose exec api composer cscheck

lint-webapp: ## Launch linter in webapp
	docker-compose exec webapp yarn lint:fix
	docker-compose exec webapp yarn lint

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)