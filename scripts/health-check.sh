#!/bin/bash

# Health Check & Monitoring Script
# Run regularly to monitor application health

set -e

echo "🏥 CEDI App - Health Check"
echo "==========================="
echo ""
echo "Timestamp: $(date)"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }

# Check Docker services
echo "Services:"
if docker-compose ps | grep -q "Up"; then
    pass "Docker services running"
else
    fail "Docker services not running"
fi

# Check backend
echo ""
echo "Backend:"
if curl -s http://localhost:5000/health | grep -q "ok"; then
    pass "Backend API responding"
else
    fail "Backend API not responding"
fi

# Check frontend
echo ""
echo "Frontend:"
if curl -s http://localhost:3000 | grep -q "html"; then
    pass "Frontend responding"
else
    fail "Frontend not responding"
fi

# Check database
echo ""
echo "Database:"
if docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
    pass "Database connected"
else
    fail "Database not responding"
fi

# Check disk space
echo ""
echo "System:"
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    pass "Disk usage: ${DISK_USAGE}%"
else
    fail "Disk usage critical: ${DISK_USAGE}%"
fi

# Check memory
MEM_USAGE=$(free | awk '/^Mem/ {printf("%.0f", $3/$2 * 100)}')
if [ "$MEM_USAGE" -lt 80 ]; then
    pass "Memory usage: ${MEM_USAGE}%"
else
    fail "Memory usage high: ${MEM_USAGE}%"
fi

echo ""
echo "==========================="
echo "Health check complete"
echo ""
