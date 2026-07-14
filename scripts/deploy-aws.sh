#!/bin/bash

# AWS ECS Deployment Script
# Builds and pushes to AWS ECR, deploys to ECS

set -e

echo "🚀 CEDI App - AWS ECS Deployment Script"
echo "========================================"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install it first."
    exit 1
fi

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${AWS_REGION:-us-east-1}
ECR_REGISTRY=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo "AWS Account: $AWS_ACCOUNT_ID"
echo "AWS Region: $AWS_REGION"
echo "ECR Registry: $ECR_REGISTRY"
echo ""

read -p "Enter image version (default: latest): " IMAGE_VERSION
IMAGE_VERSION=${IMAGE_VERSION:-latest}

echo ""
echo "📝 Building Docker images..."

# Backend
echo "Building backend..."
docker build -t $ECR_REGISTRY/cediapp-backend:$IMAGE_VERSION backend/
docker tag $ECR_REGISTRY/cediapp-backend:$IMAGE_VERSION $ECR_REGISTRY/cediapp-backend:latest

# Frontend
echo "Building frontend..."
docker build -t $ECR_REGISTRY/cediapp-frontend:$IMAGE_VERSION frontend/
docker tag $ECR_REGISTRY/cediapp-frontend:$IMAGE_VERSION $ECR_REGISTRY/cediapp-frontend:latest

echo ""
echo "📦 Creating ECR repositories..."

# Create repositories
aws ecr create-repository \
    --repository-name cediapp-backend \
    --region $AWS_REGION || true

aws ecr create-repository \
    --repository-name cediapp-frontend \
    --region $AWS_REGION || true

echo ""
echo "🔐 Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

echo ""
echo "⬆️  Pushing images to ECR..."

# Push backend
echo "Pushing backend..."
docker push $ECR_REGISTRY/cediapp-backend:$IMAGE_VERSION
docker push $ECR_REGISTRY/cediapp-backend:latest

# Push frontend
echo "Pushing frontend..."
docker push $ECR_REGISTRY/cediapp-frontend:$IMAGE_VERSION
docker push $ECR_REGISTRY/cediapp-frontend:latest

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Images pushed to ECR:"
echo "  Backend: $ECR_REGISTRY/cediapp-backend:$IMAGE_VERSION"
echo "  Frontend: $ECR_REGISTRY/cediapp-frontend:$IMAGE_VERSION"
echo ""
echo "Next steps:"
echo "  1. Update ECS task definitions with new image URIs"
echo "  2. Update ECS services to use new task definition"
echo "  3. Monitor deployment in AWS Console"
echo ""
echo "See docs/AWS_DEPLOYMENT.md for complete setup guide"
echo ""
