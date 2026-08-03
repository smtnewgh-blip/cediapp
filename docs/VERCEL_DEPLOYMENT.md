# Vercel Deployment Guide for CEDI App

## Prerequisites
- Vercel Account (https://vercel.com)
- Vercel CLI installed
- GitHub repository connected

## Step 1: Install Vercel CLI

```bash
# npm
npm install -g vercel

# yarn
yarn global add vercel

# pnpm
pnpm add -g vercel
```

## Step 2: Vercel Configuration Files

### Frontend (React) - vercel.json
```json
{
  "buildCommand": "npm run build",
  "devCommand": "npm start",
  "installCommand": "npm install",
  "framework": "react",
  "outputDirectory": "build",
  "git": {
    "deploymentEnabled": {
      "main": true
    }
  },
  "env": {
    "REACT_APP_API_URL": "@react_app_api_url"
  },
  "routes": [
    {
      "src": "^/(.*)",
      "dest": "/index.html"
    }
  ]
}
```

### Backend (Express) - vercel.json
```json
{
  "version": 2,
  "builds": [
    {
      "src": "src/index.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "src/index.js"
    }
  ],
  "env": {
    "NODE_ENV": "production",
    "DB_HOST": "@db_host",
    "DB_PORT": "@db_port",
    "DB_NAME": "@db_name",
    "DB_USER": "@db_user",
    "DB_PASSWORD": "@db_password",
    "CLAUDE_API_KEY": "@claude_api_key",
    "MANUS_API_KEY": "@manus_api_key",
    "JWT_SECRET": "@jwt_secret"
  }
}
```

## Step 3: Setup Express for Vercel

### Update backend/src/index.js
```javascript
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();

// Middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(express.json());

// Routes
import authRoutes from './routes/auth.js';
import aiRoutes from './routes/ai.js';
import workflowRoutes from './routes/workflow.js';

app.use('/api/auth', authRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/workflow', workflowRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: err.message });
});

// For Vercel
export default app;

// For local development
const PORT = process.env.PORT || 5000;
if (import.meta.url === `file://${process.argv[1]}`) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}
```

## Step 4: Update package.json Files

### frontend/package.json
```json
{
  "name": "cediapp-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.0.0",
    "axios": "^1.4.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": ["react-app"]
  },
  "browserslist": {
    "production": [">0.2%", "not dead", "not op_mini all"],
    "development": ["last 1 chrome version", "last 1 firefox version", "last 1 safari version"]
  },
  "devDependencies": {
    "react-scripts": "5.0.1"
  }
}
```

### backend/package.json
```json
{
  "name": "cediapp-backend",
  "version": "1.0.0",
  "type": "module",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.0.3",
    "pg": "^8.10.0",
    "axios": "^1.4.0",
    "jsonwebtoken": "^9.0.0",
    "bcryptjs": "^2.4.3"
  },
  "devDependencies": {
    "nodemon": "^2.0.22",
    "jest": "^29.5.0"
  }
}
```

## Step 5: Deploy Frontend to Vercel

```bash
# Login to Vercel
vercel login

# Deploy frontend
cd frontend
vercel --prod

# Follow prompts:
# - Link to existing project (or create new)
# - Framework: React
# - Build command: npm run build
# - Output directory: build
# - Install command: npm install
```

## Step 6: Deploy Backend to Vercel

```bash
# Deploy backend
cd ../backend
vercel --prod

# Follow prompts:
# - Link to existing project (or create new)
# - Framework: Other
# - Build command: (leave empty)
# - Root directory: ./
```

## Step 7: Configure Environment Variables

### Frontend Environment Variables

Go to Vercel Dashboard > Settings > Environment Variables

```
REACT_APP_API_URL=https://your-backend.vercel.app/api
```

### Backend Environment Variables

Go to Vercel Dashboard > Settings > Environment Variables

```
NODE_ENV=production
DB_HOST=your-db-host.supabase.co
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=your-password
CLAUDE_API_KEY=your-claude-key
MANUS_API_KEY=your-manus-key
JWT_SECRET=your-jwt-secret
CORS_ORIGIN=https://your-frontend.vercel.app
```

## Step 8: Connect PostgreSQL Database

### Option A: Supabase (Recommended for Vercel)

```bash
# 1. Go to https://supabase.com
# 2. Create new project
# 3. Copy connection string
# 4. Add to Vercel environment variables

# Connection string format:
postgres://user:password@host:5432/database
```

### Option B: Neon (PostgreSQL)

```bash
# 1. Go to https://neon.tech
# 2. Create new project
# 3. Copy connection string
# 4. Update environment variables
```

### Option C: AWS RDS

```bash
# Create RDS instance and configure security groups
# Make sure to allow Vercel IP addresses
```

## Step 9: Enable GitHub Integration

```bash
# In Vercel Dashboard:
# 1. Settings > Git Integration
# 2. Connect GitHub
# 3. Select repository
# 4. Configure deployment settings:
#    - Production branch: main
#    - Deploy on push: Enabled
```

## Step 10: Custom Domain Setup

```bash
# In Vercel Dashboard:
# 1. Settings > Domains
# 2. Add custom domain
# 3. Update DNS records:
#    - Type: CNAME
#    - Value: your-app.vercel.app
# 4. Wait for DNS propagation (5-48 hours)
```

## Verification

```bash
# Test frontend
curl https://your-frontend.vercel.app

# Test backend
curl https://your-backend.vercel.app/health

# Test API connectivity
curl https://your-backend.vercel.app/api/health
```

## CI/CD with GitHub + Vercel

Automatically deploy on push:

1. **Frontend**: Pushes to main → Vercel deploys automatically
2. **Backend**: Pushes to main → Vercel deploys automatically
3. **Database**: Runs migrations automatically
4. **Preview**: Pull requests get preview deployments

## Monitoring

### View Logs
```bash
# Real-time logs
vercel logs --tail

# Specific deployment
vercel logs [deployment-url]
```

### Performance Analytics
- Access in Vercel Dashboard > Analytics
- Monitor:
  - Response times
  - Error rates
  - Deployment frequency

## Scaling & Pricing

### Vercel Pricing Tiers
- **Hobby (Free)**: 100GB/month bandwidth
- **Pro ($20/month)**: 1TB/month bandwidth
- **Enterprise**: Custom pricing

### Total Cost
- **Frontend**: Free (Hobby) or $20/month (Pro)
- **Backend**: Free (Hobby) or $20/month (Pro)
- **Database (Supabase)**: Free or $25+/month
- **Total**: ~$25-50/month

## Optimization Tips

### Frontend Optimization
```bash
# Build optimization
npm run build

# Check bundle size
npm install -g serve
serve -s build
```

### Backend Optimization
```javascript
// Use connection pooling
import { Pool } from 'pg';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

## Troubleshooting

### Build Fails
```bash
# Check logs
vercel logs --tail

# Verify build command
npm run build

# Test locally
npm run dev
```

### Database Connection Issues
```bash
# Test connection string
psql "postgresql://user:password@host:5432/db"

# Verify environment variables in Vercel
vercel env list
```

### CORS Errors
```bash
# Update CORS_ORIGIN in backend
# Make sure frontend URL is correct
# Verify both are deployed and accessible
```

## Success Indicators

✅ Frontend deployed at: `https://your-frontend.vercel.app`
✅ Backend deployed at: `https://your-backend.vercel.app/api`
✅ Health check responding: `https://your-backend.vercel.app/health`
✅ Database connected and working
✅ GitHub integration active
✅ Automatic deployments working
✅ Custom domain configured
✅ SSL certificate valid

## Deployment Summary

| Component | Hosting | Status |
|-----------|---------|--------|
| Frontend | Vercel | ✅ Deployed |
| Backend | Vercel | ✅ Deployed |
| Database | Supabase/Neon | ✅ Connected |
| Domain | Custom | ✅ Configured |
| SSL | Automatic | ✅ Enabled |
| CI/CD | GitHub + Vercel | ✅ Active |

## Quick Deploy Commands

```bash
# One-line deployment (frontend + backend + database)
bash scripts/deploy-vercel-complete.sh

# Or choose specific deployment
bash scripts/deploy-vercel.sh
```

## Next Steps

1. Share your Vercel URLs
2. Configure custom domain
3. Setup monitoring and alerts
4. Optimize performance
5. Plan database backups
