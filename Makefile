.PHONY: help init up down logs backup restore clean health scale

help:
	@echo "Available commands:"
	@echo "  make init         - Generate .env file"
	@echo "  make up           - Start all services (3 workers)"
	@echo "  make scale WORKERS=N - Scale workers to N instances"
	@echo "  make down         - Stop all services"
	@echo "  make logs         - Show logs"
	@echo "  make health       - Check services health"
	@echo "  make backup       - Backup database"
	@echo "  make restore      - Restore database from backup.sql"
	@echo "  make clean        - Remove all data (WARNING: destructive)"

init:
	@./scripts/generate-secrets.sh

up:
	@docker compose up -d --scale n8n-worker=3

scale:
	@echo "Usage: make scale WORKERS=N"
	@test -n "$(WORKERS)" && docker compose up -d --scale n8n-worker=$(WORKERS) || echo "Example: make scale WORKERS=5"

down:
	@docker compose down

logs:
	@docker compose logs -f

health:
	@./scripts/health-check.sh

backup:
	@docker compose exec postgres pg_dump -U $(shell grep POSTGRES_USER .env | cut -d '=' -f2) $(shell grep POSTGRES_DB .env | cut -d '=' -f2) > backup-$(shell date +%Y%m%d-%H%M%S).sql
	@echo "Backup created: backup-$(shell date +%Y%m%d-%H%M%S).sql"

restore:
	@docker compose exec -T postgres psql -U $(shell grep POSTGRES_USER .env | cut -d '=' -f2) $(shell grep POSTGRES_DB .env | cut -d '=' -f2) < backup.sql

clean:
	@echo "WARNING: This will delete all data!"
	@read -p "Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ]
	@docker compose down -v
	@rm -rf local-files/*
	@touch local-files/.gitkeep

