#!/bin/bash

echo "================================================
🔍 Odoo Installation Status Check
================================================"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check status
check_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

# Check Docker
echo ""
echo "1. Docker Status:"
docker --version > /dev/null 2>&1
check_status $? "Docker installed"

docker info > /dev/null 2>&1
check_status $? "Docker daemon running"

# Check containers
echo ""
echo "2. Container Status:"
if docker-compose ps | grep -q "odoo_postgres.*Up"; then
    echo -e "${GREEN}✅ PostgreSQL container running${NC}"
else
    echo -e "${RED}❌ PostgreSQL container not running${NC}"
fi

if docker-compose ps | grep -q "odoo_app.*Up"; then
    echo -e "${GREEN}✅ Odoo container running${NC}"
else
    echo -e "${RED}❌ Odoo container not running${NC}"
fi

# Check Odoo accessibility
echo ""
echo "3. Odoo Accessibility:"
if curl -s http://localhost:8069/web/health > /dev/null; then
    echo -e "${GREEN}✅ Odoo web interface accessible at http://localhost:8069${NC}"
else
    echo -e "${RED}❌ Odoo web interface not accessible${NC}"
fi

# Check database
echo ""
echo "4. Database Status:"
DB_EXISTS=$(docker exec odoo_postgres psql -U odoo -lqt 2>/dev/null | cut -d \| -f 1 | grep -w "Demo" | wc -l)
if [ "$DB_EXISTS" -gt 0 ]; then
    echo -e "${GREEN}✅ Demo database exists${NC}"
    
    # Get database size
    DB_SIZE=$(docker exec odoo_postgres psql -U odoo -t -c "SELECT pg_size_pretty(pg_database_size('Demo'));" 2>/dev/null | xargs)
    echo "   Database size: $DB_SIZE"
else
    echo -e "${YELLOW}⚠️  Demo database not found${NC}"
    echo "   Run ./scripts/auto_setup_complete.sh to create it"
fi

# Check installed modules (if database exists)
if [ "$DB_EXISTS" -gt 0 ]; then
    echo ""
    echo "5. Installed Modules:"
    MODULE_COUNT=$(docker exec odoo_app odoo -c /etc/odoo/odoo.conf -d Demo --list-modules 2>/dev/null | grep -E "^\s+\w+" | wc -l)
    if [ "$MODULE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ $MODULE_COUNT modules available${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not count modules${NC}"
    fi
fi

# Check configuration files
echo ""
echo "6. Configuration Files:"
[ -f "config/odoo.conf" ] && echo -e "${GREEN}✅ config/odoo.conf exists${NC}" || echo -e "${RED}❌ config/odoo.conf missing${NC}"
[ -f "config/auto_odoo.conf" ] && echo -e "${GREEN}✅ config/auto_odoo.conf exists${NC}" || echo -e "${YELLOW}⚠️  config/auto_odoo.conf missing (needed for automation)${NC}"
[ -f ".env" ] && echo -e "${GREEN}✅ .env file exists${NC}" || echo -e "${YELLOW}⚠️  .env file missing${NC}"

# Check logs
echo ""
echo "7. Recent Logs:"
if [ -d "logs" ] && [ "$(ls -A logs 2>/dev/null)" ]; then
    echo -e "${GREEN}✅ Log files found:${NC}"
    ls -la logs/*.log 2>/dev/null | tail -5 | awk '{print "   " $9}'
else
    echo "   No log files found"
fi

# Summary
echo ""
echo "================================================"
echo "📊 Summary"
echo "================================================"

ALL_GOOD=true

# Check critical components
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}⚠️  Docker is not running!${NC}"
    echo "   Start Docker Desktop first"
    ALL_GOOD=false
elif ! docker-compose ps | grep -q "Up"; then
    echo -e "${YELLOW}⚠️  Containers are not running!${NC}"
    echo "   Run: ./scripts/start.sh"
    ALL_GOOD=false
elif [ "$DB_EXISTS" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Demo database not created!${NC}"
    echo "   Run: ./scripts/auto_setup_complete.sh"
    ALL_GOOD=false
else
    echo -e "${GREEN}✅ Everything looks good!${NC}"
    echo ""
    echo "🌐 Access Odoo at: http://localhost:8069"
    echo "📧 Login: rohitsoni@gmail.com"
    echo "🔑 Password: Rohit819"
    echo "🗄️ Database: Demo"
fi

echo "================================================"