#!/bin/bash

# Vercel Deployment Script
# Automates deployment to Vercel for both frontend and backend

set -e

echo "🚀 CEDI App - Vercel Deployment Script"
echo "========================================"
echo ""

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "📝 Installing Vercel CLI..."
    npm install -g vercel
fi

# Login to Vercel
echo "🔑 Logging in to Vercel..."
vercel login

echo ""
echo "Deployment Options:"
echo "  1) Deploy Frontend only"
echo "  2) Deploy Backend only"
echo "  3) Deploy Both (Frontend + Backend)"
echo ""
read -p "Select option (1-3): " DEPLOY_OPTION

echo ""
read -p "Environment: Production (prod) or Preview (default: prod)? " ENVIRONMENT
ENVIRONMENT=${ENVIRONMENT:-prod}

if [[ $ENVIRONMENT == "prod" ]]; then
    VERCEL_FLAG="--prod"
else
    VERCEL_FLAG=""
fi

case $DEPLOY_OPTION in
    1)
        echo ""
        echo "👩‍💻 Deploying Frontend..."
        cd frontend
        
        # Verify package.json exists
        if [ ! -f package.json ]; then
            echo "❌ Error: package.json not found in frontend directory"
            exit 1
        fi
        
        # Install dependencies
        echo "💾 Installing dependencies..."
        npm install
        
        # Build
        echo "🔨 Building frontend..."
        npm run build
        
        # Deploy to Vercel
        echo "🚀 Deploying to Vercel..."
        vercel $VERCEL_FLAG --confirm
        
        FRONTEND_URL=$(vercel ls --json | jq -r '.[0].url')
        echo ""
        echo "✅ Frontend deployed successfully!"
        echo "URL: https://$FRONTEND_URL"
        ;;
        
    2)
        echo ""
        echo "👩‍💻 Deploying Backend..."
        cd backend
        
        # Verify package.json exists
        if [ ! -f package.json ]; then
            echo "❌ Error: package.json not found in backend directory"
            exit 1
        fi
        
        # Check for vercel.json
        if [ ! -f vercel.json ]; then
            echo "⚠️  Creating vercel.json for backend..."
            cat > vercel.json << 'EOF'
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
  ]
}
EOF
        fi
        
        # Install dependencies
        echo "💾 Installing dependencies..."
        npm install
        
        # Deploy to Vercel
        echo "🚀 Deploying to Vercel..."
        vercel $VERCEL_FLAG --confirm
        
        BACKEND_URL=$(vercel ls --json | jq -r '.[0].url')
        echo ""
        echo "✅ Backend deployed successfully!"
        echo "URL: https://$BACKEND_URL"
        ;;
        
    3)
        echo ""
        echo "👩‍💻 Deploying Frontend..."
        cd frontend
        
        # Install dependencies
        echo "💾 Installing dependencies..."
        npm install
        
        # Build
        echo "🔨 Building frontend..."
        npm run build
        
        # Deploy to Vercel
        echo "🚀 Deploying to Vercel..."
        vercel $VERCEL_FLAG --confirm
        
        FRONTEND_URL=$(vercel ls --json | jq -r '.[0].url')
        
        echo ""
        echo "👩‍💻 Deploying Backend..."
        cd ../backend
        
        # Check for vercel.json
        if [ ! -f vercel.json ]; then
            echo "⚠️  Creating vercel.json for backend..."
            cat > vercel.json << 'EOF'
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
  ]
}
EOF
        fi
        
        # Install dependencies
        echo "💾 Installing dependencies..."
        npm install
        
        # Deploy to Vercel
        echo "🚀 Deploying to Vercel..."
        vercel $VERCEL_FLAG --confirm
        
        BACKEND_URL=$(vercel ls --json | jq -r '.[0].url')
        
        echo ""
        echo "✅ Both deployments successful!"
        echo ""
        echo "Frontend: https://$FRONTEND_URL"
        echo "Backend: https://$BACKEND_URL"
        echo ""
        echo "📧 Next steps:"
        echo "  1. Add REACT_APP_API_URL=$BACKEND_URL to frontend environment"
        echo "  2. Add CORS_ORIGIN=$FRONTEND_URL to backend environment"
        echo "  3. Test API connectivity"
        ;;
        
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "Deployment complete!"
echo ""
echo "View your deployment:"
echo "  vercel ls"
echo ""
echo "View logs:"
echo "  vercel logs --tail"
echo ""
