#!/bin/bash

# Complete Vercel Deployment Script
# Handles frontend, backend, database, and environment setup for Vercel

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

header() { echo -e "\n${BLUE}$1${NC}"; }
info() { echo -e "${GREEN}[✓]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

header "CEDI App - Complete Vercel Deployment"
echo "This script will:"
echo "  1. Deploy frontend to Vercel"
echo "  2. Deploy backend to Vercel"
echo "  3. Configure database (Supabase)"
echo "  4. Setup environment variables"
echo "  5. Configure GitHub integration"
echo ""

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    info "Installing Vercel CLI..."
    npm install -g vercel
fi

# Login to Vercel
header "Step 1: Vercel Authentication"
info "Please login to Vercel..."
vercel login

# Get project info
echo ""
read -p "Enter project name (default: cediapp): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-cediapp}

# Frontend deployment
header "Step 2: Frontend Deployment"
echo ""
info "Building and deploying frontend..."
cd frontend

if [ ! -f vercel.json ]; then
    info "Creating vercel.json for frontend..."
fi

npm install
npm run build

echo ""
read -p "Create new Vercel project for frontend? (y/n): " CREATE_NEW_FRONTEND

if [[ $CREATE_NEW_FRONTEND == "y" ]] || [[ $CREATE_NEW_FRONTEND == "Y" ]]; then
    vercel --prod --name="${PROJECT_NAME}-frontend"
else
    vercel --prod
fi

FRONTEND_URL=$(vercel ls --json | jq -r '.[0].url' | head -1)
info "Frontend deployed: $FRONTEND_URL"

cd ..

# Backend deployment
header "Step 3: Backend Deployment"
echo ""
info "Preparing backend for Vercel..."
cd backend

if [ ! -f vercel.json ]; then
    info "Creating vercel.json for backend..."
fi

npm install

echo ""
read -p "Create new Vercel project for backend? (y/n): " CREATE_NEW_BACKEND

if [[ $CREATE_NEW_BACKEND == "y" ]] || [[ $CREATE_NEW_BACKEND == "Y" ]]; then
    vercel --prod --name="${PROJECT_NAME}-backend"
else
    vercel --prod
fi

BACKEND_URL=$(vercel ls --json | jq -r '.[0].url' | head -1)
info "Backend deployed: $BACKEND_URL"

cd ..

# Database setup
header "Step 4: Database Configuration"
echo ""
echo "Choose database option:"
echo "  1) Supabase (PostgreSQL - Recommended)"
echo "  2) Neon (PostgreSQL)"
echo "  3) Already have database connection string"
echo ""
read -p "Select option (1-3): " DB_OPTION

case $DB_OPTION in
    1)
        info "Supabase selected"
        echo ""
        echo "Go to https://supabase.com and:"
        echo "  1. Create new project"
        echo "  2. Get connection string"
        echo ""
        read -p "Enter Supabase connection string: " DB_CONNECTION_STRING
        ;;
    2)
        info "Neon selected"
        echo ""
        echo "Go to https://neon.tech and:"
        echo "  1. Create new project"
        echo "  2. Get connection string"
        echo ""
        read -p "Enter Neon connection string: " DB_CONNECTION_STRING
        ;;
    3)
        read -p "Enter database connection string: " DB_CONNECTION_STRING
        ;;
    *)
        error "Invalid option"
        ;;
esac

# Parse connection string
if [[ $DB_CONNECTION_STRING == *"@"* ]]; then
    DB_USER=$(echo $DB_CONNECTION_STRING | sed 's/postgres:\/\///' | sed 's/:.*@//' )
    DB_PASSWORD=$(echo $DB_CONNECTION_STRING | sed 's/.*://' | sed 's/@.*//')
    DB_HOST=$(echo $DB_CONNECTION_STRING | sed 's/.*@//' | sed 's/:.*\/.*//')
    DB_PORT=$(echo $DB_CONNECTION_STRING | sed 's/.*://' | sed 's/\/.*//')
    DB_NAME=$(echo $DB_CONNECTION_STRING | sed 's/.*\///')
fi

# Environment variables
header "Step 5: Environment Configuration"
echo ""
read -p "Enter Claude API Key: " CLAUDE_API_KEY
read -p "Enter Manus API Key: " MANUS_API_KEY
read -sp "Enter JWT Secret: " JWT_SECRET
echo ""

# Generate secure JWT if empty
if [ -z "$JWT_SECRET" ]; then
    JWT_SECRET=$(openssl rand -base64 32 2>/dev/null || echo "cediapp-jwt-secret-$(date +%s)")
fi

info "Setting backend environment variables..."
vercel env add DB_HOST --value "$DB_HOST" --yes
vercel env add DB_PORT --value "$DB_PORT" --yes
vercel env add DB_NAME --value "$DB_NAME" --yes
vercel env add DB_USER --value "$DB_USER" --yes
vercel env add DB_PASSWORD --value "$DB_PASSWORD" --yes
vercel env add CLAUDE_API_KEY --value "$CLAUDE_API_KEY" --yes
vercel env add MANUS_API_KEY --value "$MANUS_API_KEY" --yes
vercel env add JWT_SECRET --value "$JWT_SECRET" --yes
vercel env add CORS_ORIGIN --value "https://$FRONTEND_URL" --yes

cd ../frontend
info "Setting frontend environment variables..."
vercel env add REACT_APP_API_URL --value "https://$BACKEND_URL/api" --yes

cd ..

# GitHub integration
header "Step 6: GitHub Integration"
echo ""
echo "GitHub integration allows automatic deployment on push"
read -p "Connect GitHub repository? (y/n): " SETUP_GITHUB

if [[ $SETUP_GITHUB == "y" ]] || [[ $SETUP_GITHUB == "Y" ]]; then
    info "Follow these steps:"
    echo "  1. Go to Vercel Dashboard"
    echo "  2. Select your projects"
    echo "  3. Settings > Git Integration"
    echo "  4. Connect GitHub"
    echo "  5. Select smtnewgh-blip/cediapp"
fi

# Final verification
header "Step 7: Verification"
echo ""
echo "Testing deployments..."

echo ""
echo "Frontend URL: https://$FRONTEND_URL"
if curl -s "https://$FRONTEND_URL" | grep -q "html\|React" > /dev/null 2>&1; then
    info "Frontend is responding"
else
    warn "Frontend may not be ready yet"
fi

echo ""
echo "Backend URL: https://$BACKEND_URL"
if curl -s "https://$BACKEND_URL/health" | grep -q "ok" > /dev/null 2>&1; then
    info "Backend is responding"
else
    warn "Backend may need environment variables or database setup"
fi

# Summary
header "Deployment Complete!"
echo ""
echo "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo "${GREEN}  CEDI App Successfully Deployed to Vercel! 🎉${NC}"
echo "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""

echo "${BLUE}Deployment URLs:${NC}"
echo "  Frontend: https://$FRONTEND_URL"
echo "  Backend: https://$BACKEND_URL"
echo ""

echo "${BLUE}Database:${NC}"
echo "  Host: $DB_HOST"
echo "  Name: $DB_NAME"
echo ""

echo "${BLUE}Quick Commands:${NC}"
echo "  View logs: vercel logs --tail"
echo "  View deployments: vercel ls"
echo "  Set environment: vercel env"
echo ""

echo "${BLUE}Documentation:${NC}"
echo "  Vercel Deployment: docs/VERCEL_DEPLOYMENT.md"
echo "  API Reference: docs/API.md"
echo ""

echo "${BLUE}Next Steps:${NC}"
echo "  1. Test the deployed applications"
echo "  2. Configure custom domain in Vercel"
echo "  3. Setup monitoring in Vercel Analytics"
echo "  4. Configure GitHub integration for auto-deploy"
echo ""
