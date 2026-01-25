#!/bin/bash
set -e

ENV_FILE=".env"
EXAMPLE_FILE="example.env"

if [ -f "$ENV_FILE" ]; then
    echo "Error: .env file already exists. Remove it first or backup it."
    exit 1
fi

if [ ! -f "$EXAMPLE_FILE" ]; then
    echo "Error: $EXAMPLE_FILE not found"
    exit 1
fi

echo "Generating secrets..."

POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
POSTGRES_NON_ROOT_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)
QDRANT_API_KEY=$(openssl rand -base64 48 | tr -d "=+/" | cut -c1-48)
REDIS_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)

cp "$EXAMPLE_FILE" "$ENV_FILE"

sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$POSTGRES_PASSWORD|" "$ENV_FILE"
sed -i "s|^POSTGRES_NON_ROOT_PASSWORD=.*|POSTGRES_NON_ROOT_PASSWORD=$POSTGRES_NON_ROOT_PASSWORD|" "$ENV_FILE"
sed -i "s|^N8N_ENCRYPTION_KEY=.*|N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY|" "$ENV_FILE"
sed -i "s|^QDRANT_API_KEY=.*|QDRANT_API_KEY=$QDRANT_API_KEY|" "$ENV_FILE"
sed -i "s|^REDIS_PASSWORD=.*|REDIS_PASSWORD=$REDIS_PASSWORD|" "$ENV_FILE"

echo "✓ .env file created successfully!"
echo ""
echo "IMPORTANT: Set the following values manually in .env:"
echo "  - PUBLIC_DOMAIN (current: n8n.reagate.com)"
echo "  - CLOUDFLARE_TUNNEL_TOKEN (get from Cloudflare dashboard)"
echo ""
echo "Generated secrets have been set for:"
echo "  - POSTGRES_PASSWORD"
echo "  - POSTGRES_NON_ROOT_PASSWORD"
echo "  - N8N_ENCRYPTION_KEY"
echo "  - QDRANT_API_KEY"
echo "  - REDIS_PASSWORD"
