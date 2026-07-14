# AWS ECS Fargate Deployment Guide

## Prerequisites
- AWS Account
- AWS CLI configured
- Docker images pushed to Amazon ECR

## Step 1: Create ECR Repository

```bash
# Create repo for backend
aws ecr create-repository --repository-name cediapp-backend --region us-east-1

# Create repo for frontend
aws ecr create-repository --repository-name cediapp-frontend --region us-east-1

# Get login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Build and push backend
docker build -t cediapp-backend:latest backend/
docker tag cediapp-backend:latest YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/cediapp-backend:latest
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/cediapp-backend:latest

# Build and push frontend
docker build -t cediapp-frontend:latest frontend/
docker tag cediapp-frontend:latest YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/cediapp-frontend:latest
docker push YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/cediapp-frontend:latest
```

## Step 2: Create RDS PostgreSQL Database

```bash
aws rds create-db-instance \
  --db-instance-identifier cediapp-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username postgres \
  --master-user-password YourSecurePassword \
  --allocated-storage 20 \
  --region us-east-1
```

## Step 3: Create ECS Cluster

```bash
aws ecs create-cluster --cluster-name cediapp-cluster --region us-east-1
```

## Step 4: Create CloudWatch Log Groups

```bash
aws logs create-log-group --log-group-name /ecs/cediapp-backend --region us-east-1
aws logs create-log-group --log-group-name /ecs/cediapp-frontend --region us-east-1
```

## Step 5: Create Task Definition

Create `ecs-task-definition.json`:

```json
{
  "family": "cediapp-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "cediapp-backend",
      "image": "YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/cediapp-backend:latest",
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        },
        {
          "name": "DB_HOST",
          "value": "your-rds-endpoint.amazonaws.com"
        },
        {
          "name": "DB_NAME",
          "value": "cediapp"
        },
        {
          "name": "DB_USER",
          "value": "postgres"
        },
        {
          "name": "CLAUDE_API_KEY",
          "value": "your_api_key"
        },
        {
          "name": "MANUS_API_KEY",
          "value": "your_manus_key"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/cediapp-backend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    },
    {
      "name": "cediapp-frontend",
      "image": "YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/cediapp-frontend:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "REACT_APP_API_URL",
          "value": "http://your-backend-alb.amazonaws.com/api"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/cediapp-frontend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

Register the task definition:

```bash
aws ecs register-task-definition \
  --cli-input-json file://ecs-task-definition.json \
  --region us-east-1
```

## Step 6: Create ECS Service

```bash
aws ecs create-service \
  --cluster cediapp-cluster \
  --service-name cediapp-service \
  --task-definition cediapp-task \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxxxx,subnet-xxxxx],securityGroups=[sg-xxxxx],assignPublicIp=ENABLED}" \
  --region us-east-1
```

## Step 7: Create Application Load Balancer

```bash
# Create ALB
aws elbv2 create-load-balancer \
  --name cediapp-alb \
  --subnets subnet-xxxxx subnet-xxxxx \
  --security-groups sg-xxxxx \
  --region us-east-1

# Create target groups
aws elbv2 create-target-group \
  --name cediapp-backend-tg \
  --protocol HTTP \
  --port 5000 \
  --vpc-id vpc-xxxxx \
  --region us-east-1

aws elbv2 create-target-group \
  --name cediapp-frontend-tg \
  --protocol HTTP \
  --port 3000 \
  --vpc-id vpc-xxxxx \
  --region us-east-1
```

## Monitoring

```bash
# View service status
aws ecs describe-services \
  --cluster cediapp-cluster \
  --services cediapp-service \
  --region us-east-1

# View tasks
aws ecs list-tasks \
  --cluster cediapp-cluster \
  --region us-east-1

# View logs
aws logs tail /ecs/cediapp-backend --follow --region us-east-1
```

## Cost Optimization

- Use Fargate Spot instances (70% cheaper)
- Set up auto-scaling based on CPU/memory
- Use CloudFront for static content
- Enable RDS automatic backups
