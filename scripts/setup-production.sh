#!/bin/bash

# Production Setup Script for DigitalOcean/VPS
# Automates entire deployment process

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           CEDI App - Production Setup Script                   ║"
echo "║              (DigitalOcean/VPS Installation)                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# Check if running as root
if [ "$EUID" -ne 0 ]; then
   error "This script must be run as root"
fi

info "Updating system packages..."
apt update && apt upgrade -y

info "Installing dependencies..."
apt install -y \
    curl \
    git \
    wget \
    htop \
    certbot \
    python3-certbot-nginx \
    nginx \
    net-tools

info "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

info "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

info "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Collect information
echo ""
echo "${YELLOW}Please provide the following information:${NC}"
read -p "Domain name (e.g., yourdomain.com): " DOMAIN
read -p "Claude API Key: " CLAUDE_API_KEY
read -p "Manus API Key: " MANUS_API_KEY
read -sp "Database password: " DB_PASSWORD
echo ""

# Generate JWT Secret
JWT_SECRET=$(openssl rand -base64 32)

info "Cloning CEDI App repository..."
cd /root
git clone https://github.com/smtnewgh-blip/cediapp.git
cd cediapp

info "Creating environment file..."
cat > .env << EOF
# Database
DB_NAME=cediapp_prod
DB_USER=postgres
DB_PASSWORD=$DB_PASSWORD

# Claude AI
CLAUDE_API_KEY=$CLAUDE_API_KEY
CLAUDE_MODEL=claude-3-sonnet-20240229

# Manus
MANUS_API_KEY=$MANUS_API_KEY
MANUS_API_URL=https://api.manus.io

# JWT
JWT_SECRET=$JWT_SECRET
JWT_EXPIRES_IN=7d

# URLs
CORS_ORIGIN=https://$DOMAIN
API_URL=https://api.$DOMAIN
EOF

info "Creating Nginx configuration..."
sudo mkdir -p /etc/nginx/sites-available
cat > /etc/nginx/sites-available/cediapp << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN api.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}

server {
    listen 443 ssl http2;
    server_name api.$DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

info "Enabling Nginx configuration..."
ln -sf /etc/nginx/sites-available/cediapp /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

info "Getting SSL certificate from Let's Encrypt..."
certbot certonly --nginx -d "$DOMAIN" -d "www.$DOMAIN" -d "api.$DOMAIN" --non-interactive --agree-tos --email "admin@$DOMAIN"

info "Starting Docker containers..."
docker-compose pull
docker-compose up -d

info "Waiting for services to be ready..."
sleep 30

info "Verifying services..."
if curl -s http://localhost:5000/health | grep -q "ok"; then
    info "Backend is running ✓"
else
    error "Backend failed to start"
fi

info "Setting up automated SSL renewal..."
cat > /usr/local/bin/renew-ssl.sh << 'SSLEOF'
#!/bin/bash
certbot renew --quiet
systemctl reload nginx
SLLEOF
chmod +x /usr/local/bin/renew-ssl.sh
echo "0 2 * * * /usr/local/bin/renew-ssl.sh" | crontab -

info "Setting up database backups..."
cat > /usr/local/bin/backup-cediapp-db.sh << 'BACKUPEOF'
#!/bin/bash
cd /root/cediapp
BACKUP_DIR="/backups/cediapp"
mkdir -p $BACKUP_DIR
docker-compose exec -T postgres pg_dump -U postgres cediapp_prod > $BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete
BACKUPEOF
chmod +x /usr/local/bin/backup-cediapp-db.sh
mkdir -p /backups/cediapp
echo "0 2 * * * /usr/local/bin/backup-cediapp-db.sh" | crontab -

info "Setting up log rotation..."
cat > /etc/logrotate.d/cediapp << 'LOGEOF'
/root/cediapp/logs/* {
    daily
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 root root
}
LOGEOF

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    Setup Complete! 🎉                           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "${GREEN}Your CEDI App is now live!${NC}"
echo ""
echo "Access your application:"
echo "  Frontend: https://$DOMAIN"
echo "  Backend API: https://api.$DOMAIN/api"
echo "  Health Check: https://api.$DOMAIN/api/health"
echo ""
echo "Useful commands:"
echo "  View logs: docker-compose logs -f"
echo "  Restart services: docker-compose restart"
echo "  Stop services: docker-compose down"
echo "  Update services: docker-compose pull && docker-compose up -d"
echo ""
echo "Monitoring:"
echo "  Check disk usage: df -h"
echo "  Check resource usage: docker stats"
echo "  View system info: htop"
echo ""
echo "Backups:"
echo "  Automatic backups daily at 2 AM"
echo "  Backup location: /backups/cediapp/"
echo "  Manual backup: /usr/local/bin/backup-cediapp-db.sh"
echo ""
echo "SSL Certificate:"
echo "  Expires: $(certbot certificates | grep -A5 $DOMAIN | grep 'Expiry Date')"
echo "  Auto-renewal: Enabled (daily at 2 AM)"
echo ""
echo "Documentation: https://github.com/smtnewgh-blip/cediapp/docs/COMPLETE_SETUP.md"
echo ""
