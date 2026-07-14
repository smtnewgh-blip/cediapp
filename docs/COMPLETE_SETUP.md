# Complete Setup & Deployment Playbook

## Phase 1: Local Testing (15 minutes)

### Step 1: Prerequisites Check

```bash
# Check Docker installation
docker --version
# Should be 20.10+

# Check Docker Compose
docker-compose --version
# Should be 2.0+

# Check Git
git --version
```

### Step 2: Clone and Setup

```bash
# Clone repository
git clone https://github.com/smtnewgh-blip/cediapp.git
cd cediapp

# Create environment file
cp backend/.env.example .env

# Edit .env with test keys (you can use dummy keys for testing)
cat >> .env << 'EOF'

# Add these for testing
CLAUDE_API_KEY=sk-test-key-123
MANUS_API_KEY=test-manus-key
JWT_SECRET=test-jwt-secret-do-not-use-in-production
EOF
```

### Step 3: Start Local Environment

```bash
# Pull latest images
docker-compose pull

# Start all services
docker-compose up -d

# Wait for services to be healthy (30 seconds)
sleep 30

# Check status
docker-compose ps
```

### Step 4: Verify Services

```bash
# Test backend health
curl http://localhost:5000/health
# Response: {"status": "ok", "timestamp": "..."}

# Test database
docker-compose exec postgres psql -U postgres -d cediapp -c "SELECT version();"

# Check logs
docker-compose logs backend
docker-compose logs frontend
```

### Step 5: Access Applications

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000/api
- **API Documentation**: See `docs/API.md`

### Step 6: Test Full Flow

```bash
# Test Registration
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'

# Test Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Step 7: Stop Local Environment

```bash
# Stop all services
docker-compose down

# Remove volumes (reset database)
docker-compose down -v
```

---

## Phase 2: Production Deployment (30-45 minutes)

### Choose Your Platform:

### **Option A: DigitalOcean Droplet (Recommended for beginners)**

```bash
# 1. Create Droplet on DigitalOcean
# - Size: Basic $6/month (1GB RAM)
# - OS: Ubuntu 22.04
# - Enable monitoring

# 2. SSH into your Droplet
ssh root@YOUR_DROPLET_IP

# 3. Run automated setup
curl -O https://raw.githubusercontent.com/smtnewgh-blip/cediapp/main/scripts/setup-production.sh
chmod +x setup-production.sh
./setup-production.sh

# 4. Follow prompts and enter:
# - Your domain name
# - Claude API key
# - Manus API key
# - Database password

# 5. Done! Your app is live
```

### **Option B: Heroku (Simplest, but pricier)**

```bash
# 1. Install Heroku CLI
curl https://cli-assets.heroku.com/install.sh | sh

# 2. Login
heroku login

# 3. Run deployment script
chmod +x scripts/deploy-heroku.sh
./scripts/deploy-heroku.sh

# 4. Open your app
heroku open --app cediapp-frontend
```

### **Option C: AWS ECS/Fargate (Most scalable)**

```bash
# 1. Configure AWS CLI
aws configure

# 2. Run AWS deployment script
chmod +x scripts/deploy-aws.sh
./scripts/deploy-aws.sh

# 3. Follow prompts for ECR, RDS, ECS setup
```

---

## Phase 3: CI/CD Automation (Already Configured!)

### GitHub Actions Pipeline (Automatic)

Your `.github/workflows/ci-cd.yml` automatically:

✅ **On Every Push:**
- Runs backend tests
- Runs frontend build
- Builds Docker images
- Runs security scans

✅ **On Main Branch Push:**
- Pushes images to registry
- Deploys to production
- Runs smoke tests
- Sends deployment notifications

### Monitor CI/CD Pipeline

```bash
# Go to your repository
https://github.com/smtnewgh-blip/cediapp/actions

# Watch builds in real-time
# Each commit triggers automated tests and deployment
```

### Setup Required Secrets

Go to: https://github.com/smtnewgh-blip/cediapp/settings/secrets/actions

Add these secrets:

```
DOCKER_REGISTRY_URL = docker.io
DOCKER_USERNAME = your-username
DOCKER_PASSWORD = your-docker-token

# For Heroku deployment
HEROKU_API_KEY = your-heroku-api-key
HEROKU_EMAIL = your-email@example.com

# For AWS deployment
AWS_ACCESS_KEY_ID = your-access-key
AWS_SECRET_ACCESS_KEY = your-secret-key
AWS_REGION = us-east-1
```

---

## Phase 4: Monitoring & Logging

### Real-Time Logs

```bash
# Production server logs
ssh root@your-server-ip
cd /root/cediapp
docker-compose logs -f backend

# Or use centralized logging:
# Datadog: https://www.datadoghq.com
# New Relic: https://newrelic.com
# Cloudwatch (AWS): https://aws.amazon.com/cloudwatch
```

### Setup Monitoring Dashboard

#### Option 1: Prometheus + Grafana

```bash
# Create monitoring stack
cd /root/cediapp

# Add to docker-compose.yml:
docker-compose -f docker-compose.monitoring.yml up -d

# Access Grafana
# http://your-server:3001
# Default: admin/admin
```

#### Option 2: Datadog

```bash
# Install Datadog agent
DD_AGENT_MAJOR_VERSION=7 \
DD_API_KEY=your-datadog-key \
DD_SITE="datadoghq.com" \
bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# View your dashboard
# https://app.datadoghq.com
```

### Health Checks

```bash
# Backend health
curl https://yourdomain.com/api/health

# Database health
docker-compose exec postgres pg_isready -U postgres

# Full system status
watch -n 1 'docker stats --no-stream'
```

### Alerts & Notifications

```bash
# Setup alerts in Datadog for:
# - High CPU usage (>80%)
# - High memory usage (>80%)
# - Database connection failures
# - API response time >2s
# - Error rate >1%

# Send alerts to:
# - Slack: #cediapp-alerts
# - Email: ops@yourdomain.com
# - PagerDuty: For critical issues
```

---

## Phase 5: Database Backups & Recovery

### Automated Backups

```bash
# SSH to production server
ssh root@your-server-ip
cd /root/cediapp

# Create backup script
cat > backup-db.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backups/cediapp"
mkdir -p $BACKUP_DIR

# Backup database
docker-compose exec -T postgres pg_dump -U postgres cediapp > $BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql

# Cleanup old backups (keep last 7 days)
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete

# Optional: Upload to S3
# aws s3 sync $BACKUP_DIR s3://your-backup-bucket/cediapp-db/
EOF

chmod +x backup-db.sh

# Schedule daily backups at 2 AM
echo "0 2 * * * /root/cediapp/backup-db.sh" | crontab -
```

### Restore from Backup

```bash
# List available backups
ls -la /backups/cediapp/

# Restore specific backup
cat /backups/cediapp/backup_20240714_020000.sql | docker-compose exec -T postgres psql -U postgres

# Verify restore
docker-compose exec postgres psql -U postgres -c "\dt"
```

---

## Phase 6: Scaling & Performance

### Load Testing

```bash
# Install k6 (load testing tool)
choco install k6  # Windows
brew install k6   # Mac

# Create load test
cat > load-test.js << 'EOF'
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 100 },
    { duration: '2m', target: 0 },
  ],
};

export default function () {
  let response = http.get('https://yourdomain.com');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
}
EOF

# Run load test
k6 run load-test.js
```

### Auto-Scaling Configuration

```bash
# For DigitalOcean App Platform:
# - Set CPU/Memory limits per service
# - Enable auto-scaling based on metrics
# - Set min/max replicas

# For Kubernetes:
kubectl apply -f k8s/hpa.yaml  # Horizontal Pod Autoscaler

# For AWS ECS:
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name cediapp-asg \
  --policy-name cediapp-scale-up \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration file://scaling-policy.json
```

---

## Phase 7: Security Hardening

### SSL/TLS Configuration

```bash
# Already configured with Let's Encrypt
# Verify certificate
openssl s_client -connect yourdomain.com:443

# Check expiration
echo | openssl s_client -servername yourdomain.com -connect yourdomain.com:443 2>/dev/null | openssl x509 -noout -dates
```

### Security Scanning

```bash
# Scan for vulnerabilities
trivy image your-username/cediapp-backend:latest
trivy image your-username/cediapp-frontend:latest

# Check dependencies
cd backend && npm audit
cd ../frontend && npm audit

# Fix vulnerabilities
npm audit fix
```

### Environment Variables Security

```bash
# Never commit .env files
echo ".env" >> .gitignore
echo ".env.*.local" >> .gitignore

# Use GitHub Secrets instead
# https://github.com/smtnewgh-blip/cediapp/settings/secrets

# For production, use:
# - AWS Secrets Manager
# - Kubernetes Secrets
# - HashiCorp Vault
```

### Database Security

```bash
# Change default PostgreSQL password
docker-compose exec postgres psql -U postgres -c "ALTER USER postgres PASSWORD 'new_secure_password';"

# Enable SSL for database connections
# Configure pg_hba.conf for IP whitelisting

# Regular security updates
docker-compose pull postgres
docker-compose up -d
```

---

## Phase 8: Maintenance Checklist

### Weekly Tasks
- [ ] Check logs for errors
- [ ] Review performance metrics
- [ ] Test backup restoration
- [ ] Check disk space usage

### Monthly Tasks
- [ ] Update dependencies
  ```bash
  cd backend && npm update
  cd ../frontend && npm update
  ```
- [ ] Security audit
  ```bash
  npm audit
  trivy image your-image:latest
  ```
- [ ] Review and rotate secrets
- [ ] Test disaster recovery plan

### Quarterly Tasks
- [ ] Load testing
- [ ] Security penetration test
- [ ] Architecture review
- [ ] Cost optimization review

### Annual Tasks
- [ ] Major version upgrades
- [ ] Compliance audit
- [ ] Disaster recovery drill
- [ ] Technology stack review

---

## Quick Reference Commands

```bash
# Local Development
docker-compose up -d          # Start all services
docker-compose down           # Stop all services
docker-compose logs -f        # View all logs

# Production (SSH into server)
docker-compose ps             # Check service status
docker-compose restart        # Restart services
docker-compose pull           # Update images
docker-compose up -d          # Start services

# Monitoring
docker stats                  # View resource usage
dfree -h                       # Check disk space
htop                          # System resources

# Database
docker-compose exec postgres psql -U postgres
backup-db.sh                  # Run backup

# Logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs postgres
```

---

## Troubleshooting Guide

### Services Won't Start
```bash
# Check Docker daemon
sudo systemctl status docker

# View detailed error logs
docker-compose logs

# Restart Docker
sudo systemctl restart docker
```

### High Memory Usage
```bash
# Check container memory
docker stats

# Reduce memory in docker-compose.yml
mem_limit: 512m

# Restart services
docker-compose restart
```

### Database Connection Errors
```bash
# Check if postgres is healthy
docker-compose exec postgres pg_isready

# Rebuild database
docker-compose down
rm -rf postgres_data/
docker-compose up -d postgres
```

### SSL Certificate Issues
```bash
# Check certificate expiration
openssl x509 -in /etc/letsencrypt/live/yourdomain.com/cert.pem -noout -dates

# Renew certificate
sudo certbot renew --force-renewal
```

---

## Support & Resources

- **Documentation**: https://github.com/smtnewgh-blip/cediapp/docs
- **Issues**: https://github.com/smtnewgh-blip/cediapp/issues
- **Discussions**: https://github.com/smtnewgh-blip/cediapp/discussions
- **Docker Docs**: https://docs.docker.com
- **GitHub Actions**: https://docs.github.com/en/actions
- **Claude AI**: https://claude.ai
- **Manus Automation**: https://manus.io

---

**You're now ready to manage your CEDI App in production! 🚀**
