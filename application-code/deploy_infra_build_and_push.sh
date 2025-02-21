#!/bin/bash

STACK_NAME="cdk8s-demo-stack"
TEMPLATE_FILE="aws_infra.yaml"
REPOSITORY_NAME="my-ecr-repository"
AWS_REGION="eu-north-1"
BACKEND_DIR="backend"
FRONTEND_DIR="frontend"
DATABASE_DIR="database"
CACHE_DIR="cache"

# Function to check if stack exists
stack_exists() {
    aws cloudformation describe-stacks --stack-name $STACK_NAME >/dev/null 2>&1
}

# Deploy or update the CloudFormation stack
if stack_exists; then
    echo "Updating existing stack: $STACK_NAME"
    update_output=$(aws cloudformation update-stack \
        --stack-name $STACK_NAME \
        --template-body file://$TEMPLATE_FILE \
        --capabilities CAPABILITY_NAMED_IAM 2>&1)
    
    if echo "$update_output" | grep -q "No updates are to be performed"; then
        echo "No updates are to be performed. Skipping wait."
    else
        echo "Waiting for stack update to complete..."
        aws cloudformation wait stack-update-complete --stack-name $STACK_NAME
    fi
else
    echo "Creating new stack: $STACK_NAME"
    aws cloudformation create-stack \
        --stack-name $STACK_NAME \
        --template-body file://$TEMPLATE_FILE \
        --capabilities CAPABILITY_NAMED_IAM
    
    echo "Waiting for stack creation to complete..."
    aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
fi

echo "Stack operation completed successfully!"

echo "Fetching ECR Repository URI..."
ECR_URI=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='ECRRepositoryURI'].OutputValue" --output text)
echo "ECR Repository URI: $ECR_URI"

# Authenticate Docker to AWS ECR
echo "Authenticating Docker with AWS ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI

# Build and push backend image
echo "Building and pushing backend image..."
docker build --platform linux/amd64 -t $ECR_URI:backend-latest $BACKEND_DIR

docker push $ECR_URI:backend-latest

echo "Backend image pushed successfully!"

# Build and push frontend image
echo "Building and pushing frontend image..."
docker build --platform linux/amd64 -t $ECR_URI:frontend-latest $FRONTEND_DIR

docker push $ECR_URI:frontend-latest

echo "Frontend image pushed successfully!"

# Build and push database image
echo "Building and pushing database image..."
docker build --platform linux/amd64 -t $ECR_URI:database-latest $DATABASE_DIR

docker push $ECR_URI:database-latest

echo "Database image pushed successfully!"

# Build and push cache image
echo "Building and pushing cache image..."
docker build --platform linux/amd64 -t $ECR_URI:cache-latest $CACHE_DIR

docker push $ECR_URI:cache-latest

echo "Cache image pushed successfully!"

echo "Deployment complete!"
