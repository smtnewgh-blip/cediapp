# DigitalOcean Deployment Guide

## Option 1: DigitalOcean App Platform (Easiest)

### Step 1: Connect GitHub Repository

1. Go to https://cloud.digitalocean.com/apps
2. Click "Create App"
3. Select "GitHub"
4. Authorize and select `smtnewgh-blip/cediapp` repository
5. Select branch: `main`

### Step 2: Configure Services

**Backend Service:**
- Name: `cediapp-backend`
- Source: `backend/Dockerfile`
- HTTP Port: 5000
- Environment Variables:
  ```
  NODE_ENV=production
  CLAUDE_API_KEY=your_key
  MANUS_API_KEY=your_key
  JWT_SECRET=your_secret
  ```

**Frontend Service:**
- Name: `cediapp-frontend`
- Source: `frontend/Dockerfile`
- HTTP Port: 3000
- Environment Variables:
  ```
  REACT_APP_API_URL=https://your-app-backend.ondigitalocean.app/api
  ```

### Step 3: Add Database

1. Click "Add Resource"
2. Select "Database"
3. Choose PostgreSQL
4. Set database name: `cediapp`
5. Note the connection string

### Step 4: Deploy

Click "Create App" - DigitalOcean will automatically:
- Build Docker images
- Deploy containers
- Manage SSL certificates
- Handle load balancing

**Cost:** ~$12/month (Starter database) + compute

---

## Option 2: DigitalOcean Droplet + Docker Compose (More Control)

### Step 1: Create Droplet

```bash
# Via CLI
doctl compute droplet create cediapp-server \
  --region nyc3 \
  --size s-1vcpu-1gb \
  --image ubuntu-22-04-x64 \
  --enable-monitoring

# Or use DigitalOcean console at https://cloud.digitalocean.com
```

### Step 2: SSH into Droplet

```bash
ssh root@your_droplet_ip
```

### Step 3: Install Docker & Dependencies

```bash
# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
apt install -y git
```

### Step 4: Clone and Deploy

```bash
# Clone repository
git clone https://github.com/smtnewgh-blip/cediapp.git
cd cediapp

# Create .env file
cat > .env << 'EOF'
DB_NAME=cediapp_prod
DB_USER=postgres
DB_PASSWORD=$(openssl rand -base64 32)
CLAUDE_API_KEY=your_key
MANUS_API_KEY=your_key
JWT_SECRET=$(openssl rand -base64 32)
CORS_ORIGIN=https://yourdomain.com
API_URL=https://api.yourdomain.com
EOF

# Start services
docker-compose up -d
```

### Step 5: Setup Floating IP (Optional)

```bash
# Create Floating IP
doctl compute floating-ip create --region nyc3

# Assign to Droplet
doctl compute floating-ip-action assign your_floating_ip your_droplet_id
```

### Step 6: Add DNS Records

1. Go to DigitalOcean Domains
2. Create/Update domain:
   ```
   A Record: yourdomain.com → your_droplet_ip
   A Record: api.yourdomain.com → your_droplet_ip
   ```

### Step 7: Setup Nginx with SSL

```bash
# Install Nginx
apt install -y nginx certbot python3-certbot-nginx

# Create config
cat > /etc/nginx/sites-available/cediapp << 'EOF'
server {
    listen 80;
    server_name yourdomain.com api.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
    }
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Enable config
ln -s /etc/nginx/sites-available/cediapp /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Test and reload
nginx -t
systemctl reload nginx
```

### Step 8: Setup SSL with Let's Encrypt

```bash
# Get certificate
certbot certonly --nginx -d yourdomain.com -d api.yourdomain.com

# Update nginx config with certificate paths
# Edit /etc/nginx/sites-available/cediapp to add:
# ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

# Reload nginx
systemctl reload nginx
```

## Monitoring on DigitalOcean

### View Logs

```bash
# SSH into Droplet
ssh root@your_droplet_ip

# View application logs
cd /root/cediapp
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Backup Database

```bash
# Manual backup
docker-compose exec postgres pg_dump -U postgres cediapp_prod > backup.sql

# Automated backup (daily at 2 AM)
cat >> /etc/crontab << 'EOF'
0 2 * * * root cd /root/cediapp && docker-compose exec -T postgres pg_dump -U postgres cediapp_prod > /backups/backup_$(date +\%Y\%m\%d).sql
EOF
```

## Pricing

- **Droplet (Basic)**: $4-6/month (1 GB RAM)
- **Droplet (Standard)**: $12-24/month (2-4 GB RAM) - Recommended
- **Database Backup**: $1/month
- **Floating IP**: Free
- **Monitoring**: Free
- **SSL**: Free (Let's Encrypt)
- **Total**: ~$15-30/month

## Update & Maintenance

### Pull Latest Code

```bash
cd /root/cediapp
git pull origin main
docker-compose pull
docker-compose up -d
```

### Monitor Resource Usage

```bash
# SSH into Droplet
ssh root@your_droplet_ip

# View CPU/Memory
free -h
df -h
top

# Docker stats
docker stats
```

## Troubleshooting

### Port Already in Use

```bash
lsof -i :80
lsof -i :443
lsof -i :5000
lsof -i :3000
```

### Restart Services

```bash
cd /root/cediapp
docker-compose restart
```

### Check Connectivity

```bash
# Backend health
curl https://api.yourdomain.com/health

# Frontend
curl https://yourdomain.com
```

## Success Indicators

✅ App Platform or Droplet running
✅ Domain pointing to server
✅ SSL certificate valid
✅ Frontend accessible at yourdomain.com
✅ API accessible at api.yourdomain.com
✅ Database connected
✅ Logs showing normal operation
