#!/bin/bash

echo "==========================================
Odoo Community Edition - Stop Script
==========================================
"

# Navigate to project root
cd "$(dirname "$0")/.." || exit

# Check if containers are running
if ! docker-compose ps | grep -q "Up"; then
    echo "ℹ️  No Odoo containers are currently running."
    exit 0
fi

echo "🛑 Stopping Odoo services..."
docker-compose down

echo "
✅ All services stopped successfully.

📊 Current status:"
docker-compose ps

echo "
==========================================
🏁 Odoo services have been stopped
==========================================

To restart services, run: ./scripts/start.sh
"