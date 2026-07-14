#!/bin/bash

# Heroku Deployment Script
# Automates deployment to Heroku

set -e

echo "🚀 CEDI App - Heroku Deployment Script"
echo "======================================="
echo ""

# Check if Heroku CLI is installed
if ! command -v heroku &> /dev/null; then
    echo "❌ Heroku CLI not found. Installing..."
    curl https://cli-assets.heroku.com/install.sh | sh
fi

# Check if logged in
if ! heroku auth:whoami > /dev/null 2>&1; then
    echo "📝 Logging in to Heroku..."
    heroku login
fi

echo ""
read -p "Enter app name for backend (e.g., cediapp-backend): " BACKEND_APP
read -p "Enter app name for frontend (e.g., cediapp-frontend): " FRONTEND_APP
read -p "Enter Claude API Key: " CLAUDE_API_KEY
read -p "Enter Manus API Key: " MANUS_API_KEY

echo ""
echo "Creating Heroku apps..."

# Create backend app
echo "Creating backend app: $BACKEND_APP"
heroku create $BACKEND_APP --buildpack heroku/nodejs || true

# Create frontend app
echo "Creating frontend app: $FRONTEND_APP"
heroku create $FRONTEND_APP --buildpack heroku/nodejs || true

echo ""
echo "Adding PostgreSQL database..."
heroku addons:create heroku-postgresql:hobby-dev --app $BACKEND_APP || true

echo ""
echo "Setting environment variables..."

# Backend env vars
heroku config:set NODE_ENV=production --app $BACKEND_APP
heroku config:set CLAUDE_API_KEY=$CLAUDE_API_KEY --app $BACKEND_APP
heroku config:set MANUS_API_KEY=$MANUS_API_KEY --app $BACKEND_APP
heroku config:set JWT_SECRET=$(openssl rand -base64 32) --app $BACKEND_APP

# Frontend env vars
heroku config:set REACT_APP_API_URL=https://$BACKEND_APP.herokuapp.com/api --app $FRONTEND_APP

echo ""
echo "📦 Deploying backend..."
cd backend
heroku git:remote -a $BACKEND_APP
git push heroku main
cd ..

echo ""
echo "📦 Deploying frontend..."
cd frontend
heroku git:remote -a $FRONTEND_APP
git push heroku main
cd ..

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Access your apps:"
echo "  Backend: https://$BACKEND_APP.herokuapp.com/api"
echo "  Frontend: https://$FRONTEND_APP.herokuapp.com"
echo ""
echo "Useful commands:"
echo "  View logs: heroku logs --tail --app $BACKEND_APP"
echo "  Connect to database: heroku pg:psql --app $BACKEND_APP"
echo "  Restart app: heroku restart --app $BACKEND_APP"
echo ""
