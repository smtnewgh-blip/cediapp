# CEDI App - Quick Reference Guide

## 🚀 Quick Start Commands

### Local Development
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild images
docker-compose up -d --build
```

### Access Applications
```
Frontend:     http://localhost:3000
Backend API:  http://localhost:5000/api
Database:     localhost:5432
Grafana:      http://localhost:3001 (admin/admin)
Prometheus:   http://localhost:9090
```

### Database Management
```bash
# Connect to database
docker-compose exec postgres psql -U postgres

# Backup database
docker-compose exec postgres pg_dump -U postgres cediapp > backup.sql

# Restore database
docker-compose exec -T postgres psql -U postgres cediapp < backup.sql
```

### Monitoring
```bash
# Check service status
docker-compose ps

# View resource usage
docker stats

# Health check
bash scripts/health-check-production.sh
```

### Deployment
```bash
# Complete setup (all phases)
bash scripts/complete-setup.sh

# Production VPS setup
sudo bash scripts/setup-production.sh

# Heroku deployment
bash scripts/deploy-heroku.sh

# AWS deployment
bash scripts/deploy-aws.sh
```

### Maintenance
```bash
# Backup database
bash scripts/backup-db.sh

# Trigger CI/CD pipeline
bash scripts/trigger-cicd.sh

# Update dependencies
cd backend && npm update && cd ..
cd frontend && npm update && cd ..

# Security audit
cd backend && npm audit && cd ..
cd frontend && npm audit && cd ..
```

## 📋 Environment Variables

### Required (Production)
```
NODE_ENV=production
CLAUDE_API_KEY=your_key
MANUS_API_KEY=your_key
JWT_SECRET=your_secret
DB_PASSWORD=secure_password
CORS_ORIGIN=https://yourdomain.com
```

### Optional
```
PORT=5000
DB_HOST=postgres
DB_PORT=5432
DB_NAME=cediapp
DB_USER=postgres
CLAUDE_MODEL=claude-3-sonnet-20240229
MANUS_API_URL=https://api.manus.io
JWT_EXPIRES_IN=7d
```

## 🔗 Important Links

- **Repository**: https://github.com/smtnewgh-blip/cediapp
- **API Documentation**: `/docs/API.md`
- **Complete Setup**: `/docs/COMPLETE_SETUP.md`
- **Deployment Guide**: `/docs/DEPLOYMENT.md`
- **Contributing**: `/CONTRIBUTING.md`

## 🆘 Troubleshooting

### Services won't start
```bash
# Check Docker
sudo systemctl status docker

# View detailed logs
docker-compose logs

# Restart Docker
sudo systemctl restart docker
```

### Database connection issues
```bash
# Check postgres health
docker-compose exec postgres pg_isready

# Rebuild database
docker-compose down
rm -rf postgres_data/
docker-compose up -d
```

### High memory/CPU usage
```bash
# Check container stats
docker stats

# Limit resources in docker-compose.yml
mem_limit: 512m
cpus: '0.5'
```

### SSL certificate issues
```bash
# Check expiration
openssl x509 -in cert.pem -noout -dates

# Renew certificate
sudo certbot renew --force-renewal
```

## 📞 Support

- **Issues**: https://github.com/smtnewgh-blip/cediapp/issues
- **Discussions**: https://github.com/smtnewgh-blip/cediapp/discussions
- **Email**: support@yourdomain.com

## 📊 Monitoring Checklist

- [ ] Check service status daily
- [ ] Monitor disk usage
- [ ] Review error logs
- [ ] Verify backups run
- [ ] Check SSL certificate expiration
- [ ] Monitor response times
- [ ] Review error rates
- [ ] Check database size

## 🔐 Security Best Practices

1. **Secrets**: Never commit `.env` files
2. **Updates**: Keep dependencies up to date
3. **Passwords**: Use strong, unique passwords
4. **Backups**: Store backups securely
5. **Access**: Limit SSH/database access
6. **Monitoring**: Enable alerts and logging
7. **SSL**: Keep certificates updated
8. **Firewall**: Configure properly

## 💡 Common Tasks

### Deploy new version
```bash
git add .
git commit -m "Update"
git push origin main
# CI/CD pipeline will handle deployment
```

### Scale application
```bash
# Increase resources in docker-compose.yml
# Or use cloud platform scaling (Heroku, AWS, etc.)
```

### View live logs
```bash
ssh root@your-server-ip
cd /root/cediapp
docker-compose logs -f backend
```

### Rotate secrets
```bash
# Update in .env
# Restart services
docker-compose restart
# Update in GitHub Secrets
```
