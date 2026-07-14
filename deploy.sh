#!/bin/bash

# CEDI App - Universal Deployment Script
# Supports: Docker Compose, DigitalOcean, Heroku, AWS

set -e

echo "========================================"
echo "CEDI App - Deployment Script"
echo "========================================"
echo ""
echo "Select deployment option:"
echo "1) Docker Hub + VPS (DigitalOcean/Linode/AWS EC2)"
echo "2) DigitalOcean App Platform"
echo "3) Heroku"
echo "4) AWS ECS/Fargate"
echo "5) Docker Compose (Local Testing)"
echo ""
read -p "Enter option (1-5): " OPTION

case $OPTION in
    1)
        echo "\n🚀 Docker Hub + VPS Deployment"
        echo "=============================="
        read -p "Enter Docker Hub username: " DOCKER_USER
        read -p "Enter your domain (e.g., yourdomain.com): " DOMAIN
        read -p "Enter your VPS IP address: " VPS_IP
        
        echo "\n1. Building Docker images..."
        docker build -t $DOCKER_USER/cediapp-backend:latest backend/
        docker build -t $DOCKER_USER/cediapp-frontend:latest frontend/
        
        echo "\n2. Pushing to Docker Hub..."
        echo "Please login to Docker Hub when prompted"
        docker login
        docker push $DOCKER_USER/cediapp-backend:latest
        docker push $DOCKER_USER/cediapp-frontend:latest
        
        echo "\n3. Deployment instructions:"
        echo "   SSH into your server: ssh root@$VPS_IP"
        echo "   Then run the following commands:"
        echo ""
        echo "   # Install Docker"
        echo "   curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
        echo ""
        echo "   # Clone repository"
        echo "   git clone https://github.com/smtnewgh-blip/cediapp.git && cd cediapp"
        echo ""
        echo "   # Update docker-compose.yml with your Docker Hub username"
        echo "   sed -i 's/your-username/$DOCKER_USER/g' docker-compose.yml"
        echo ""
        echo "   # Create .env file and start services"
        echo "   cp backend/.env.example .env"
        echo "   # Edit .env with your API keys"
        echo "   docker-compose up -d"
        echo ""
        echo "   # Access at: http://$VPS_IP:3000"
        ;;
        
    2)
        echo "\n🚀 DigitalOcean App Platform Deployment"
        echo "========================================"
        echo "Please follow these steps:"
        echo ""
        echo "1. Go to https://cloud.digitalocean.com/apps"
        echo "2. Click 'Create App'"
        echo "3. Connect your GitHub repository: smtnewgh-blip/cediapp"
        echo "4. Configure services:"
        echo "   - Backend: backend/Dockerfile, Port 5000"
        echo "   - Frontend: frontend/Dockerfile, Port 3000"
        echo "5. Add PostgreSQL database"
        echo "6. Set environment variables (Claude API key, Manus key, JWT secret)"
        echo "7. Deploy!"
        echo ""
        echo "Cost: ~\$12-25/month"
        ;;
        
    3)
        echo "\n🚀 Heroku Deployment"
        echo "====================="
        echo "Please follow these steps:"
        echo ""
        echo "1. Install Heroku CLI: https://devcenter.heroku.com/articles/heroku-cli"
        echo "2. Login: heroku login"
        echo "3. Create apps:"
        echo "   heroku create cediapp-backend --buildpack heroku/nodejs"
        echo "   heroku create cediapp-frontend --buildpack heroku/nodejs"
        echo "4. Add database: heroku addons:create heroku-postgresql:hobby-dev"
        echo "5. Set environment variables"
        echo "6. Deploy:"
        echo "   cd backend && heroku git:remote -a cediapp-backend && git push heroku main"
        echo "   cd frontend && heroku git:remote -a cediapp-frontend && git push heroku main"
        echo ""
        echo "Cost: ~\$23/month (2 apps + database)"
        ;;
        
    4)
        echo "\n🚀 AWS ECS/Fargate Deployment"
        echo "=============================="
        echo "Please follow the guide: docs/AWS_DEPLOYMENT.md"
        echo ""
        echo "Quick steps:"
        echo "1. Create ECR repositories for backend and frontend"
        echo "2. Build and push Docker images"
        echo "3. Create RDS PostgreSQL database"
        echo "4. Create ECS cluster and task definitions"
        echo "5. Deploy services with ALB"
        echo ""
        echo "Cost: Variable (~\$50-200+/month)"
        ;;
        
    5)
        echo "\n🚀 Local Docker Compose Deployment"
        echo "====================================="
        echo ""
        
        # Create .env if doesn't exist
        if [ ! -f .env ]; then
            echo "Creating .env file..."
            cp backend/.env.example .env
            echo ""
            echo "⚠️  Please edit .env with your API keys:"
            echo "   CLAUDE_API_KEY"
            echo "   MANUS_API_KEY"
            echo "   JWT_SECRET"
            echo ""
            read -p "Press enter after editing .env file: "
        fi
        
        echo "Starting services with Docker Compose..."
        docker-compose pull
        docker-compose up -d
        
        echo ""
        echo "✅ Services started!"
        echo ""
        echo "Access:"
        echo "  Frontend: http://localhost:3000"
        echo "  Backend API: http://localhost:5000/api"
        echo "  Database: localhost:5432"
        echo ""
        echo "View logs:"
        echo "  docker-compose logs -f backend"
        echo "  docker-compose logs -f frontend"
        echo ""
        echo "Stop services:"
        echo "  docker-compose down"
        ;;
        
    *)
        echo "❌ Invalid option. Please select 1-5."
        exit 1
        ;;
esac

echo ""
echo "========================================"
echo "For detailed documentation, see:"
echo "  - docs/DOCKER_HUB_DEPLOY.md"
echo "  - docs/DIGITALOCEAN_DEPLOY.md"
echo "  - docs/HEROKU_DEPLOY.md"
echo "  - docs/AWS_DEPLOYMENT.md"
echo "========================================"
echo ""
