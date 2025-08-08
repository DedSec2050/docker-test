# Jenkins CI/CD Setup for Todo Application

This document provides instructions for setting up and configuring Jenkins for automated deployment of the Todo Application using Docker containers.

## Overview

The Jenkins pipeline automatically builds and deploys both the frontend (Node.js/Express) and backend (Python/Flask) services using Docker containers with proper networking.

## Prerequisites

### Jenkins Server Requirements

- Jenkins installed with Docker support
- Docker installed on the Jenkins agent/server
- Network connectivity to Docker daemon
- Required Jenkins plugins:
  - Docker Pipeline Plugin
  - Pipeline Plugin
  - Git Plugin

### Environment Setup

- Access to MongoDB Atlas or MongoDB instance
- Docker network capabilities
- Ports 3000 (frontend) and 8000 (backend) available

## Jenkins Configuration

### 1. Global Environment Variables

Configure the following environment variables in Jenkins:
**Manage Jenkins → Configure System → Global Properties → Environment Variables**

| Variable      | Description                  | Example                                                                                    |
| ------------- | ---------------------------- | ------------------------------------------------------------------------------------------ |
| `MONGO_URI`   | MongoDB connection string    | `mongodb+srv://user:password@cluster.mongodb.net/?retryWrites=true&w=majority&appName=app` |
| `SECRET_KEY`  | Flask application secret key | `your-super-secret-key-change-in-production`                                               |
| `FLASK_ENV`   | Flask environment            | `production` or `development`                                                              |
| `BACKEND_URL` | Backend URL for frontend     | `http://jenkins-backend-container:8000`                                                    |

### 2. Pipeline Job Setup

1. **Create New Item**

   - Choose "Pipeline" project type
   - Name: `todo-app-pipeline`

2. **Configure Pipeline**
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: Your repository URL
   - **Script Path**: `JenkinsFIle`

### 3. Required Permissions

Ensure Jenkins user has permissions to:

- Execute Docker commands
- Access Docker daemon socket
- Create/manage Docker networks
- Bind to ports 3000 and 8000

## Pipeline Stages Explanation

### Stage 1: Clean Old Containers & Images

```groovy
stage('Clean Old Containers & Images')
```

- Stops and removes existing containers
- Removes old Docker images
- Ensures clean deployment environment
- Uses `|| true` to continue if containers don't exist

### Stage 2: Create Network If Missing

```groovy
stage('Create Network If Missing')
```

- Creates Docker network `docker-net` if it doesn't exist
- Enables communication between frontend and backend containers
- Network is reused across deployments

### Stage 3: Build Backend

```groovy
stage('Build Backend')
```

- Builds Docker image for Python Flask backend
- Uses `backend/Dockerfile`
- Tags image as `jenkins-backend`

### Stage 4: Build Frontend

```groovy
stage('Build Frontend')
```

- Builds Docker image for Node.js Express frontend
- Uses `frontend/Dockerfile`
- Tags image as `jenkins-frontend`

### Stage 5: Run Backend

```groovy
stage('Run Backend')
```

- Starts backend container on port 8000
- Connects to `docker-net` network
- Injects environment variables from Jenkins
- Container name: `jenkins-backend-container`

### Stage 6: Run Frontend

```groovy
stage('Run Frontend')
```

- Starts frontend container on port 3000
- Connects to same Docker network
- Configures backend URL for inter-service communication
- Container name: `jenkins-frontend-container`

## Network Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │
│   (Port 3000)   │◄──►│   (Port 8000)   │
│   Node.js       │    │   Python/Flask  │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────────────────┘
              docker-net network
                     │
              ┌─────────────────┐
              │   MongoDB       │
              │   (Atlas/Cloud) │
              └─────────────────┘
```

## Usage Instructions

### Manual Trigger

1. Go to Jenkins dashboard
2. Select `todo-app-pipeline`
3. Click "Build Now"

### Automatic Triggers

Configure webhook in your Git repository:

- **Webhook URL**: `http://your-jenkins-url/generic-webhook-trigger/invoke`
- **Events**: Push events to main/master branch

### Monitoring Deployment

1. Check Jenkins build console output
2. Verify containers are running:
   ```bash
   docker ps | grep jenkins-
   ```
3. Test application endpoints:
   - Frontend: `http://your-server:3000`
   - Backend API: `http://your-server:8000/api`
   - Health Check: `http://your-server:3000/health`

## Troubleshooting

### Common Issues

#### 1. Docker Permission Denied

```bash
# Add Jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

#### 2. Port Already in Use

```bash
# Check which process is using the port
sudo netstat -tulpn | grep :3000
sudo netstat -tulpn | grep :8000

# Stop conflicting processes
docker stop $(docker ps -q --filter "publish=3000")
docker stop $(docker ps -q --filter "publish=8000")
```

#### 3. Network Issues

```bash
# Recreate Docker network
docker network rm docker-net
docker network create docker-net
```

#### 4. MongoDB Connection Failed

- Verify `MONGO_URI` is correctly set in Jenkins
- Check MongoDB Atlas IP whitelist settings
- Ensure network connectivity from Jenkins server

#### 5. Environment Variables Not Loading

- Verify variables are set in Jenkins Global Properties
- Check variable names match exactly (case-sensitive)
- Restart Jenkins after adding new variables

### Debugging Commands

```bash
# View Jenkins pipeline logs
# Check in Jenkins UI → Build → Console Output

# Inspect running containers
docker inspect jenkins-backend-container
docker inspect jenkins-frontend-container

# View container logs
docker logs jenkins-backend-container
docker logs jenkins-frontend-container

# Test network connectivity
docker exec jenkins-frontend-container ping jenkins-backend-container

# Check environment variables in containers
docker exec jenkins-backend-container env
docker exec jenkins-frontend-container env
```

## Security Considerations

1. **Environment Variables**

   - Store sensitive data in Jenkins credentials store
   - Use Jenkins credential bindings instead of plain text
   - Rotate secrets regularly

2. **Docker Security**

   - Use non-root users in Docker containers
   - Implement proper image scanning
   - Keep base images updated

3. **Network Security**
   - Restrict access to Jenkins server
   - Use HTTPS for Jenkins web interface
   - Implement proper firewall rules

## Advanced Configuration

### Using Jenkins Credentials

Replace environment variables with credential bindings:

```groovy
environment {
    MONGO_URI = credentials('mongo-uri-secret')
    SECRET_KEY = credentials('flask-secret-key')
}
```

### Multi-Environment Deployment

Add parameters for different environments:

```groovy
parameters {
    choice(
        name: 'ENVIRONMENT',
        choices: ['development', 'staging', 'production'],
        description: 'Deployment environment'
    )
}
```

### Health Checks

Add health check stage:

```groovy
stage('Health Check') {
    steps {
        sh '''
            sleep 10
            curl -f http://localhost:3000/health || exit 1
            curl -f http://localhost:8000/health || exit 1
        '''
    }
}
```

## Maintenance

### Regular Tasks

- Monitor disk usage (Docker images/containers)
- Update base images in Dockerfiles
- Review and rotate secrets
- Update Jenkins plugins
- Monitor application logs

### Backup Strategy

- Backup Jenkins configuration
- Backup build artifacts if needed
- Document environment variable configurations

## Support

For issues related to:

- **Jenkins Setup**: Check Jenkins documentation
- **Docker Issues**: Verify Docker installation and permissions
- **Application Errors**: Check application logs in containers
- **MongoDB Connection**: Verify connection string and network access

## Additional Resources

- [Jenkins Pipeline Documentation](https://jenkins.io/doc/book/pipeline/)
- [Docker Networking Guide](https://docs.docker.com/network/)
- [MongoDB Atlas Documentation](https://docs.atlas.mongodb.com/)
- [Flask Deployment Guide](https://flask.palletsprojects.com/en/latest/deploying/)
- [Express.js Production Guide](https://expressjs.com/en/advanced/best-practice-performance.html)
