# Docker Hub & VPS Deployment Guide

## Step 1: Push Images to Docker Hub

### Create Docker Hub Account
1. Go to https://hub.docker.com
2. Sign up or login
3. Create two repositories:
   - `your-username/cediapp-backend`
   - `your-username/cediapp-frontend`

### Build and Push Images

```bash
# Login to Docker Hub
docker login

# Build backend
cd backend
docker build -t your-username/cediapp-backend:1.0.0 .
docker push your-username/cediapp-backend:1.0.0
docker push your-username/cediapp-backend:latest

# Build frontend
cd ../frontend
docker build -t your-username/cediapp-frontend:1.0.0 .
docker push your-username/cediapp-frontend:1.0.0
docker push your-username/cediapp-frontend:latest
```

## Step 2: Deploy to VPS (DigitalOcean, Linode, AWS EC2)

### Prerequisites
- VPS with Ubuntu 20.04+
- SSH access
- Docker and Docker Compose installed

### SSH into Your Server

```bash
ssh root@your_server_ip
```

### Install Docker

```bash
# Update packages
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker --version
docker-compose --version
```

### Clone Your Repository

```bash
git clone https://github.com/smtnewgh-blip/cediapp.git
cd cediapp
```

### Update docker-compose.yml for Production

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: cediapp-db
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backend/src/database/schema.sql:/docker-entrypoint-initdb.d/schema.sql
    networks:
      - cediapp-network
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    image: your-username/cediapp-backend:latest
    container_name: cediapp-backend
    environment:
      NODE_ENV: production
      PORT: 5000
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: ${DB_NAME}
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      CLAUDE_API_KEY: ${CLAUDE_API_KEY}
      CLAUDE_MODEL: ${CLAUDE_MODEL}
      MANUS_API_KEY: ${MANUS_API_KEY}
      MANUS_API_URL: ${MANUS_API_URL}
      JWT_SECRET: ${JWT_SECRET}
      CORS_ORIGIN: ${CORS_ORIGIN}
    ports:
      - "5000:5000"
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - cediapp-network
    restart: always

  frontend:
    image: your-username/cediapp-frontend:latest
    container_name: cediapp-frontend
    environment:
      REACT_APP_API_URL: ${API_URL}
    ports:
      - "3000:3000"
    depends_on:
      - backend
    networks:
      - cediapp-network
    restart: always

  nginx:
    image: nginx:alpine
    container_name: cediapp-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - backend
      - frontend
    networks:
      - cediapp-network
    restart: always

volumes:
  postgres_data:

networks:
  cediapp-network:
    driver: bridge
```

### Create .env File

```bash
cat > .env << 'EOF'
# Database
DB_NAME=cediapp_prod
DB_USER=cediapp_user
DB_PASSWORD=$(openssl rand -base64 32)

# Claude AI
CLAUDE_API_KEY=your_claude_key
CLAUDE_MODEL=claude-3-sonnet-20240229

# Manus
MANUS_API_KEY=your_manus_key
MANUS_API_URL=https://api.manus.io

# JWT
JWT_SECRET=$(openssl rand -base64 32)

# CORS & API
CORS_ORIGIN=https://yourdomain.com
API_URL=https://api.yourdomain.com
EOF
```

### Create Nginx Configuration

```bash
cat > nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;

    # Backend API
    upstream backend {
        server cediapp-backend:5000;
    }

    # Frontend
    upstream frontend {
        server cediapp-frontend:3000;
    }

    # Redirect HTTP to HTTPS
    server {
        listen 80;
        server_name yourdomain.com www.yourdomain.com;
        return 301 https://$server_name$request_uri;
    }

    # HTTPS Server
    server {
        listen 443 ssl http2;
        server_name yourdomain.com www.yourdomain.com;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }

        # API
        location /api/ {
            proxy_pass http://backend/api/;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF
```

### Start Services

```bash
# Pull latest images
docker-compose pull

# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f backend
```

### Setup SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get certificate
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Copy certificates to ssl directory
sudo mkdir -p ssl
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem
sudo chmod 644 ssl/*

# Restart nginx
docker-compose restart nginx
```

### Auto-Renew SSL

```bash
# Create renewal script
cat > /usr/local/bin/renew-ssl.sh << 'EOF'
#!/bin/bash
cd /root/cediapp
sudo certbot renew --quiet
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem
docker-compose restart nginx
EOF

# Make executable
sudo chmod +x /usr/local/bin/renew-ssl.sh

# Add to crontab (runs daily at 2 AM)
sudo crontab -e
# Add: 0 2 * * * /usr/local/bin/renew-ssl.sh
```

## Monitoring

### View Application Logs

```bash
# Backend logs
docker-compose logs -f backend

# Frontend logs
docker-compose logs -f frontend

# Database logs
docker-compose logs -f postgres

# All logs
docker-compose logs -f
```

### Health Checks

```bash
# API health
curl https://yourdomain.com/api/health

# Container status
docker-compose ps

# Resource usage
docker stats
```

### Backup Database

```bash
# Backup
docker-compose exec postgres pg_dump -U cediapp_user cediapp_prod > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore
docker-compose exec -T postgres psql -U cediapp_user cediapp_prod < backup_20240714_120000.sql
```

## Maintenance

### Update Application

```bash
# Pull latest code
git pull origin main

# Pull latest Docker images
docker-compose pull

# Restart services
docker-compose up -d
```

### View Real-Time Metrics

```bash
# CPU, Memory, Network
docker stats

# Container details
docker inspect cediapp-backend
```

## Cost Optimization

- **DigitalOcean Droplet**: $5-15/month (basic)
- **Database**: PostgreSQL managed $15/month (recommended)
- **Domain**: $10-15/year
- **SSL**: Free (Let's Encrypt)
- **Total**: ~$30-50/month

## Troubleshooting

### Port Already in Use
```bash
# Find process using port
lsof -i :3000
lsof -i :5000

# Kill process
kill -9 <PID>
```

### Database Connection Failed
```bash
# Restart database
docker-compose restart postgres

# Check logs
docker-compose logs postgres
```

### Out of Disk Space
```bash
# Clean up Docker
docker system prune -a

# Check disk usage
df -h
du -sh /var/lib/docker
```

## Success Indicators

✅ Frontend accessible at https://yourdomain.com
✅ Backend API accessible at https://api.yourdomain.com/api/health
✅ Database connected and working
✅ SSL certificate valid
✅ Auto-renewal enabled
✅ Logs showing no errors
✅ All services running
