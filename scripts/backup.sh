#!/bin/bash

echo "==========================================
Odoo Community Edition - Backup Script
==========================================
"

# Configuration
BACKUP_DIR="$(dirname "$0")/../backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_CONTAINER="odoo_postgres"
ODOO_DATA_DIR="$(dirname "$0")/../data/odoo"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Navigate to project root
cd "$(dirname "$0")/.." || exit

# Check if containers are running
if ! docker-compose ps | grep -q "Up"; then
    echo "⚠️  Warning: Containers are not running. Backing up existing data..."
fi

echo "🔍 Available databases:"
docker exec $DB_CONTAINER psql -U odoo -c "\l" 2>/dev/null || echo "Could not list databases (container may be stopped)"

echo "
📦 Starting backup process..."

# Backup all PostgreSQL databases
echo "1️⃣ Backing up PostgreSQL databases..."
DB_BACKUP_FILE="$BACKUP_DIR/odoo_db_${TIMESTAMP}.sql"

if docker exec $DB_CONTAINER pg_dumpall -U odoo > "$DB_BACKUP_FILE" 2>/dev/null; then
    echo "✅ Database backup completed: $DB_BACKUP_FILE"
    
    # Compress the backup
    gzip "$DB_BACKUP_FILE"
    echo "✅ Compressed to: ${DB_BACKUP_FILE}.gz"
else
    echo "⚠️  Database backup skipped (container not running or no databases)"
fi

# Backup Odoo filestore
echo "
2️⃣ Backing up Odoo filestore..."
FILESTORE_BACKUP="$BACKUP_DIR/odoo_filestore_${TIMESTAMP}.tar.gz"

if [ -d "$ODOO_DATA_DIR" ] && [ "$(ls -A $ODOO_DATA_DIR 2>/dev/null)" ]; then
    tar -czf "$FILESTORE_BACKUP" -C "$ODOO_DATA_DIR" .
    echo "✅ Filestore backup completed: $FILESTORE_BACKUP"
else
    echo "⚠️  No filestore data to backup"
fi

# Backup configuration
echo "
3️⃣ Backing up configuration files..."
CONFIG_BACKUP="$BACKUP_DIR/odoo_config_${TIMESTAMP}.tar.gz"
tar -czf "$CONFIG_BACKUP" config/ docker-compose.yml .env 2>/dev/null || \
tar -czf "$CONFIG_BACKUP" config/ docker-compose.yml 2>/dev/null
echo "✅ Configuration backup completed: $CONFIG_BACKUP"

# Clean old backups (keep last 7 days by default)
echo "
🧹 Cleaning old backups..."
find "$BACKUP_DIR" -name "odoo_*.gz" -mtime +7 -delete
echo "✅ Old backups cleaned (kept last 7 days)"

# Summary
echo "
==========================================
✅ Backup completed successfully!
==========================================

📁 Backup location: $BACKUP_DIR
📅 Timestamp: $TIMESTAMP

📦 Created files:
$(ls -lh "$BACKUP_DIR"/*${TIMESTAMP}* 2>/dev/null | awk '{print "   - " $9 " (" $5 ")"}')

💡 To restore from this backup, run:
   ./scripts/restore.sh $TIMESTAMP

==========================================
"