#!/bin/bash

echo "================================================
🧹 Complete Odoo Cleanup Script
================================================
This will remove all data and containers
================================================
"

echo "⚠️  WARNING: This will delete all Odoo data!"
echo -n "Are you sure you want to continue? (yes/no): "
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Cleanup cancelled."
    exit 0
fi

SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR/.." || exit

echo ""
echo "=== Stopping all containers ==="
docker-compose down -v

echo ""
echo "=== Removing data directories ==="
rm -rf data/odoo/*
rm -rf data/postgres/*
echo "✅ Data directories cleaned"

echo ""
echo "=== Removing logs ==="
rm -rf logs/*
echo "✅ Logs cleaned"

echo ""
echo "=== Removing flag files ==="
rm -f config/.demo_flag
echo "✅ Flag files cleaned"

echo ""
echo "=== Complete Docker cleanup ==="
docker system prune -f

echo "✅ Complete cleanup done"
echo ""
echo "You can now run a fresh installation with:"
echo "./scripts/1_auto_setup_complete.sh"