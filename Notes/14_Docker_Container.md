# Docker - Container Fundamentals & Production Guide

## Table of Contents

- [What is Docker?](#what-is-docker)
- [Why Docker Over Virtual Machines?](#why-docker-over-virtual-machines)
- [Core Concepts](#core-concepts)
- [Installation & Setup](#installation--setup)
- [Docker User Group & Permissions](#docker-user-group--permissions)
- [Essential Docker Commands](#essential-docker-commands)
- [Working with Images](#working-with-images)
- [Running & Managing Containers](#running--managing-containers)
- [Container Lifecycle & Policies](#container-lifecycle--policies)
- [Creating Custom Docker Images](#creating-custom-docker-images)
- [Production Use Cases](#production-use-cases)
- [Best Practices](#best-practices)

---

## What is Docker?

**Docker** is a containerization platform that packages applications and their dependencies into lightweight, portable units called **containers**.

### In Simple Terms:

**Traditional Approach (Before Docker):**
```
Your App → Full OS → Lots of Disk Space & Memory → Slow startup → Heavy
```

**Docker Approach:**
```
Your App → Lightweight Container → Minimal Overhead → Fast startup → Lightweight
```

### Real-World Analogy:

**Shipping Industry Analogy:**
- **Without Docker (VM):** Loading cargo on different ships requires different equipment, different loading procedures, different storage areas. Takes time to setup.
- **With Docker (Containers):** All cargo goes into standard containers. Same container works on any ship, truck, or train. Load once, ship anywhere.

### What Docker Provides:

1. **Consistency** - "Works on my machine" problem solved
2. **Isolation** - Apps don't interfere with each other
3. **Efficiency** - Shared OS kernel, lightweight
4. **Portability** - Run anywhere (laptop, server, cloud)
5. **Scalability** - Spin up multiple containers easily

---

## Why Docker Over Virtual Machines?

### Virtual Machine (VM) vs Docker Comparison

| Aspect | Virtual Machine | Docker Container |
|--------|-----------------|-----------------|
| **Size** | 5-10 GB (includes full OS) | 100-500 MB (shares OS kernel) |
| **Startup Time** | 1-2 minutes | < 1 second |
| **Memory Usage** | 1-4 GB minimum | 50-200 MB typical |
| **Performance** | 5-10% overhead (virtualization) | < 1% overhead (native) |
| **Density** | Can run 10-20 VMs per host | Can run 100-1000 containers per host |
| **Management** | Complex (full OS to maintain) | Simple (just app + dependencies) |

### Detailed Explanation: Why VMs Are Heavy

**VM Architecture:**
```
┌─────────────────────────────────────┐
│       Your Application              │
├─────────────────────────────────────┤
│    Guest OS (Linux) - FULL OS!      │  ← THIS IS THE PROBLEM
│  ├─ Linux Kernel (50 MB)            │
│  ├─ Package Manager                 │
│  ├─ Shell & Utilities               │
│  ├─ Libraries & Tools               │
│  └─ Unnecessary services            │
├─────────────────────────────────────┤
│ Hypervisor (VirtualBox/KVM)         │
├─────────────────────────────────────┤
│    Host Machine OS & Hardware       │
└─────────────────────────────────────┘

Resource Usage:
- Each VM needs its own complete OS
- Minimum 1-2 GB RAM per VM just for OS
- Startup: Need to boot entire OS (1-2 minutes)
- Disk space: 5-10 GB per VM
```

**Docker Container Architecture:**
```
┌─────────────────────────────────────┐
│       Your Application              │
├─────────────────────────────────────┤
│ Docker Engine (Minimal - just Docker)│
├─────────────────────────────────────┤
│    SHARED Host OS Kernel            │  ← MUCH MORE EFFICIENT!
│         (Used by ALL containers)    │
├─────────────────────────────────────┤
│    Host Machine OS & Hardware       │
└─────────────────────────────────────┘

Resource Usage:
- Shared kernel across all containers
- Only 50-100 MB per container
- Startup: Instant (< 1 second)
- Disk space: 100-500 MB per container
```

### Cost Comparison: Real Example

**Hosting a Web Application with 100 concurrent users:**

**Using VMs (10 VMs needed):**
```
10 VMs × 2 GB RAM each = 20 GB RAM needed
10 VMs × 50 GB storage = 500 GB storage
10 servers to manage & update
Monthly cost: $2000-5000
```

**Using Docker (100 containers):**
```
100 containers × 100 MB RAM = 10 GB RAM needed
100 containers × 500 MB = 50 GB storage
1 server to manage
Monthly cost: $300-500
```

**Cost Savings: 80-90%! Plus, less management overhead.**

### Why VMs Are Still Used:

- Full isolation (important for untrusted workloads)
- Run different OS types (Windows, Linux on same host)
- Strict licensing requirements
- Some legacy applications require full OS

---

## Core Concepts

### Three Main Docker Concepts:

#### 1. **Image** - Blueprint/Template
```
Think of it as: A class in programming
Properties: 
  - Read-only
  - Contains: OS, libraries, app code, dependencies
  - Can be stored, shared, versioned
  - Created once, run many times
  
Example: ubuntu:20.04, nginx:latest, python:3.9
```

#### 2. **Container** - Running Instance
```
Think of it as: An object created from a class
Properties:
  - Running instance of an image
  - Can be started, stopped, paused
  - Has isolated filesystem, network, processes
  - Changes are lost when container stops (unless committed)

Example: Container ID a8f9c3b2e1d5 running nginx
```

#### 3. **Registry** - Image Repository
```
Think of it as: GitHub for Docker images
Popular registries:
  - Docker Hub (public, default)
  - Docker Registry (private, self-hosted)
  - AWS ECR (AWS-hosted private)
  - Google Container Registry (GCP)
  - Azure Container Registry (Azure)

Example: docker pull nginx  # Pulls from Docker Hub
```

### Image vs Container

```
IMAGE                          CONTAINER
(Template/Class)               (Running Instance)
├─ Read-only                   ├─ Read-write
├─ Can run 100 containers      ├─ One container per instance
├─ Static                      ├─ Dynamic (running)
├─ Size: 100-500 MB            ├─ Size: image + runtime + changes
└─ Shared across containers    └─ Isolated per container
```

---

## Installation & Setup

### Installation for Different Linux Distributions

#### **On Ubuntu/Debian:**
```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install dependencies
sudo apt-get install -y curl wget gnupg lsb-release ca-certificates

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Verify installation
docker --version
sudo docker run hello-world
```

#### **On CentOS/RHEL/Fedora:**
```bash
# Install Docker from official repository
sudo yum install -y curl wget yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker  # Enable on boot

# Verify installation
docker --version
sudo docker run hello-world
```

#### **On Fedora (Latest):**
```bash
# Install Docker
sudo dnf install -y docker

# Start and enable
sudo systemctl start docker
sudo systemctl enable docker

# Verify
docker --version
```

---

## Docker User Group & Permissions

### The Problem: Running Docker Without `sudo`

By default, Docker commands require `sudo`, which can be inconvenient and poses security risks.

```bash
# Without proper setup
sudo docker ps
sudo docker run ubuntu ls

# This requires typing sudo every time!
```

### Solution: Add User to Docker Group

#### Step 1: Create Docker Group (Usually already exists)
```bash
sudo groupadd docker
```

#### Step 2: Add Current User to Docker Group
```bash
sudo usermod -aG docker $USER

# Or add specific user
sudo usermod -aG docker username
```

#### Step 3: Activate Group Changes
```bash
# Option A: Run this command to apply immediately
newgrp docker

# Option B: Log out and log back in (applies changes to new sessions)
exit
# Then login again
```

#### Step 4: Verify (Without sudo)
```bash
docker ps
docker images
docker --version

# Should work without sudo now!
```

#### Step 5: Test with hello-world Container
```bash
docker run hello-world

# If this works without sudo, setup is complete!
```

### Important Security Note:

```
WARNING: Adding user to docker group is equivalent to root access!
────────────────────────────────────────────────────────────────

docker group users can:
  ✗ Mount host directories in containers
  ✗ Run containers with full host access
  ✗ Potentially gain root access to the host

Best Practice:
  ✓ Only add trusted users to docker group
  ✓ Use --security-opt in production
  ✓ Run Docker daemon in rootless mode for extra security
  ✓ Restrict container capabilities

For production: Consider using Docker with rootless mode
$ dockerd-rootless-setuptool.sh install
```

---

## Essential Docker Commands

### 1. **docker --help** - Get Help

```bash
# Full help for Docker
docker --help

# Help for specific command
docker run --help
docker ps --help
docker build --help

# Shows all available docker commands and options
```

### 2. **docker search** - Search for Images on Docker Hub

```bash
# Search for nginx image
docker search nginx

# Search for python image
docker search python

# Output shows:
# NAME                      DESCRIPTION                 STARS
# nginx                     Official build of Nginx     16000+
# jwilder/nginx-proxy       nginx-proxy                 1800+

# Search with filters
docker search nginx --filter "stars=1000"  # Only show images with 1000+ stars
docker search nginx --limit 5              # Show only 5 results
```

### 3. **docker images** - List Downloaded Images

```bash
# List all images on your system
docker images

# Output example:
# REPOSITORY    TAG       IMAGE ID       CREATED       SIZE
# nginx         latest    dd34e67e3371   2 weeks ago    142MB
# ubuntu        20.04     ba6acccedd29   3 weeks ago    72.9MB
# python        3.9       e1b6668d8a1a   1 month ago    916MB

# Show only image IDs
docker images -q

# Show all images (including intermediate)
docker images -a

# Show images with specific repository
docker images nginx
```

### 4. **docker pull** - Download Images from Registry

```bash
# Pull latest version of an image
docker pull nginx

# Pull specific version (tag)
docker pull nginx:1.20.0
docker pull ubuntu:20.04
docker pull python:3.9-slim

# Pull from private registry
docker pull myregistry.azurecr.io/myapp:v1.0

# Verify after pulling
docker images nginx
```

### 5. **docker rmi** - Remove Images

```bash
# Remove specific image (by name)
docker rmi nginx

# Remove specific image version (by tag)
docker rmi nginx:1.20.0

# Remove multiple images
docker rmi ubuntu:20.04 python:3.9

# Remove image by image ID
docker rmi dd34e67e3371

# Force remove (even if in use)
docker rmi -f nginx

# Remove all images
docker rmi $(docker images -q)

# Important: Container using image must be stopped first
# If you try to remove an image with running container:
# Error response from daemon: conflict: unable to remove repository reference
#   (must force) - image is being used by running container a1b2c3d4e5f6
```

---

## Working with Images

### Finding & Understanding Images

```bash
# Search for images
docker search nginx

# Pull the image
docker pull nginx:latest

# Inspect image details
docker inspect nginx:latest

# Shows detailed info:
# - Image ID
# - Created date
# - DockerVersion
# - Architecture
# - Environment variables
# - Exposed ports
# - Volumes
# - Default command/entrypoint
```

### Best Practices for Images

```bash
# Use specific versions (not just 'latest')
✓ GOOD:   docker pull nginx:1.21.0
✗ BAD:    docker pull nginx          # Uses 'latest' by default

# Use minimal base images
✓ GOOD:   python:3.9-slim (150 MB)
✗ BAD:    python:3.9 (900 MB)

# Use official images
✓ GOOD:   docker pull nginx          # Official image
✗ BAD:    docker pull random-guy/nginx  # Unknown source
```

---

## Running & Managing Containers

### 1. **docker run** - Launch a Container

#### Basic Syntax:
```bash
docker run [OPTIONS] IMAGE [COMMAND]
```

#### Simple Examples:
```bash
# Run ubuntu and execute ls command
docker run ubuntu ls

# Run nginx in the background
docker run nginx

# Run python command
docker run python:3.9 python --version
```

#### Advanced Example with Detailed Explanation:
```bash
docker run --detach \
  --publish 8080:80 \
  --name webserver \
  --memory 512m \
  --cpus 1 \
  nginx:latest

# Let's break down each flag:

--detach              # Run in background (don't show logs in terminal)
                      # Without this: container logs show in console

--publish 8080:80     # Port mapping: HOST:CONTAINER
                      # Host port 8080 → Container port 80
                      # Now access at: http://localhost:8080

--name webserver      # Give container a memorable name
                      # Instead of: a8f9c3b2e1d5 (random ID)
                      # Use:       webserver
                      # Commands: docker stop webserver

--memory 512m         # Limit container memory to 512 MB
                      # Prevents one container from consuming all RAM

--cpus 1              # Limit to 1 CPU core
                      # Prevents CPU hogging

nginx:latest          # The image to run
                      # nginx = image name
                      # latest = tag/version

# After run, Docker generates unique CONTAINER ID: a8f9c3b2e1d5
```

#### More Practical Examples:
```bash
# Web server with volume mount (persistent data)
docker run --detach \
  --publish 8080:80 \
  --name web \
  --volume /home/user/html:/usr/share/nginx/html \
  nginx

# Database container with environment variables
docker run --detach \
  --name postgres \
  --environment POSTGRES_PASSWORD=mypassword \
  --volume pgdata:/var/lib/postgresql/data \
  postgres:13

# Python app with port and limits
docker run --detach \
  --publish 5000:5000 \
  --name myapp \
  --memory 1g \
  --cpus 2 \
  my-python-app:1.0

# Interactive terminal (debugging)
docker run -it ubuntu bash
# -i: interactive (keep STDIN open)
# -t: allocate pseudo-terminal
# Now you can type commands inside container
```

### 2. **docker ps** - List Running Containers

```bash
# List running containers
docker ps

# Output:
# CONTAINER ID  IMAGE    COMMAND         NAMES    STATUS       PORTS
# a8f9c3b2e1d5  nginx    "nginx -g ..."  web      Up 2 hours   0.0.0.0:8080->80

# List ALL containers (running + stopped)
docker ps -a

# Show only container IDs
docker ps -q

# Show with specific format
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### 3. **docker stop** - Stop a Container (Gracefully)

```bash
# Stop by container name
docker stop webserver

# Stop by container ID
docker stop a8f9c3b2e1d5

# Stop multiple containers
docker stop web database cache

# Force stop with timeout
docker stop -t 10 webserver  # Wait 10 seconds before force killing

# Wait for container to stop (blocking)
docker stop -t 30 webserver && echo "Stopped successfully"
```

### 4. **docker start** vs **docker run** - Key Difference

```
docker run - Creates & Starts a NEW container
──────────────────────────────────────────────
$ docker run --name web nginx
├─ Creates new container from image
├─ Starts the container
├─ First time use only
└─ Result: New container running

Multiple runs = Multiple containers!
$ docker run nginx  # Creates container 1
$ docker run nginx  # Creates container 2
$ docker run nginx  # Creates container 3
$ docker ps        # Shows 3 containers!


docker start - Restarts an EXISTING stopped container
──────────────────────────────────────────────────────
$ docker start web
├─ Uses existing container
├─ Restarts it from stopped state
├─ Must be stopped first
└─ Result: Same container running again

Multiple starts = Same container!
$ docker start web
$ docker start web
$ docker start web
$ docker ps        # Shows 1 container!
```

#### Comparison Table:
| Command | Creates Container | Starts Container | Image Required | When to Use |
|---------|-------------------|------------------|----------------|------------|
| `docker run` | ✅ Yes | ✅ Yes | ✅ Yes | First time, new instance |
| `docker start` | ❌ No | ✅ Yes | ❌ No | Restart stopped container |

#### Real Example:
```bash
# Initial setup - use docker run
docker run --detach --publish 8080:80 --name webserver nginx
# Container is now running

# Later, you stop it
docker stop webserver
# Container is stopped but not deleted

# Don't create a new one, restart the existing!
docker start webserver
# Same container, same data, same configuration
```

### 5. **docker rm** - Remove Container (Delete)

```bash
# Remove stopped container
docker rm webserver

# Remove by container ID
docker rm a8f9c3b2e1d5

# Remove multiple containers
docker rm web database cache

# Force remove (even if running)
docker rm -f webserver

# Remove all stopped containers
docker rm $(docker ps -qa)

# Important: Container must be stopped first!
# If running: Error: You cannot remove a running container
docker stop webserver  # Stop first
docker rm webserver    # Then remove
```

### Important Note: Image vs Container Removal

```
REMOVING A CONTAINER WITH RUNNING INSTANCE:
─────────────────────────────────────────────

DON'T DO THIS:
$ docker rmi nginx   # Remove image with running container
# Error: conflict: unable to remove repository reference
#   (must force) - image is being used by running container a1b2c3d4.

CORRECT PROCEDURE:
1. Stop running container first
   $ docker stop webserver

2. Then remove container
   $ docker rm webserver

3. Then remove image
   $ docker rmi nginx

SHORTCUT (Force remove - not recommended):
$ docker rm -f webserver  # Stops and removes container
$ docker rmi -f nginx     # Forces image removal
```

---

## Container Lifecycle & Policies

### Container States:

```
Created → Running → Paused → Stopped → Removed
  │        │        │        │        │
  └─ Just created    │        │        └─ Deleted
     Not started     │        └─ Can be restarted
                     └─ Temporarily paused
```

### Restart Policies - Keep Containers Running After Host Reboot

#### Problem:
```
Without restart policy:
- Server reboots
- Docker daemon restarts
- Containers stay stopped
- Services are down!
```

#### Solution: Restart Policy Flag

```bash
# Restart policy: always (auto-restart even after docker daemon restart)
docker run --detach \
  --publish 8080:80 \
  --name webserver \
  --restart always \
  nginx:latest

# Output unique CONTAINER ID: a8f9c3b2e1d5
```

#### Available Restart Policies:

| Policy | Behavior | Use Case |
|--------|----------|----------|
| `no` | Do not auto-restart | Development, manual management |
| `always` | Always restart unless explicitly stopped | Production services |
| `unless-stopped` | Restart unless explicitly stopped | Most production scenarios |
| `on-failure` | Restart only if exit code != 0 | Services that may fail |
| `on-failure:3` | Restart max 3 times on failure | Prevent infinite restart loops |

#### Real Production Examples:

```bash
# Web server - always restart
docker run --detach \
  --publish 8080:80 \
  --name web \
  --restart always \
  nginx:latest

# Database - restart unless stopped
docker run --detach \
  --name postgres \
  --restart unless-stopped \
  --volume pgdata:/var/lib/postgresql/data \
  postgres:13

# Worker process - restart max 5 times
docker run --detach \
  --name worker \
  --restart on-failure:5 \
  my-worker-app:1.0

# Development - no restart
docker run -it \
  --restart no \
  ubuntu bash
```

#### Verify Restart Policy:

```bash
# Check restart policy of container
docker inspect webserver | grep -A 5 "RestartPolicy"

# Output shows:
# "RestartPolicy": {
#     "Name": "always",
#     "MaximumRetryCount": 0
# }
```

#### Server Restart Behavior with `--restart always`:

```bash
# Before server restart
$ docker ps
# CONTAINER ID  IMAGE  NAMES       STATUS
# a8f9c3b2e1d5  nginx  webserver   Up 5 days

# Server reboots/docker daemon stops

# After server restart (with --restart always)
$ docker ps
# CONTAINER ID  IMAGE  NAMES       STATUS
# a8f9c3b2e1d5  nginx  webserver   Up 2 seconds  ← Auto-restarted!

# Without --restart policy: Container stays stopped
```

---

## Creating Custom Docker Images

### Understanding Dockerfile

A **Dockerfile** is a recipe/script that tells Docker how to build an image.

#### Dockerfile Components:

```dockerfile
# 1. FROM - Start from base image
FROM nginx:latest

# 2. COPY - Copy files from host to container
COPY index.html /usr/share/nginx/html/index.html

# 3. RUN - Execute commands during build
RUN apt-get update && apt-get install -y curl

# 4. ENV - Set environment variables
ENV APP_NAME="MyApp"

# 5. EXPOSE - Document which ports the app uses
EXPOSE 8080

# 6. CMD - Default command when container starts
CMD ["nginx", "-g", "daemon off;"]

# 7. ENTRYPOINT - Configure container to run as executable
ENTRYPOINT ["/app/start.sh"]

# 8. WORKDIR - Set working directory
WORKDIR /app
```

### Real Example 1: Simple Web Server

```dockerfile
# Create directory first
mkdir my-webapp
cd my-webapp

# Create index.html
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My Docker App</title>
</head>
<body>
    <h1>Welcome to Docker! 🐳</h1>
    <p>This runs in a container.</p>
</body>
</html>
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
# Start from nginx base image
FROM nginx:latest

# Copy custom HTML to web server directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 (nginx default)
EXPOSE 80

# Start nginx (default nginx behavior)
CMD ["nginx", "-g", "daemon off;"]
EOF

# Build the image
docker build --tag mycompany/my-webapp:1.0 .

# Run the container
docker run --detach --publish 8080:80 --name myapp mycompany/my-webapp:1.0

# Access at http://localhost:8080
```

### Real Example 2: Python Application

```dockerfile
# Create directory structure
mkdir my-python-app
cd my-python-app

# Create Python app
cat > app.py << 'EOF'
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from Docker!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
Flask==2.0.1
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
# Use Python base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install -r requirements.txt

# Copy application code
COPY app.py .

# Expose port
EXPOSE 5000

# Run application
CMD ["python", "app.py"]
EOF

# Build
docker build --tag mycompany/python-app:1.0 .

# Run
docker run --detach --publish 5000:5000 --name pyapp mycompany/python-app:1.0
```

### Real Example 3: Application with RUN Commands

```dockerfile
FROM ubuntu:20.04

# Update system
RUN apt-get update && apt-get upgrade -y

# Install software
RUN apt-get install -y \
    curl \
    wget \
    git \
    build-essential

# Set environment variable
ENV APP_ENV=production

# Copy application
COPY /app /app

# Set working directory
WORKDIR /app

# Build your application (example)
RUN ./build.sh

# Expose port
EXPOSE 8080

# Default command
CMD ["./start.sh"]
```

### Dockerfile Best Practices:

```dockerfile
# ✓ GOOD - Combines multiple RUN commands
FROM ubuntu:20.04
RUN apt-get update && \
    apt-get install -y curl wget git && \
    apt-get clean

# ✗ BAD - Separate RUN commands (creates extra layers, larger image)
FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y git

# ✓ GOOD - Minimal base image
FROM python:3.9-slim  # ~150 MB

# ✗ BAD - Bloated base image
FROM ubuntu:20.04     # ~70 MB, but needs all tools installed

# ✓ GOOD - Copy specific files
COPY app.py requirements.txt /app/

# ✗ BAD - Copy everything including git history
COPY . /app/

# ✓ GOOD - Non-root user for security
RUN useradd -m appuser
USER appuser

# ✗ BAD - Running as root (security risk)
# (no USER directive)
```

### Building Docker Images

#### Basic Build:
```bash
# Build image from Dockerfile
docker build --tag mycompany/myapp:1.0 .

# Flags:
# --tag    = image name and version (repository/name:tag)
# .        = path to Dockerfile (. = current directory)
```

#### Build with Different Dockerfile:
```bash
# Use specific Dockerfile
docker build -f Dockerfile.prod --tag myapp:prod .

# Use Dockerfile from different directory
docker build --tag myapp:latest /path/to/dockerfile/location/
```

#### Build with Build Arguments:
```bash
# Pass variables during build
docker build \
  --build-arg ENVIRONMENT=production \
  --build-arg VERSION=1.2.0 \
  --tag myapp:1.2.0 \
  .

# In Dockerfile:
ARG VERSION
ARG ENVIRONMENT
RUN echo "Building $VERSION for $ENVIRONMENT"
```

#### Complete Build Example:
```bash
# Build with tag (repository/name:version)
docker build \
  --tag mycompany.azurecr.io/myapp:1.0.0 \
  --tag mycompany.azurecr.io/myapp:latest \
  .

# Flags explained:
# Multiple --tag flags allow multiple names/versions
# Follows: registry/repository/name:tag format
```

---

## Production Use Cases

### Use Case 1: Multi-Container Web Application

```bash
docker network create web-network
docker run --detach --name postgres --network web-network --restart always \
  --environment POSTGRES_PASSWORD=pass --volume pgdata:/var/lib/postgresql/data postgres:13
docker run --detach --name app --network web-network --restart always --memory 512m mycompany/app:1.0
docker run --detach --name nginx --network web-network --publish 80:80 --restart always nginx:latest
```

### Use Case 2: Development Environment

```bash
docker run --detach --name dev-postgres --publish 5432:5432 --environment POSTGRES_PASSWORD=pass postgres:13
docker run --detach --name dev-app --publish 5000:5000 --volume /home/user/code:/app mycompany/app:dev
```

### Use Case 3: Scaling with Multiple Containers

```bash
for i in {1..3}; do
  docker run --detach --name app-$i --restart always mycompany/app:1.0
done
```

---

## Best Practices

### 1. Image Best Practices

```bash
# ✓ Use specific versions
docker pull nginx:1.21.0

# ✗ Avoid 'latest' tag (changes unexpectedly)
docker pull nginx  # Uses 'latest' by default

# ✓ Use minimal base images
FROM python:3.9-slim

# ✗ Avoid bloated images
FROM ubuntu:20.04  # Requires tools installation

# ✓ Security: Use official images
docker pull nginx  # Official

# ✗ Security risk: Unknown source
docker pull random-guy/nginx
```

### 2. Container Best Practices

```bash
# ✓ Set resource limits
docker run --memory 512m --cpus 1 nginx

# ✗ No limits (container can hog all resources)
docker run nginx

# ✓ Use named containers (not random IDs)
docker run --name web nginx

# ✗ Hard to manage random IDs
docker run nginx  # Container ID: a8f9c3b2e1d5f4g6...

# ✓ Use restart policies
docker run --restart unless-stopped nginx

# ✗ Manual restart required
docker run nginx  # Must manually restart after reboot

# ✓ Mount volumes for data persistence
docker run --volume /data:/data nginx

# ✗ Data lost when container stops
docker run nginx  # Changes lost!
```

### 3. Security Best Practices

```dockerfile
# ✓ Run as non-root user
FROM ubuntu:20.04
RUN useradd -m appuser
USER appuser

# ✗ Running as root (security risk)
FROM ubuntu:20.04
# (No USER directive, implicitly root)

# ✓ Use minimal base images (smaller attack surface)
FROM alpine:3.14  # ~5 MB

# ✗ Larger surface area
FROM ubuntu:20.04  # ~70 MB
```

### 4. Network Best Practices

```bash
# ✓ Create isolated network
docker network create app-network
docker run --network app-network --name web nginx
docker run --network app-network --name db postgres

# ✗ Default bridge (less isolated)
docker run nginx
docker run postgres
```

### 5. Storage Best Practices

```bash
# ✓ Use named volumes (managed by Docker)
docker volume create pgdata
docker run --volume pgdata:/var/lib/postgresql/data postgres

# ✓ Use bind mounts for development
docker run --volume /home/user/code:/app myapp

# ✗ Store data in container (lost on rm)
docker run postgresql  # Data in container filesystem
docker rm postgresql   # Data deleted!
```

---

## Quick Reference Cheat Sheet

### Most Common Commands

```bash
# Search and download
docker search nginx
docker pull nginx:latest
docker images

# Run containers
docker run --detach --publish 8080:80 --name web nginx
docker ps
docker ps -a

# Manage containers
docker stop web
docker start web
docker rm web
docker rm -f web  # Force remove even if running

# Manage images
docker rmi nginx
docker rmi -f nginx  # Force remove

# Restart policy
docker run --restart always nginx
docker run --restart unless-stopped postgres

# Remove image (container must be stopped)
docker stop web    # Stop container first
docker rm web      # Remove container
docker rmi nginx   # Remove image
```

---

## Summary

| Topic | Key Point |
|-------|-----------|
| **What is Docker?** | Lightweight containerization for packaging apps |
| **Why Docker?** | Lightweight (100-500 MB vs 5-10 GB VMs), Fast startup, Easy scaling |
| **Image** | Template/blueprint (read-only) |
| **Container** | Running instance of image (read-write, isolated) |
| **Modes** | `docker run` = create new, `docker start` = restart existing |
| **Restart Policy** | `--restart always` for production persistence |
| **Dockerfile** | Recipe to build custom images |
| **Build** | `docker build --tag name:version .` |
| **Limits** | Always set `--memory` and `--cpus` |
| **Security** | Run as non-root, use minimal images, enable restart policy |


