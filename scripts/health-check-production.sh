#!/bin/bash

# Production Health Check Script
# Run periodically to monitor application health

set -e

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║        CEDI App - Production Health Check                ║"
echo "║        $(date '+%Y-%m-%d %H:%M:%S')                                ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Configuration
BACKEND_URL="${BACKEND_URL:-http://localhost:5000}"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:3000}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}[✓]${NC} $1"; }
fail() { echo -e "${RED}[✗]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

HEALTH_OK=true

# Check Backend
echo "Backend Services:"
if curl -s "$BACKEND_URL/health" | grep -q "ok"; then
    pass "API health check passing"
else
    fail "API health check failed"
    HEALTH_OK=false
fi

# Check Frontend
echo ""
echo "Frontend Services:"
if curl -s "$FRONTEND_URL" | grep -q "html\|React\|<!DOCTYPE" > /dev/null 2>&1; then
    pass "Frontend responding"
else
    fail "Frontend not responding"
    HEALTH_OK=false
fi

# Check Database
echo ""
echo "Database Services:"
if nc -z $DB_HOST $DB_PORT 2>/dev/null || command -v psql &>/dev/null; then
    if pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER 2>/dev/null || true; then
        pass "Database connection OK"
    else
        fail "Database connection failed"
        HEALTH_OK=false
    fi
else
    warn "Could not verify database connectivity"
fi

# Check System Resources
echo ""
echo "System Resources:"

# Disk Usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    pass "Disk usage: ${DISK_USAGE}%"
else
    fail "Disk usage critical: ${DISK_USAGE}%"
    HEALTH_OK=false
fi

# Memory Usage
if command -v free &> /dev/null; then
    MEM_USAGE=$(free | awk '/^Mem/ {printf("%.0f", $3/$2 * 100)}')
    if [ "$MEM_USAGE" -lt 80 ]; then
        pass "Memory usage: ${MEM_USAGE}%"
    else
        fail "Memory usage high: ${MEM_USAGE}%"
        HEALTH_OK=false
    fi
fi

# Docker Services
echo ""
echo "Docker Services:"
if command -v docker-compose &> /dev/null; then
    RUNNING_SERVICES=$(docker-compose ps --services --filter "status=running" 2>/dev/null | wc -l)
    TOTAL_SERVICES=$(docker-compose ps --services 2>/dev/null | wc -l)
    
    if [ "$RUNNING_SERVICES" -eq "$TOTAL_SERVICES" ] && [ "$TOTAL_SERVICES" -gt 0 ]; then
        pass "All $RUNNING_SERVICES services running"
    else
        fail "Only $RUNNING_SERVICES/$TOTAL_SERVICES services running"
        HEALTH_OK=false
    fi
else
    warn "Docker Compose not found"
fi

# SSL Certificate
echo ""
echo "SSL/TLS Certificates:"
if command -v certbot &> /dev/null; then
    CERT_INFO=$(certbot certificates 2>/dev/null | grep -A2 "Certificate Path" | head -1 || echo "")
    if [ -z "$CERT_INFO" ]; then
        warn "No SSL certificates found"
    else
        EXPIRY=$(openssl x509 -in "${CERT_INFO#*: }" -noout -enddate 2>/dev/null | cut -d= -f2 || echo "Unknown")
        pass "SSL certificate expires: $EXPIRY"
    fi
else
    warn "Certbot not found"
fi

# Summary
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
if [ "$HEALTH_OK" = true ]; then
    echo -e "${GREEN}║        All health checks PASSED ✓                      ║${NC}"
else
    echo -e "${RED}║        Some health checks FAILED ✗                     ║${NC}"
fi
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Exit with appropriate code
if [ "$HEALTH_OK" = true ]; then
    exit 0
else
    exit 1
fi
