# n8n Stack with Ollama

Production-ready n8n deployment with PostgreSQL, Redis, Qdrant vector database, and Ollama for local LLM inference.

## Features

- **n8n**: Workflow automation with queue mode + 3 workers
- **PostgreSQL 17**: Optimized database with tuned parameters
- **Redis**: Queue management with AOF persistence
- **Qdrant**: Vector database for embeddings
- **SearXNG**: Privacy-respecting metasearch engine
- **Cloudflare Tunnel**: Secure public access
- **Production-ready**: Resource limits, logging, healthchecks

## Quick Start

### 1. Generate Configuration

```bash
chmod +x scripts/generate-secrets.sh
./scripts/generate-secrets.sh
```

### 2. Configure Environment

Edit `.env` file:
- Set `PUBLIC_DOMAIN` to your domain
- Set `CLOUDFLARE_TUNNEL_TOKEN` from Cloudflare dashboard
- Review `GENERIC_TIMEZONE` if needed

### 3. Launch Services

Using Makefile:
```bash
make up
```

Or directly:
```bash
docker compose up -d
```

## Service Access

- **n8n**: https://YOUR_DOMAIN (via Cloudflare Tunnel)
- **SearXNG**: http://searxng:8080/search?q=QUERY&format=json (internal)

All services are internal-only (no external ports exposed).
Access to internal services only via Docker network.

## n8n Workers

По умолчанию запускается 3 воркера:
- Автоматический load balancing через Redis
- Каждый воркер: 1GB memory limit

**Изменить количество:**
```bash
# Через Makefile
make scale WORKERS=5

# Или напрямую
docker compose up -d --scale n8n-worker=5
```

## SearXNG Usage

Use from n8n HTTP Request node:
```
URL: http://searxng:8080/search
Method: GET
Query Parameters:
  - q: your search query
  - format: json
  - categories: general (optional)
```

## Management

**Stop services:**
```bash
make down
```

**View logs:**
```bash
make logs
```

**Check health:**
```bash
make health
```

**Backup database:**
```bash
make backup
```

**Restore database:**
```bash
make restore
```

**Clean all data (destructive):**
```bash
make clean
```

## Optimizations

### Resource Limits
- **PostgreSQL**: 1GB limit, 512MB reserved
- **n8n**: 2GB limit, 512MB reserved
- **n8n Workers**: 1GB each (x3)
- **Redis**: 512MB limit, 256MB reserved (256MB maxmemory)
- **Qdrant**: 1GB limit, 512MB reserved
- **SearXNG**: 512MB limit, 256MB reserved
- **Cloudflared**: 256MB limit, 64MB reserved

### PostgreSQL Tuning
- `shared_buffers=256MB`
- `max_connections=200`
- `effective_cache_size=1GB`
- `checkpoint_completion_target=0.9`
- Optimized for SSD storage

### n8n Queue Mode
- Redis-backed queue with 3 workers
- Parallel execution across workers
- Automatic pruning (7 days retention)
- 16MB max payload size
- Horizontal scaling ready

### Logging
- JSON log driver with rotation
- 10MB max size, 3 files retained
- Prevents disk space issues

### Security
- All secrets auto-generated
- SCRAM-SHA-256 authentication
- Secure cookies enabled
- API key protection
- Password-protected services

## File Structure

```
├── docker-compose.yml       # Main orchestration file
├── Makefile                # Management commands
├── example.env             # Environment template
├── .env                    # Your configuration (generated)
├── scripts/
│   ├── generate-secrets.sh # Secret generation utility
│   └── health-check.sh     # Health monitoring script
├── searxng/
│   └── settings-base.yml   # SearXNG configuration
└── local-files/            # Shared files volume
    └── .gitkeep
```

## Troubleshooting

**Check service health:**
```bash
docker compose ps
```

**Reset everything:**
```bash
docker compose down -v
rm .env
./scripts/generate-secrets.sh
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PUBLIC_DOMAIN` | Your public domain | n8n.example.com |
| `POSTGRES_USER` | Database user | root |
| `POSTGRES_DB` | Database name | n8n |
| `GENERIC_TIMEZONE` | System timezone | Europe/Minsk |
| `CLOUDFLARE_TUNNEL_TOKEN` | CF tunnel token | - |
| `N8N_ENCRYPTION_KEY` | n8n encryption key | auto-generated |
| `N8N_LOG_LEVEL` | Log level | info |
| `N8N_PAYLOAD_SIZE_MAX` | Max payload (MB) | 16 |
| `QDRANT_API_KEY` | Qdrant API key | auto-generated |
| `QDRANT_LOG_LEVEL` | Qdrant log level | INFO |
| `REDIS_PASSWORD` | Redis password | auto-generated |
| `SEARXNG_BASE_URL` | SearXNG base URL | http://searxng:8080/ |
| `SEARXNG_UWSGI_WORKERS` | SearXNG workers | 4 |
| `SEARXNG_UWSGI_THREADS` | SearXNG threads | 4 |

## License

MIT

