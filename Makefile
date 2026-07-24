# Shortcut biar nggak ngetik -f panjang tiap kali.
# Contoh: `make dev`, `make prod`, `make logs`, `make cli`

COMPOSE_DEV  = docker compose -f docker-compose.yml -f docker-compose.dev.yml
COMPOSE_PROD = docker compose -f docker-compose.yml -f docker-compose.prod.yml

.PHONY: dev prod dev-down prod-down logs ps cli cli-prod restart clean help

## dev: jalankan environment development (+ Redis Commander di :8081)
dev:
	$(COMPOSE_DEV) up -d

## prod: jalankan environment production
prod:
	$(COMPOSE_PROD) up -d

## dev-down: matikan dev
dev-down:
	$(COMPOSE_DEV) down

## prod-down: matikan prod
prod-down:
	$(COMPOSE_PROD) down

## logs: ikuti log redis (dev)
logs:
	$(COMPOSE_DEV) logs -f redis

## ps: status container (dev)
ps:
	$(COMPOSE_DEV) ps

## cli: masuk redis-cli (dev, pakai password dari .env)
cli:
	$(COMPOSE_DEV) exec redis sh -c 'redis-cli -a "$$REDIS_PASSWORD_DEV"'

## cli-prod: masuk redis-cli (prod, pakai password dari .env)
cli-prod:
	$(COMPOSE_PROD) exec redis sh -c 'redis-cli -a "$$REDIS_PASSWORD"'

## restart: restart service redis (dev)
restart:
	$(COMPOSE_DEV) restart redis

## clean: matikan dev + HAPUS volume data (hati-hati!)
clean:
	$(COMPOSE_DEV) down -v

## help: tampilkan daftar command
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## //'