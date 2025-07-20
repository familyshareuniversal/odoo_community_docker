#!/bin/bash

echo "================================================
🚀 Odoo Community Edition - Automated Setup
================================================
This script will automatically:
1. Start Docker containers
2. Create Demo database with demo data
3. Setup admin user (rohitsoni@gmail.com)
4. Install ALL official Odoo modules
5. Verify installation

Total estimated time: 45-50 minutes
================================================
"

# Configuration
DB_NAME="Demo"

# Display database type
if [ "$DB_NAME" = "Demo" ]; then
    echo "📌 Database Type: DEMO (All modules will be installed)"
    echo "================================================"
    echo ""
else
    echo "📌 Database Type: PRODUCTION (Selective modules)"
    echo "================================================"
    echo ""
fi
ADMIN_EMAIL="rohitsoni@gmail.com"
ADMIN_PASSWORD="Rohit819"
MASTER_PASSWORD="Rohit819"
SCRIPT_DIR="$(dirname "$0")"
LOG_FILE="$SCRIPT_DIR/../logs/auto_setup_$(date +%Y%m%d_%H%M%S).log"

# Create logs directory if it doesn't exist
mkdir -p "$SCRIPT_DIR/../logs"

# Function to log messages
log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        log_message "✅ $1"
    else
        log_message "❌ $1 failed!"
        log_message "Check log file: $LOG_FILE"
        exit 1
    fi
}

# Start logging
log_message "Starting automated setup at $(date)"
log_message "Log file: $LOG_FILE"

# Step 1: Start Docker containers
log_message ""
log_message "Step 1: Starting Docker containers..."
cd "$SCRIPT_DIR/.." || exit
./scripts/start.sh >> "$LOG_FILE" 2>&1
check_success "Docker containers started"

# Wait for Odoo web interface to be fully ready (just like manual check)
log_message ""
log_message "Waiting for Odoo web interface to be fully ready..."
log_message "Checking http://localhost:8069 (just like you would in browser)..."

MAX_ATTEMPTS=120  # 10 minutes max
ATTEMPT=0
ODOO_READY=false

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    # Check if we can access Odoo's web interface (checking for redirect or Odoo)
    if curl -s http://localhost:8069 2>/dev/null | grep -q -E "(Redirecting|Odoo)"; then
        # Also check if database manager is accessible
        if curl -s http://localhost:8069/web/database/manager 2>/dev/null | grep -q "Create Database"; then
            ODOO_READY=true
            break
        fi
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
    if [ $((ATTEMPT % 12)) -eq 0 ]; then
        log_message "Still waiting for Odoo to start... ($((ATTEMPT * 5)) seconds elapsed)"
    fi
    sleep 5
done

if [ "$ODOO_READY" = true ]; then
    log_message "✅ Odoo web interface is ready! (took $((ATTEMPT * 5)) seconds)"
    log_message "✅ Can access http://localhost:8069 - just like manual setup"
else
    log_message "❌ Timeout: Odoo did not become ready within 10 minutes"
    log_message "Please check Docker logs: docker-compose logs odoo"
    exit 1
fi

# Extra safety - give Odoo a moment to stabilize after becoming accessible
log_message "Giving Odoo 10 more seconds to fully stabilize..."
sleep 10

# Step 2: Create Demo database
log_message ""
log_message "Step 2: Creating Demo database with demo data..."
"$SCRIPT_DIR/2_create_demo_db.sh" >> "$LOG_FILE" 2>&1
check_success "Demo database created"

# Step 3: Setup admin user
log_message ""
log_message "Step 3: Setting up admin user (rohitsoni@gmail.com)..."
"$SCRIPT_DIR/3_setup_admin_user.py" >> "$LOG_FILE" 2>&1
check_success "Admin user configured"

# Step 4: Install all modules
log_message ""
log_message "Step 4: Installing all official Odoo modules..."
log_message "This will take approximately 30-45 minutes..."
"$SCRIPT_DIR/4_install_all_modules.sh" >> "$LOG_FILE" 2>&1
check_success "All modules installed"

# Step 5: Final verification
log_message ""
log_message "Step 5: Running final verification..."
docker exec odoo_app odoo -c /etc/odoo/auto_odoo.conf -d Demo --no-http --list-modules >> "$LOG_FILE" 2>&1
check_success "Module verification completed"

# Summary
log_message ""
log_message "================================================"
log_message "✅ AUTOMATED SETUP COMPLETED SUCCESSFULLY!"
log_message "================================================"
log_message ""
log_message "📊 Setup Summary:"
log_message "  - Database: Demo"
log_message "  - Admin Email: rohitsoni@gmail.com"
log_message "  - Admin Password: Rohit819"
log_message "  - Demo Data: Included"
log_message "  - All Modules: Installed"
log_message ""
log_message "🌐 Access Odoo at: http://localhost:8069"
log_message ""
log_message "📝 Login Credentials:"
log_message "  - Email: rohitsoni@gmail.com"
log_message "  - Password: Rohit819"
log_message "  - Database: Demo"
log_message ""
log_message "📁 Full log available at: $LOG_FILE"
log_message ""
log_message "🎉 Happy Odoo-ing!"
log_message "================================================"
log_message "Completed at $(date)"