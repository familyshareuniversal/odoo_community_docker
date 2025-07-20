#!/bin/bash

echo "================================================
📦 Installing All Official Odoo Modules
================================================"

# Configuration
DB_NAME="Demo"
CONFIG_FILE="/etc/odoo/auto_odoo.conf"

# Check if this is a Demo database
DEMO_FLAG_FILE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../config/.demo_flag"
IS_DEMO_DB=false

# First check the flag file
if [ -f "$DEMO_FLAG_FILE" ]; then
    source "$DEMO_FLAG_FILE"
    if [ "$DEMO_DATABASE" = "true" ]; then
        IS_DEMO_DB=true
    fi
fi

# Also check the database name directly
if [ "$DB_NAME" = "Demo" ]; then
    IS_DEMO_DB=true
fi

# Set modules file based on database type
if [ "$IS_DEMO_DB" = true ]; then
    MODULES_FILE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../config/modules_list.txt"
    echo "================================================"
    echo "🎯 DEMO DATABASE DETECTED"
    echo "================================================"
    echo "Installing ALL Odoo modules for client demonstrations"
    echo "This will showcase every feature Odoo has to offer!"
    echo "================================================"
else
    # Check if custom modules file exists
    CUSTOM_MODULES_FILE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../config/modules_production.txt"
    if [ -f "$CUSTOM_MODULES_FILE" ]; then
        MODULES_FILE="$CUSTOM_MODULES_FILE"
        echo "================================================"
        echo "📊 PRODUCTION DATABASE: $DB_NAME"
        echo "================================================"
        echo "Installing modules from: modules_production.txt"
        echo "================================================"
    else
        # Default to minimal set
        MODULES_FILE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../config/modules_minimal.txt"
        echo "================================================"
        echo "📊 PRODUCTION DATABASE: $DB_NAME"
        echo "================================================"
        echo "No custom module list found."
        echo "Installing minimal module set from: modules_minimal.txt"
        echo "================================================"
    fi
fi

LOG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../logs"
INSTALL_LOG="$LOG_DIR/module_installation_$(date +%Y%m%d_%H%M%S).log"

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Initialize counters
TOTAL_MODULES=0
INSTALLED_MODULES=0
FAILED_MODULES=0
SKIPPED_MODULES=0

# Arrays to track modules
declare -a FAILED_MODULE_NAMES
declare -a SKIPPED_MODULE_NAMES

# Function to log messages
log_message() {
    echo "$1" | tee -a "$INSTALL_LOG"
}

# Function to install a module
install_module() {
    local module_name="$1"
    local module_num="$2"
    local total_count="$3"
    
    log_message ""
    log_message "[$module_num/$total_count] Installing module: $module_name"
    
    # Check if module is already installed
    if echo "$INSTALLED_MODULES_LIST" | grep -q "^${module_name}$"; then
        log_message "⏭️  Module '$module_name' is already installed, skipping..."
        ((SKIPPED_MODULES++))
        SKIPPED_MODULE_NAMES+=("$module_name")
        return 0
    fi
    
    # Try to install the module
    if docker exec odoo_app odoo -c "$CONFIG_FILE" -d "$DB_NAME" -i "$module_name" --no-http --stop-after-init >> "$INSTALL_LOG" 2>&1; then
        log_message "✅ Successfully installed: $module_name"
        ((INSTALLED_MODULES++))
        return 0
    else
        log_message "❌ Failed to install: $module_name"
        ((FAILED_MODULES++))
        FAILED_MODULE_NAMES+=("$module_name")
        return 1
    fi
}

# Start installation
log_message "Starting module installation at $(date)"
log_message "Database: $DB_NAME"
log_message "Modules list: $MODULES_FILE"
log_message "Log file: $INSTALL_LOG"
log_message ""

# Check if modules file exists
if [ ! -f "$MODULES_FILE" ]; then
    log_message "❌ Modules file not found: $MODULES_FILE"
    exit 1
fi

# Count total modules (excluding comments and empty lines)
TOTAL_MODULES=$(grep -v '^#' "$MODULES_FILE" | grep -v '^$' | wc -l)
log_message "Total modules to process: $TOTAL_MODULES"
log_message "================================================"

# Get list of already installed modules
log_message ""
log_message "Checking for already installed modules..."
INSTALLED_MODULES_LIST=$(docker exec odoo_postgres psql -U odoo -d "$DB_NAME" -t -c "SELECT name FROM ir_module_module WHERE state='installed';" | tr -d ' ')
ALREADY_INSTALLED_COUNT=$(echo "$INSTALLED_MODULES_LIST" | grep -v '^$' | wc -l)
log_message "Found $ALREADY_INSTALLED_COUNT modules already installed"
log_message ""

# Read modules from file and install
MODULE_NUM=0
while IFS= read -r module || [[ -n "$module" ]]; do
    # Skip comments and empty lines
    if [[ "$module" =~ ^#.*$ ]] || [[ -z "$module" ]]; then
        continue
    fi
    
    # Trim whitespace
    module=$(echo "$module" | xargs)
    
    ((MODULE_NUM++))
    
    # Show progress
    PROGRESS=$((MODULE_NUM * 100 / TOTAL_MODULES))
    log_message ""
    log_message "📊 Progress: $PROGRESS% ($MODULE_NUM/$TOTAL_MODULES)"
    
    # Install the module
    install_module "$module" "$MODULE_NUM" "$TOTAL_MODULES"
    
    # Small delay to prevent overwhelming the system
    sleep 1
    
done < "$MODULES_FILE"

# Final summary
log_message ""
log_message "================================================"
log_message "📊 Module Installation Summary"
log_message "================================================"
log_message "Total modules processed: $TOTAL_MODULES"
log_message "✅ Successfully installed: $INSTALLED_MODULES"
log_message "⏭️  Already installed (skipped): $SKIPPED_MODULES"
log_message "❌ Failed to install: $FAILED_MODULES"
log_message ""

# List failed modules if any
if [ ${#FAILED_MODULE_NAMES[@]} -gt 0 ]; then
    log_message "Failed modules:"
    for module in "${FAILED_MODULE_NAMES[@]}"; do
        log_message "  - $module"
    done
    log_message ""
fi

# List skipped modules if many
if [ ${#SKIPPED_MODULE_NAMES[@]} -gt 10 ]; then
    log_message "Skipped modules (already installed): ${#SKIPPED_MODULE_NAMES[@]} modules"
    log_message "(See full list in log file)"
else
    if [ ${#SKIPPED_MODULE_NAMES[@]} -gt 0 ]; then
        log_message "Skipped modules (already installed):"
        for module in "${SKIPPED_MODULE_NAMES[@]}"; do
            log_message "  - $module"
        done
    fi
fi

log_message ""
log_message "Installation completed at $(date)"
log_message "Full log available at: $INSTALL_LOG"
log_message "================================================"

# Exit with error if any modules failed
if [ $FAILED_MODULES -gt 0 ]; then
    exit 1
else
    exit 0
fi