#!/bin/bash

# Complete CEDI App - All-in-One Setup & Deployment Script
# Handles ALL phases: Local testing → Production → Monitoring → CI/CD

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
header() { echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"; echo -e "${BLUE}$1${NC}"; echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"; }
info() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
success() { echo -e "${GREEN}$1${NC}"; }

header "CEDI App - Complete Deployment Automation"
echo "This script will:"
echo "  1. Test local Docker environment"
echo "  2. Setup and start local application"
echo "  3. Deploy to production (your choice of platform)"
echo "  4. Configure monitoring and alerts"
echo "  5. Setup automated backups and CI/CD"
echo ""

# ============================================
# PHASE 1: VERIFICATION & LOCAL TESTING
# ============================================
header "PHASE 1: System Verification"

# Check OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    SUDO="sudo"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    SUDO=""
else
    error "Unsupported OS: $OSTYPE"
fi
info "Detected OS: $OS"

# Check Docker
if ! command -v docker &> /dev/null; then
    error "Docker not found. Install from: https://www.docker.com/products/docker-desktop"
fi
DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
info "Docker version: $DOCKER_VERSION"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    error "Docker Compose not found. Please install it."
fi
DOCKER_COMPOSE_VERSION=$(docker-compose --version | awk '{print $3}' | sed 's/,//')
info "Docker Compose version: $DOCKER_COMPOSE_VERSION"

# Check Git
if ! command -v git &> /dev/null; then
    error "Git not found. Please install it."
fi
GIT_VERSION=$(git --version | awk '{print $3}')
info "Git version: $GIT_VERSION"

# Check Docker daemon
if ! docker ps &> /dev/null; then
    error "Docker daemon is not running. Please start Docker."
fi
info "Docker daemon is running"

# ============================================
# PHASE 2: LOCAL ENVIRONMENT SETUP
# ============================================
header "PHASE 2: Local Environment Setup"

REPO_DIR=$(pwd)
cd "$REPO_DIR" || error "Failed to change directory"

# Create .env if doesn't exist
if [ ! -f .env ]; then
    info "Creating .env file from template..."
    cp backend/.env.example .env
    
    # Generate secure secrets
    JWT_SECRET=$(openssl rand -base64 32 2>/dev/null || base64 <<< "$RANDOM$RANDOM$RANDOM")
    sed -i.bak "s/your_jwt_secret_key/$JWT_SECRET/" .env
    rm -f .env.bak
    
    warn "Please edit .env file with your credentials:"
    warn "  - CLAUDE_API_KEY"
    warn "  - MANUS_API_KEY"
    warn "  - Database password"
    
    echo ""
    read -p "Press Enter after editing .env file (or skip if using test keys): "
else
    info ".env file already exists"
fi

# Start local services
info "Starting Docker services..."
docker-compose pull --quiet
docker-compose up -d

# Wait for services
info "Waiting for services to be healthy (30 seconds)..."
sleep 30

# Check service status
info "Checking service status..."
docker-compose ps

# Test backend
echo ""
info "Testing backend API..."
if curl -s http://localhost:5000/health | grep -q "ok"; then
    success "✓ Backend is running and responding"
else
    warn "Backend not responding yet, retrying..."
    sleep 10
    if ! curl -s http://localhost:5000/health | grep -q "ok"; then
        error "Backend failed to start. Check logs: docker-compose logs backend"
    fi
    success "✓ Backend is running"
fi

# Test database
info "Testing database connection..."
if docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
    success "✓ Database is connected"
else
    error "Database connection failed"
fi

# ============================================
# PHASE 3: PRODUCTION DEPLOYMENT SELECTION
# ============================================
header "PHASE 3: Production Deployment"

echo "Select deployment platform:"
echo "  1) DigitalOcean / VPS (Recommended - Low cost, Full control)"
echo "  2) Heroku (Easiest - Fully managed, Higher cost)"
echo "  3) AWS ECS/Fargate (Most scalable - Enterprise-grade)"
echo "  4) Skip (Use local setup only)"
echo ""
read -p "Select option (1-4): " DEPLOY_OPTION

case $DEPLOY_OPTION in
    1)
        header "DigitalOcean / VPS Deployment"
        
        read -p "Enter your server IP address: " SERVER_IP
        read -p "Enter your domain name (e.g., yourdomain.com): " DOMAIN
        read -p "Enter SSH username (default: root): " SSH_USER
        SSH_USER=${SSH_USER:-root}
        
        info "Preparing deployment files..."
        chmod +x scripts/setup-production.sh
        
        info "Copying setup script to server..."
        scp scripts/setup-production.sh $SSH_USER@$SERVER_IP:/root/
        
        info "Copying docker-compose to server..."
        scp docker-compose.yml $SSH_USER@$SERVER_IP:/root/cediapp/
        scp backend/.env.example $SSH_USER@$SERVER_IP:/root/cediapp/backend/
        
        echo ""
        success "Setup files copied to server. To complete deployment, SSH into your server and run:"
        echo ""
        echo "  ssh $SSH_USER@$SERVER_IP"
        echo "  cd /root"
        echo "  bash setup-production.sh"
        echo ""
        ;;
        
    2)
        header "Heroku Deployment"
        
        if ! command -v heroku &> /dev/null; then
            info "Installing Heroku CLI..."
            if [[ $OS == "macos" ]]; then
                brew tap heroku/brew && brew install heroku
            else
                curl https://cli-assets.heroku.com/install.sh | sh
            fi
        fi
        
        info "Checking Heroku login..."
        if ! heroku auth:whoami > /dev/null 2>&1; then
            heroku login
        fi
        
        read -p "Enter Heroku app name for backend (e.g., cediapp-backend): " HEROKU_BACKEND
        read -p "Enter Heroku app name for frontend (e.g., cediapp-frontend): " HEROKU_FRONTEND
        
        info "Creating Heroku apps..."
        heroku create $HEROKU_BACKEND --buildpack heroku/nodejs || true
        heroku create $HEROKU_FRONTEND --buildpack heroku/nodejs || true
        
        info "Adding PostgreSQL database..."
        heroku addons:create heroku-postgresql:hobby-dev --app $HEROKU_BACKEND || true
        
        info "Setting environment variables..."
        heroku config:set NODE_ENV=production --app $HEROKU_BACKEND
        heroku config:set JWT_SECRET=$(openssl rand -base64 32) --app $HEROKU_BACKEND
        
        info "Deploying backend..."
        cd backend
        heroku git:remote -a $HEROKU_BACKEND
        git push heroku main
        cd ..
        
        info "Deploying frontend..."
        cd frontend
        heroku config:set REACT_APP_API_URL=https://$HEROKU_BACKEND.herokuapp.com/api --app $HEROKU_FRONTEND
        heroku git:remote -a $HEROKU_FRONTEND
        git push heroku main
        cd ..
        
        success "Heroku deployment complete!"
        success "Frontend: https://$HEROKU_FRONTEND.herokuapp.com"
        success "Backend: https://$HEROKU_BACKEND.herokuapp.com/api"
        ;;
        
    3)
        header "AWS ECS/Fargate Deployment"
        
        if ! command -v aws &> /dev/null; then
            error "AWS CLI not installed. Install from: https://aws.amazon.com/cli/"
        fi
        
        info "Getting AWS account information..."
        AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        AWS_REGION=${AWS_REGION:-us-east-1}
        
        success "AWS Account: $AWS_ACCOUNT_ID"
        success "AWS Region: $AWS_REGION"
        
        info "Building Docker images..."
        docker build -t cediapp-backend:latest backend/
        docker build -t cediapp-frontend:latest frontend/
        
        info "Pushing to AWS ECR..."
        chmod +x scripts/deploy-aws.sh
        AWS_REGION=$AWS_REGION bash scripts/deploy-aws.sh
        
        success "AWS deployment initiated. See docs/AWS_DEPLOYMENT.md for ECS setup."
        ;;
        
    4)
        warn "Skipping production deployment. Using local setup only."
        ;;
        
    *)
        error "Invalid option"
        ;;
esac

# ============================================
# PHASE 4: MONITORING & ALERTS SETUP
# ============================================
header "PHASE 4: Monitoring & Alerts"

read -p "Setup monitoring stack (Prometheus + Grafana)? (y/n): " SETUP_MONITORING

if [[ $SETUP_MONITORING == "y" ]] || [[ $SETUP_MONITORING == "Y" ]]; then
    info "Starting monitoring stack..."
    docker-compose -f docker-compose.monitoring.yml up -d
    
    info "Waiting for monitoring services to start..."
    sleep 15
    
    success "Monitoring stack is running!"
    success "Access Grafana: http://localhost:3001 (admin/admin)"
    success "Access Prometheus: http://localhost:9090"
    
    info "Importing Grafana dashboards..."
    # Dashboards can be imported from https://grafana.com/grafana/dashboards/
    warn "Please manually import Docker & System dashboards in Grafana UI"
else
    info "Monitoring setup skipped"
fi

# ============================================
# PHASE 5: AUTOMATED BACKUPS
# ============================================
header "PHASE 5: Automated Backups"

read -p "Setup automated daily backups? (y/n): " SETUP_BACKUPS

if [[ $SETUP_BACKUPS == "y" ]] || [[ $SETUP_BACKUPS == "Y" ]]; then
    info "Creating backup directory..."
    mkdir -p "$REPO_DIR/backups"
    
    info "Creating backup script..."
    chmod +x scripts/backup-db.sh
    
    if [[ $OS == "linux" ]]; then
        info "Adding cron job for daily backups..."
        (crontab -l 2>/dev/null; echo "0 2 * * * cd $REPO_DIR && bash scripts/backup-db.sh") | crontab -
        success "Backup scheduled for 2 AM daily"
    else
        warn "Please manually setup backup cron job on production server"
        echo "Command: 0 2 * * * cd $REPO_DIR && bash scripts/backup-db.sh"
    fi
    
    info "Creating first backup..."
    bash scripts/backup-db.sh
    success "Backup created in: $REPO_DIR/backups/"
else
    info "Automated backups skipped"
fi

# ============================================
# PHASE 6: CI/CD PIPELINE SETUP
# ============================================
header "PHASE 6: CI/CD Pipeline Setup"

read -p "Setup GitHub Secrets for CI/CD? (y/n): " SETUP_CICD

if [[ $SETUP_CICD == "y" ]] || [[ $SETUP_CICD == "Y" ]]; then
    info "Getting repository information..."
    REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
    REPO_NAME=$(echo $REPO_URL | sed 's/.*\///;s/.git//')
    REPO_OWNER=$(echo $REPO_URL | sed 's/.*\///;s/\/.*//')
    
    if [ -z "$REPO_NAME" ] || [ -z "$REPO_OWNER" ]; then
        read -p "Enter GitHub repository (owner/repo): " GITHUB_REPO
        IFS='/' read -r REPO_OWNER REPO_NAME <<< "$GITHUB_REPO"
    fi
    
    success "Repository: $REPO_OWNER/$REPO_NAME"
    
    echo ""
    info "Required GitHub Secrets:"
    echo "  DOCKER_REGISTRY_URL=docker.io"
    echo "  DOCKER_USERNAME=<your-docker-username>"
    echo "  DOCKER_PASSWORD=<your-docker-token>"
    echo ""
    
    echo "Add secrets at: https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
    echo ""
    
    read -p "Have you added the GitHub Secrets? (y/n): " SECRETS_ADDED
    if [[ $SECRETS_ADDED == "y" ]] || [[ $SECRETS_ADDED == "Y" ]]; then
        success "✓ GitHub Secrets configured"
        success "✓ CI/CD Pipeline will trigger on next push"
    fi
else
    info "CI/CD setup skipped"
fi

# ============================================
# FINAL SUMMARY
# ============================================
header "Deployment Complete! 🎉"

echo ""
echo "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo "${GREEN}              YOUR CEDI APP IS READY TO DEPLOY             ${NC}"
echo "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""

echo "${BLUE}Local Development:${NC}"
echo "  Frontend: http://localhost:3000"
echo "  Backend API: http://localhost:5000/api"
echo "  Database: localhost:5432"
echo ""

if [[ $SETUP_MONITORING == "y" ]] || [[ $SETUP_MONITORING == "Y" ]]; then
    echo "${BLUE}Monitoring:${NC}"
    echo "  Grafana: http://localhost:3001 (admin/admin)"
    echo "  Prometheus: http://localhost:9090"
    echo ""
fi

echo "${BLUE}Quick Commands:${NC}"
echo "  View logs: docker-compose logs -f backend"
echo "  Stop services: docker-compose down"
echo "  Restart services: docker-compose restart"
echo "  Health check: bash scripts/health-check.sh"
echo ""

echo "${BLUE}Documentation:${NC}"
echo "  Complete Setup: docs/COMPLETE_SETUP.md"
echo "  API Reference: docs/API.md"
echo "  Deployment Guide: docs/DEPLOYMENT.md"
echo ""

echo "${BLUE}Next Steps:${NC}"
echo "  1. Make a change and push to GitHub"
echo "  2. Watch CI/CD pipeline at: https://github.com/$REPO_OWNER/$REPO_NAME/actions"
echo "  3. Monitor in Grafana dashboard"
echo "  4. Check automated backups in: $REPO_DIR/backups/"
echo ""

echo "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo "${GREEN}  Ready for production deployment! 🚀${NC}"
echo "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
