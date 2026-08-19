#!/bin/bash

# Deploy Todo App to GitHub Pages
# Usage: bash deploy-github-pages.sh

set -e

echo "🚀 Deploying Todo App to GitHub Pages..."
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Step 1: Checking GitHub Pages configuration...${NC}"

# Check if .github/workflows exists
if [ ! -d ".github/workflows" ]; then
    echo "📁 Creating .github/workflows directory..."
    mkdir -p .github/workflows
fi

echo -e "${BLUE}Step 2: Creating deployment workflow...${NC}"

# Create GitHub Actions workflow
cat > .github/workflows/deploy-todo.yml << 'EOF'
name: Deploy Todo App to GitHub Pages

on:
  push:
    branches:
      - main
    paths:
      - 'todo-app/**'
      - '.github/workflows/deploy-todo.yml'

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pages: write
      id-token: write
    
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Setup Pages
        uses: actions/configure-pages@v3
      
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v2
        with:
          path: 'todo-app'
      
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v2
EOF

echo -e "${GREEN}✅ Workflow created!${NC}"
echo ""

echo -e "${BLUE}Step 3: Creating package.json...${NC}"

# Create package.json if it doesn't exist
if [ ! -f "package.json" ]; then
    cat > package.json << 'EOF'
{
  "name": "cediapp",
  "version": "1.0.0",
  "description": "CEDI App - Complete Development Environment",
  "homepage": "https://smtnewgh-blip.github.io/cediapp/todo-app",
  "repository": {
    "type": "git",
    "url": "https://github.com/smtnewgh-blip/cediapp"
  },
  "author": "Shafiq Mukaila",
  "license": "MIT",
  "scripts": {
    "serve": "python -m http.server 8000",
    "deploy": "bash scripts/deploy-github-pages.sh"
  }
}
EOF
    echo -e "${GREEN}✅ package.json created!${NC}"
fi

echo ""
echo -e "${BLUE}Step 4: Verifying todo app files...${NC}"

# Check todo app files
if [ -f "todo-app/index.html" ] && [ -f "todo-app/styles.css" ] && [ -f "todo-app/script.js" ]; then
    echo -e "${GREEN}✅ All todo app files present!${NC}"
else
    echo -e "${YELLOW}⚠️  Some todo app files missing!${NC}"
fi

echo ""
echo -e "${BLUE}Step 5: Committing changes...${NC}"

# Stage changes
git add .github/workflows/deploy-todo.yml package.json 2>/dev/null || true

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo -e "${YELLOW}ℹ️  No changes to commit${NC}"
else
    git commit -m "Add GitHub Pages deployment workflow for Todo App"
    echo -e "${GREEN}✅ Changes committed!${NC}"
fi

echo ""
echo -e "${BLUE}Step 6: Pushing to GitHub...${NC}"

# Push to main branch
git push origin main

echo ""
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Deployment Setup Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. Go to: https://github.com/smtnewgh-blip/cediapp/settings/pages"
echo "2. Under 'Build and deployment':"
echo "   - Source: GitHub Actions"
echo "   - Workflow: deploy-todo.yml"
echo "3. Click 'Save'"
echo ""

echo -e "${BLUE}🌐 Your Todo App will be available at:${NC}"
echo "   https://smtnewgh-blip.github.io/cediapp/todo-app/"
echo ""

echo -e "${BLUE}📊 Monitor deployment:${NC}"
echo "   https://github.com/smtnewgh-blip/cediapp/actions"
echo ""

echo -e "${GREEN}🎉 Happy organizing!${NC}"
