#!/bin/bash

echo "==========================================
Odoo Community Edition - Restore Script
==========================================
"

# Check if timestamp parameter is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide a backup timestamp"
    echo "Usage: ./scripts/restore.sh TIMESTAMP"
    echo ""
    echo "Available backups:"
    ls -la "$(dirname "$0")/../backups" | grep odoo_ | awk '{print "  " $9}'
    exit 1
fi

TIMESTAMP=$1
BACKUP_DIR="$(dirname "$0")/../backups"
DB_CONTAINER="odoo_postgres"
ODOO_DATA_DIR="$(dirname "$0")/../data/odoo"

# Navigate to project root
cd "$(dirname "$0")/.." || exit

# Check if backup files exist
DB_BACKUP="${BACKUP_DIR}/odoo_db_${TIMESTAMP}.sql.gz"
FILESTORE_BACKUP="${BACKUP_DIR}/odoo_filestore_${TIMESTAMP}.tar.gz"
CONFIG_BACKUP="${BACKUP_DIR}/odoo_config_${TIMESTAMP}.tar.gz"

if [ ! -f "$DB_BACKUP" ] && [ ! -f "$FILESTORE_BACKUP" ] && [ ! -f "$CONFIG_BACKUP" ]; then
    echo "❌ Error: No backup files found for timestamp: $TIMESTAMP"
    echo "Available backups:"
    ls -la "$BACKUP_DIR" | grep odoo_ | awk '{print "  " $9}'
    exit 1
fi

echo "⚠️  WARNING: This will restore data from backup timestamp: $TIMESTAMP"
echo "⚠️  Current data will be OVERWRITTEN!"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Restore cancelled."
    exit 0
fi

# Stop services if running
echo "
🛑 Stopping services..."
docker-compose down

# Restore database
if [ -f "$DB_BACKUP" ]; then
    echo "
1️⃣ Restoring PostgreSQL database..."
    
    # Start only PostgreSQL
    docker-compose up -d db
    echo "⏳ Waiting for PostgreSQL to be ready..."
    sleep 10
    
    # Drop existing databases and restore
    echo "🗑️  Dropping existing databases..."
    docker exec $DB_CONTAINER psql -U odoo -c "DROP DATABASE IF EXISTS postgres;" 2>/dev/null || true
    
    echo "📥 Restoring database from backup..."
    gunzip -c "$DB_BACKUP" | docker exec -i $DB_CONTAINER psql -U odoo
    
    echo "✅ Database restored successfully"
else
    echo "⚠️  No database backup found for this timestamp"
fi

# Restore filestore
if [ -f "$FILESTORE_BACKUP" ]; then
    echo "
2️⃣ Restoring Odoo filestore..."
    
    # Backup current filestore
    if [ -d "$ODOO_DATA_DIR" ] && [ "$(ls -A $ODOO_DATA_DIR)" ]; then
        echo "📦 Backing up current filestore..."
        mv "$ODOO_DATA_DIR" "${ODOO_DATA_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create directory and extract
    mkdir -p "$ODOO_DATA_DIR"
    tar -xzf "$FILESTORE_BACKUP" -C "$ODOO_DATA_DIR"
    echo "✅ Filestore restored successfully"
else
    echo "⚠️  No filestore backup found for this timestamp"
fi

# Restore configuration (optional)
if [ -f "$CONFIG_BACKUP" ]; then
    echo "
3️⃣ Found configuration backup. Do you want to restore it?"
    read -p "This will overwrite current configuration files (yes/no): " restore_config
    
    if [ "$restore_config" == "yes" ]; then
        tar -xzf "$CONFIG_BACKUP" -C .
        echo "✅ Configuration restored successfully"
    else
        echo "⏭️  Skipped configuration restore"
    fi
fi

# Start services
echo "
🚀 Starting services..."
docker-compose up -d

echo "
⏳ Waiting for services to be ready..."
sleep 10

# Check status
docker-compose ps

echo "
==========================================
✅ Restore completed successfully!
==========================================

📅 Restored from: $TIMESTAMP

🔍 Please verify:
   1. Access Odoo at http://localhost:8069
   2. Check that your data is restored
   3. Test critical functionality

⚠️  Note: If you had a different master password,
   update it in config/odoo.conf

==========================================
"