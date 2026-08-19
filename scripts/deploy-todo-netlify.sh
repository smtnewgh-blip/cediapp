#!/bin/bash

# Deploy Todo App to Netlify
# Usage: bash deploy-todo-netlify.sh

set -e

echo "🚀 Deploying Todo App to Netlify..."
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if Netlify CLI is installed
if ! command -v netlify &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Netlify CLI...${NC}"
    npm install -g netlify-cli
fi

echo -e "${BLUE}Step 1: Logging in to Netlify...${NC}"
netlify login

echo ""
echo -e "${BLUE}Step 2: Creating netlify.toml...${NC}"

# Create netlify.toml
cat > netlify.toml << 'EOF'
[build]
  publish = "todo-app"
  command = "echo 'Static site ready'"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Content-Type-Options = "nosniff"
    X-Frame-Options = "SAMEORIGIN"
    X-XSS-Protection = "1; mode=block"
    Cache-Control = "public, max-age=3600"

[[headers]]
  for = "/static/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
EOF

echo -e "${GREEN}✅ netlify.toml created!${NC}"

echo ""
echo -e "${BLUE}Step 3: Deploying to Netlify...${NC}"

echo ""
echo -e "${YELLOW}Choose deployment mode:${NC}"
echo "  1) Preview (staging)"
echo "  2) Production"
echo ""
read -p "Select (1 or 2): " DEPLOY_MODE

if [ "$DEPLOY_MODE" = "2" ]; then
    echo -e "${BLUE}Deploying to PRODUCTION...${NC}"
    netlify deploy --dir=todo-app --prod
    DEPLOY_TYPE="Production"
else
    echo -e "${BLUE}Deploying to PREVIEW...${NC}"
    netlify deploy --dir=todo-app
    DEPLOY_TYPE="Preview"
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Netlify Deployment Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}📋 Deployment Info:${NC}"
echo "   Type: $DEPLOY_TYPE"
echo ""

echo -e "${BLUE}🌐 Access your Todo App:${NC}"
echo "   Visit: https://cediapp-todo.netlify.app"
echo ""

echo -e "${BLUE}📊 Manage deployment:${NC}"
echo "   Dashboard: https://app.netlify.com"
echo ""

echo -e "${BLUE}🔗 Custom domain:${NC}"
echo "   Site settings > Domain management"
echo ""

echo -e "${GREEN}🎉 Your Todo App is live!${NC}"
