# Heroku Deployment Guide

## Prerequisites
- Heroku Account (https://www.heroku.com)
- Heroku CLI installed
- Git configured

## Step 1: Install Heroku CLI

```bash
# Mac
brew tap heroku/brew && brew install heroku

# Ubuntu/Debian
curl https://cli-assets.heroku.com/install-ubuntu.sh | sh

# Windows
# Download from https://cli-assets.heroku.com/heroku-x64.exe

# Verify
heroku --version
```

## Step 2: Login to Heroku

```bash
heroku login
# Opens browser for authentication
```

## Step 3: Create Heroku Apps

```bash
# Backend app
heroku create cediapp-backend --buildpack heroku/nodejs

# Frontend app
heroku create cediapp-frontend --buildpack heroku/nodejs
```

## Step 4: Add PostgreSQL Database

```bash
# Add Heroku Postgres to backend app
heroku addons:create heroku-postgresql:hobby-dev --app cediapp-backend

# Get connection string
heroku config --app cediapp-backend
# Look for DATABASE_URL
```

## Step 5: Set Environment Variables

```bash
# Backend environment variables
heroku config:set NODE_ENV=production --app cediapp-backend
heroku config:set CLAUDE_API_KEY=your_claude_key --app cediapp-backend
heroku config:set CLAUDE_MODEL=claude-3-sonnet-20240229 --app cediapp-backend
heroku config:set MANUS_API_KEY=your_manus_key --app cediapp-backend
heroku config:set MANUS_API_URL=https://api.manus.io --app cediapp-backend
heroku config:set JWT_SECRET=$(openssl rand -base64 32) --app cediapp-backend

# Frontend environment variables
heroku config:set REACT_APP_API_URL=https://cediapp-backend.herokuapp.com/api --app cediapp-frontend
```

## Step 6: Deploy Backend

### Create Procfile for Backend

```bash
cat > backend/Procfile << 'EOF'
web: npm start
release: node -e "require('pg').Client.prototype.query.call(new (require('pg').Client)(), require('fs').readFileSync('./src/database/schema.sql', 'utf8'), (e)=> process.exit(e ? 1 : 0))"
EOF
```

### Push to Heroku

```bash
cd backend

# Add Heroku remote
heroku git:remote -a cediapp-backend

# Deploy
git push heroku main

# View logs
heroku logs --tail --app cediapp-backend
```

## Step 7: Deploy Frontend

### Create server.js for Frontend Static Serving

```bash
cat > frontend/server.js << 'EOF'
const express = require('express');
const path = require('path');
const app = express();

const PORT = process.env.PORT || 3000;

// Serve static files from build directory
app.use(express.static(path.join(__dirname, 'build')));

// Catch-all handler for SPA
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF
```

### Update Frontend package.json

```bash
# Add to scripts section:
"start": "node server.js",
"heroku-postbuild": "npm run build"
```

### Add server dependency

```bash
cd frontend
npm install express
```

### Deploy Frontend

```bash
# Add Heroku remote
heroku git:remote -a cediapp-frontend

# Deploy
git push heroku main

# View logs
heroku logs --tail --app cediapp-frontend
```

## Step 8: Database Migrations

```bash
# Connect to database
heroku pg:psql --app cediapp-backend

# Run schema (paste contents of backend/src/database/schema.sql)
# Or use:
heroku pg:psql --app cediapp-backend < backend/src/database/schema.sql
```

## Step 9: Custom Domain (Optional)

```bash
# Add domain
heroku domains:add yourdomain.com --app cediapp-backend
heroku domains:add yourdomain.com --app cediapp-frontend

# Update DNS records at your registrar:
# Type: CNAME
# Name: yourdomain.com
# Value: cediapp-backend.herokuapp.com (for backend)
```

## Monitoring

### View Logs

```bash
# Real-time logs
heroku logs --tail --app cediapp-backend

# Last 100 lines
heroku logs --num 100 --app cediapp-backend
```

### App Status

```bash
# Restart app
heroku restart --app cediapp-backend

# Dyno status
heroku ps --app cediapp-backend

# Metrics
heroku metrics --app cediapp-backend
```

### Database

```bash
# Database info
heroku pg:info --app cediapp-backend

# Connect to database
heroku pg:psql --app cediapp-backend

# Backup
heroku pg:backups:capture --app cediapp-backend

# List backups
heroku pg:backups --app cediapp-backend
```

## Maintenance

### Update Application

```bash
# Backend
cd backend
git push heroku main

# Frontend
cd frontend
git push heroku main
```

### Scaling

```bash
# Scale dynos (paid feature)
heroku ps:scale web=2 --app cediapp-backend

# Check current scaling
heroku ps --app cediapp-backend
```

## Cost

- **Hobby Dyno (Free)**: Sleeps after 30 min inactivity
- **Standard Dyno**: $7/month per app
- **PostgreSQL Hobby**: $9/month
- **Total**: $23/month (2 apps + database)

## Troubleshooting

### App Crashes

```bash
# Check logs
heroku logs --tail --app cediapp-backend

# Restart
heroku restart --app cediapp-backend
```

### Database Connection Issues

```bash
# Check DATABASE_URL
heroku config --app cediapp-backend

# Test connection
heroku pg:psql --app cediapp-backend
```

### Build Failures

```bash
# Check buildpack
heroku buildpacks --app cediapp-backend

# View build logs
heroku logs --tail --app cediapp-backend
```

## Success Indicators

✅ Both apps deployed successfully
✅ Database connected
✅ Environment variables set
✅ Logs showing no errors
✅ Frontend accessible
✅ API endpoints responding
✅ Database migrations complete
