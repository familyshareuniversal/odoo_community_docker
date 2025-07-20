#!/bin/bash

echo "==========================================
Odoo Community Edition - Start Script
==========================================
"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

echo "✅ Docker is running"

# Check if .env file exists
if [ ! -f ../.env ]; then
    echo "⚠️  .env file not found. Creating from .env.example..."
    cp ../.env.example ../.env
    echo "✅ Created .env file. Please edit it with your settings."
fi

# Navigate to project root
cd "$(dirname "$0")/.." || exit

# Check if containers are already running
if docker-compose ps | grep -q "Up"; then
    echo "⚠️  Containers are already running."
    echo "Use ./scripts/stop.sh to stop them first."
    exit 1
fi

echo "🚀 Starting Odoo services..."
docker-compose up -d

echo "
⏳ Waiting for services to be ready..."
sleep 5

# Check health status
echo "
📊 Checking service status..."
docker-compose ps

# Wait for Odoo to be fully ready
echo "
⏳ Waiting for Odoo to be fully ready (this may take up to 30 seconds)..."
attempts=0
max_attempts=30

while [ $attempts -lt $max_attempts ]; do
    if curl -s http://localhost:8069/web/health > /dev/null; then
        echo "
✅ Odoo is ready!"
        break
    fi
    attempts=$((attempts + 1))
    sleep 1
done

if [ $attempts -eq $max_attempts ]; then
    echo "
⚠️  Odoo is taking longer than expected to start. Check logs with:
   docker-compose logs odoo"
fi

echo "
==========================================
🎉 Odoo Community Edition is running!
==========================================

📌 Access Odoo at: http://localhost:8069
📌 Database: PostgreSQL on port 5432

📝 First time setup:
   1. Open http://localhost:8069 in your browser
   2. Create a new database
   3. Set master password (from config/odoo.conf)
   4. Install desired modules

🛠  Useful commands:
   - View logs: docker-compose logs -f
   - Stop services: ./scripts/stop.sh
   - Backup data: ./scripts/backup.sh
   - Restore data: ./scripts/restore.sh

==========================================
"