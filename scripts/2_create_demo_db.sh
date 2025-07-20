#!/bin/bash

echo "Creating Demo database with demo data..."

# Configuration
DB_NAME="Demo"
MASTER_PASSWORD="Rohit819"
ADMIN_PASSWORD="Rohit819"
CONFIG_FILE="/etc/odoo/auto_odoo.conf"
SCRIPT_DIR="$(dirname "$0")"

# Check if database already exists
echo "Checking if database already exists..."
if docker exec odoo_postgres psql -U odoo -d postgres -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
    echo "⚠️  Database '$DB_NAME' already exists!"
    read -p "Do you want to drop and recreate it? (yes/no): " confirm
    if [ "$confirm" == "yes" ]; then
        echo "Dropping existing database..."
        # First disconnect all connections
        docker exec odoo_postgres psql -U odoo -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();" >/dev/null 2>&1
        docker exec odoo_postgres dropdb -U odoo "$DB_NAME"
        echo "✅ Existing database dropped"
    else
        echo "Using existing database..."
        exit 0
    fi
fi

# Copy the auto config to container
docker cp config/auto_odoo.conf odoo_app:/etc/odoo/auto_odoo.conf

# Create database using Odoo's database manager API
echo "Creating new database '$DB_NAME' using Odoo API..."

# Use Python to create database via XML-RPC
python3 - <<EOF
import xmlrpc.client
import time

url = "http://localhost:8069"
db_name = "$DB_NAME"
master_pwd = "$MASTER_PASSWORD"
admin_pwd = "$ADMIN_PASSWORD"
lang = "en_US"
demo = True

print("Waiting for Odoo to be ready...")
# Wait for Odoo to be ready
for i in range(30):
    try:
        common = xmlrpc.client.ServerProxy(f'{url}/xmlrpc/2/common')
        version = common.version()
        if version:
            print("✅ Odoo is ready!")
            break
    except:
        time.sleep(2)
else:
    print("❌ Odoo failed to become ready")
    exit(1)

# Create database
print(f"Creating database '{db_name}'...")
try:
    db = xmlrpc.client.ServerProxy(f'{url}/xmlrpc/2/db')
    
    # Check if database exists
    if db_name in db.list():
        print(f"Database {db_name} already exists")
        exit(0)
    
    # Create new database
    db.create_database(master_pwd, db_name, demo, lang, admin_pwd)
    print("✅ Database creation initiated...")
    
    # Wait for database to be created
    print("Waiting for database creation to complete...")
    for i in range(60):
        if db_name in db.list():
            print(f"✅ Database '{db_name}' created successfully!")
            break
        time.sleep(2)
    else:
        print("❌ Database creation timeout")
        exit(1)
        
except Exception as e:
    print(f"❌ Error creating database: {e}")
    exit(1)
EOF

if [ $? -eq 0 ]; then
    echo "✅ Database '$DB_NAME' created successfully with demo data!"
    
    # Wait a bit for database to be fully initialized
    echo "Waiting for database initialization..."
    sleep 10
    
    # Verify database was created
    if docker exec odoo_postgres psql -U odoo -d postgres -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
        echo "✅ Database verified in PostgreSQL"
        
        # Get database size
        DB_SIZE=$(docker exec odoo_postgres psql -U odoo -d postgres -t -c "SELECT pg_size_pretty(pg_database_size('$DB_NAME'));" | xargs)
        echo "📊 Database size: $DB_SIZE"
    else
        echo "❌ Database not found in PostgreSQL!"
        exit 1
    fi
else
    echo "❌ Failed to create database!"
    exit 1
fi

echo "✅ Database creation completed!"

# Check if this is a Demo database
if [ "$DB_NAME" = "Demo" ]; then
    echo ""
    echo "📌 Demo database detected!"
    echo "   This database will have ALL modules installed for demonstration purposes."
    echo "   Perfect for showing clients all Odoo capabilities!"
    
    # Create a flag file
    echo "DEMO_DATABASE=true" > "$SCRIPT_DIR/../config/.demo_flag"
else
    echo ""
    echo "📌 Production database '$DB_NAME' created."
    echo "   Modules will be installed based on business requirements."
    
    # Create a flag file
    echo "DEMO_DATABASE=false" > "$SCRIPT_DIR/../config/.demo_flag"
fi