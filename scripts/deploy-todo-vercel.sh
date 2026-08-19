#!/bin/bash

# Deploy Todo App to Vercel
# Usage: bash deploy-todo-vercel.sh

set -e

echo "🚀 Deploying Todo App to Vercel..."
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Vercel CLI...${NC}"
    npm install -g vercel
fi

echo -e "${BLUE}Step 1: Logging in to Vercel...${NC}"
vercel login

echo ""
echo -e "${BLUE}Step 2: Creating vercel.json...${NC}"

# Create vercel.json for todo app
cat > todo-app/vercel.json << 'EOF'
{
  "version": 2,
  "name": "cediapp-todo",
  "public": true,
  "buildCommand": "echo 'Static site ready'",
  "outputDirectory": "./",
  "cleanUrls": true,
  "trailingSlash": false,
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ],
  "headers": [
    {
      "source": "/.*",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=3600, s-maxage=3600"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "SAMEORIGIN"
        }
      ]
    }
  ]
}
EOF

echo -e "${GREEN}✅ vercel.json created!${NC}"

echo ""
echo -e "${BLUE}Step 3: Deploying to Vercel...${NC}"

# Deploy to Vercel
cd todo-app/

echo ""
echo -e "${YELLOW}Choose deployment mode:${NC}"
echo "  1) Preview (staging)"
echo "  2) Production"
echo ""
read -p "Select (1 or 2): " DEPLOY_MODE

if [ "$DEPLOY_MODE" = "2" ]; then
    echo -e "${BLUE}Deploying to PRODUCTION...${NC}"
    vercel --prod
    DEPLOY_TYPE="Production"
else
    echo -e "${BLUE}Deploying to PREVIEW...${NC}"
    vercel
    DEPLOY_TYPE="Preview"
fi

cd ..

echo ""
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Vercel Deployment Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}📋 Deployment Info:${NC}"
echo "   Type: $DEPLOY_TYPE"
echo ""

echo -e "${BLUE}🌐 Access your Todo App:${NC}"
echo "   Visit: https://cediapp-todo.vercel.app"
echo ""

echo -e "${BLUE}📊 Manage deployment:${NC}"
echo "   Dashboard: https://vercel.com/dashboard"
echo ""

echo -e "${BLUE}🔗 Environment variables:${NC}"
echo "   Settings > Environment Variables"
echo ""

echo -e "${GREEN}🎉 Your Todo App is live!${NC}"
