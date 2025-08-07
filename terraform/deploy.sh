#!/bin/bash

# Step 1: Create ECR repos
terraform apply -target=aws_ecr_repository.flask_repo -target=aws_ecr_repository.express_repo

echo "✅ ECR repositories created."
echo "⏸️  Please push your Docker images to ECR now, then press ENTER to continue..."
read

# Step 2: Apply the rest
terraform apply
