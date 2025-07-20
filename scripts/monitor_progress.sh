#!/bin/bash

echo "================================================
📊 Module Installation Progress Monitor
================================================"

LOG_FILE="$(ls -t logs/module_installation_*.log 2>/dev/null | head -1)"

if [ -z "$LOG_FILE" ]; then
    echo "❌ No module installation log found"
    exit 1
fi

echo "Monitoring: $LOG_FILE"
echo ""

while true; do
    # Get current stats
    TOTAL=$(grep "Total modules to process:" "$LOG_FILE" | awk '{print $NF}')
    INSTALLED=$(grep -c "✅ Successfully installed:" "$LOG_FILE")
    FAILED=$(grep -c "❌ Failed to install:" "$LOG_FILE")
    SKIPPED=$(grep -c "already installed, skipping" "$LOG_FILE")
    CURRENT=$(grep "Installing module:" "$LOG_FILE" | tail -1 | cut -d: -f2 | xargs)
    
    # Get total installed modules from database
    TOTAL_IN_DB=$(docker exec odoo_postgres psql -U odoo -d Demo -t -c "SELECT COUNT(*) FROM ir_module_module WHERE state='installed';" 2>/dev/null | tr -d ' ')
    
    # Calculate progress
    if [ -n "$TOTAL" ] && [ "$TOTAL" -gt 0 ]; then
        PROCESSED=$((INSTALLED + FAILED + SKIPPED))
        PROGRESS=$((PROCESSED * 100 / TOTAL))
        REMAINING=$((TOTAL - PROCESSED))
        
        # Clear screen and show progress
        clear
        echo "================================================"
        echo "📊 Module Installation Progress"
        echo "================================================"
        echo "Total Modules in List:     $TOTAL"
        echo "✅ Installed This Run:    $INSTALLED"
        echo "⏭️  Skipped (Already):     $SKIPPED"
        echo "❌ Failed:                $FAILED"
        echo "⏳ Remaining:             $REMAINING"
        echo "📊 Progress:              $PROGRESS%"
        echo ""
        echo "📊 TOTAL in Database:      $TOTAL_IN_DB modules"
        echo ""
        echo "🔄 Current Module: $CURRENT"
        echo ""
        echo "Progress Bar:"
        printf "["
        for i in $(seq 1 50); do
            if [ $i -le $((PROGRESS / 2)) ]; then
                printf "="
            else
                printf " "
            fi
        done
        printf "] $PROGRESS%%\n"
        echo ""
        echo "Last update: $(date)"
        echo ""
        echo "Press Ctrl+C to stop monitoring"
    fi
    
    # Check if installation is complete
    if grep -q "Installation completed at" "$LOG_FILE"; then
        echo ""
        echo "✅ Installation completed!"
        grep "Installation completed at" "$LOG_FILE"
        break
    fi
    
    sleep 5
done