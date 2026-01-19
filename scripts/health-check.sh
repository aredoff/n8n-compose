#!/bin/bash
set -e

echo "=== n8n Stack Health Check ==="
echo ""

services=(
    "postgres:PostgreSQL"
    "n8n:n8n"
    "redis:Redis"
    "qdrant:Qdrant"
    "searxng:SearXNG"
)

for service in "${services[@]}"; do
    name="${service%%:*}"
    label="${service##*:}"
    
    if docker compose ps --format json | jq -e ".[] | select(.Service == \"$name\" and .Health == \"healthy\")" > /dev/null 2>&1; then
        echo "✓ $label is healthy"
    elif docker compose ps --format json | jq -e ".[] | select(.Service == \"$name\" and .State == \"running\")" > /dev/null 2>&1; then
        echo "⚠ $label is running (no healthcheck)"
    else
        echo "✗ $label is not running"
    fi
done

echo ""

if docker compose ps --format json | jq -e '.[] | select(.Service == "ollama-cpu" and .State == "running")' > /dev/null 2>&1; then
    echo "✓ Ollama (CPU) is running"
elif docker compose ps --format json | jq -e '.[] | select(.Service == "ollama-gpu" and .State == "running")' > /dev/null 2>&1; then
    echo "✓ Ollama (GPU) is running"
else
    echo "ℹ Ollama is not running (optional)"
fi

if docker compose ps --format json | jq -e '.[] | select(.Service == "cloudflared" and .State == "running")' > /dev/null 2>&1; then
    echo "✓ Cloudflare Tunnel is running"
else
    echo "✗ Cloudflare Tunnel is not running"
fi

echo ""
echo "=== Resource Usage ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" 2>/dev/null | grep -E "n8n|postgres|redis|qdrant|searxng|ollama|cloudflared" || echo "No containers running"

