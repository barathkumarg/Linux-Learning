#!/bin/bash

##############################################################################
# Docker - Container Fundamentals & Production Commands
# Reference: 14_Docker_Container.md
#
# Docker: Lightweight containerization for packaging applications
# Replaces heavy VMs with lightweight, efficient containers
##############################################################################

echo "=========================================="
echo "Docker Command Reference - Complete Guide"
echo "=========================================="

# ============================================================================
# SECTION 1: INSTALLATION VERIFICATION
# ============================================================================

echo -e "\n### SECTION 1: Installation & Verification ###\n"

echo "1. Check if Docker is installed:"
echo "$ docker --version"
# Output: Docker version 20.10.7, build b0f5bc3

echo -e "\n2. Verify Docker daemon is running:"
echo "$ sudo systemctl status docker"
# Output: ● docker.service - Docker Application Container Engine

echo -e "\n3. Test Docker installation:"
echo "$ docker run hello-world"
# Pulls and runs hello-world image, prints welcome message

# ============================================================================
# SECTION 2: DOCKER USER GROUP SETUP
# ============================================================================

echo -e "\n### SECTION 2: Docker User Group Setup ###\n"

echo "2a. Create Docker group (if not exists):"
echo "$ sudo groupadd docker"

echo -e "\n2b. Add current user to Docker group:"
echo "$ sudo usermod -aG docker \$USER"

echo -e "\n2c. Apply group changes immediately:"
echo "$ newgrp docker"
# Or logout and login again

echo -e "\n2d. Verify (should work without sudo):"
echo "$ docker ps"
# Should list containers without sudo prompt

# ============================================================================
# SECTION 3: DOCKER HELP COMMANDS
# ============================================================================

echo -e "\n### SECTION 3: Getting Help ###\n"

echo "3a. Full Docker help:"
echo "$ docker --help"
# Lists all available docker commands and options

echo -e "\n3b. Help for specific command:"
echo "$ docker run --help"
echo "$ docker ps --help"
echo "$ docker build --help"
# Shows detailed options for specific command

echo -e "\n3c. Docker version and info:"
echo "$ docker version"      # Version details
echo "$ docker info"         # System-wide information

# ============================================================================
# SECTION 4: SEARCHING FOR IMAGES
# ============================================================================

echo -e "\n### SECTION 4: Searching for Images ###\n"

echo "4a. Search Docker Hub for images:"
echo "$ docker search nginx"
# Output shows image name, description, stars, automation status

echo -e "\n4b. Search with filters:"
echo "$ docker search nginx --filter 'stars=1000'"
echo "$ docker search python --limit 5"

echo -e "\n4c. Common images to search:"
cat << 'EOF'
nginx           - Web server
ubuntu          - Linux distribution
python          - Python runtime
nodejs          - Node.js runtime
mysql           - MySQL database
postgres        - PostgreSQL database
redis           - Redis cache
mongo           - MongoDB database
httpd           - Apache HTTP Server
alpine          - Minimal Linux (~5 MB)
EOF

# ============================================================================
# SECTION 5: IMAGE MANAGEMENT
# ============================================================================

echo -e "\n### SECTION 5: Image Management ###\n"

echo "5a. List all downloaded images:"
echo "$ docker images"
# Shows REPOSITORY, TAG, IMAGE ID, CREATED, SIZE

echo -e "\n5b. List only image IDs:"
echo "$ docker images -q"

echo -e "\n5c. List all images (including hidden):"
echo "$ docker images -a"

echo -e "\n5d. Show images for specific repository:"
echo "$ docker images nginx"

echo -e "\n5e. Pull images from Docker Hub:"
echo "$ docker pull nginx                # Latest version"
echo "$ docker pull nginx:1.20.0         # Specific version"
echo "$ docker pull ubuntu:20.04"
echo "$ docker pull python:3.9-slim"

echo -e "\n5f. Pull from private registry:"
echo "$ docker pull myregistry.azurecr.io/myapp:v1.0"
echo "$ docker pull quay.io/myorg/app:latest"

echo -e "\n5g. Remove images:"
echo "$ docker rmi nginx                    # Remove by name"
echo "$ docker rmi nginx:1.20.0             # Remove specific version"
echo "$ docker rmi a8f9c3b2e1d5             # Remove by image ID"
echo "$ docker rmi -f nginx                 # Force remove"
echo "$ docker rmi \$(docker images -q)     # Remove all images"

echo -e "\n5h. Important: Remove image requirements:"
cat << 'EOF'
Before removing an image, stop any containers using it:

WRONG (will fail):
$ docker rmi nginx
# Error: conflict: unable to remove repository reference
#   (must force) - image is being used by running container

CORRECT:
1. List containers using image
   $ docker ps | grep nginx

2. Stop running containers
   $ docker stop webserver

3. Remove containers
   $ docker rm webserver

4. Now remove image
   $ docker rmi nginx
EOF

# ============================================================================
# SECTION 6: RUNNING CONTAINERS
# ============================================================================

echo -e "\n### SECTION 6: Running Containers ###\n"

echo "6a. Basic container run:"
echo "$ docker run ubuntu ls"
# Runs ls command in ubuntu container, prints output, exits

echo -e "\n6b. Run container in background (detached):"
echo "$ docker run --detach nginx"
# Returns container ID immediately, container runs in background

echo -e "\n6c. Run with publication (port mapping):"
echo "$ docker run --detach --publish 8080:80 nginx"
# Maps host port 8080 to container port 80
# Access nginx at http://localhost:8080

echo -e "\n6d. Run with name:"
echo "$ docker run --detach --name webserver nginx"
# Container name: webserver (instead of random ID)
# Reference: docker stop webserver

echo -e "\n6e. Full example with all options:"
cat << 'EOF'
docker run --detach \
  --publish 8080:80 \
  --name webserver \
  --memory 512m \
  --cpus 1 \
  nginx:latest

Detailed explanation:
  --detach              Run in background
  --publish 8080:80     Host port 8080 → Container port 80
  --name webserver      Memorable container name
  --memory 512m         Limit memory to 512 MB
  --cpus 1              Limit to 1 CPU core
  nginx:latest          Image and version to run

Result: Container running with ID a8f9c3b2e1d5
EOF

echo -e "\n6f. Run with environment variables:"
echo "$ docker run --detach \\"
echo "  --environment POSTGRES_PASSWORD=secretpass \\"
echo "  --name mydb \\"
echo "  postgres:13"

echo -e "\n6g. Run with volume mount (persistent data):"
echo "$ docker run --detach \\"
echo "  --volume /home/user/html:/usr/share/nginx/html \\"
echo "  --name web \\"
echo "  nginx"
# Changes to /home/user/html appear in container

echo -e "\n6h. Run interactively (debugging):"
echo "$ docker run -it ubuntu bash"
# -i: Interactive (keep STDIN open)
# -t: Terminal (allocate pseudo-terminal)
# Result: You're inside the container, can type commands
# Type 'exit' to exit

echo -e "\n6i. Run with resource limits:"
echo "$ docker run --detach \\"
echo "  --memory 1g \\"
echo "  --cpus 2 \\"
echo "  --memory-swap 2g \\"
echo "  myapp:1.0"
# Limit memory to 1 GB, swap to 2 GB, CPU cores to 2

# ============================================================================
# SECTION 7: LISTING AND VIEWING CONTAINERS
# ============================================================================

echo -e "\n### SECTION 7: Viewing Containers ###\n"

echo "7a. List running containers:"
echo "$ docker ps"
# Shows: CONTAINER ID, IMAGE, COMMAND, CREATED, STATUS, PORTS, NAMES

echo -e "\n7b. List all containers (including stopped):"
echo "$ docker ps -a"
# Shows all containers: running, stopped, exited

echo -e "\n7c. Show only container IDs:"
echo "$ docker ps -q"

echo -e "\n7d. Custom format output:"
echo "$ docker ps --format \"table {{.Names}}\\t{{.Status}}\\t{{.Ports}}\""
# Shows container names, status, and ports in table format

echo -e "\n7e. View container details:"
echo "$ docker inspect webserver"
# Shows detailed info: ID, image, network, mounts, environment, etc.

echo -e "\n7f. View container logs:"
echo "$ docker logs webserver"
echo "$ docker logs -f webserver         # Follow log in real-time"
echo "$ docker logs --tail 20 webserver  # Last 20 lines"

echo -e "\n7g. View container statistics:"
echo "$ docker stats webserver"
# Shows: CPU %, memory usage, network I/O, block I/O

# ============================================================================
# SECTION 8: STOPPING AND STARTING CONTAINERS
# ============================================================================

echo -e "\n### SECTION 8: Container Lifecycle ###\n"

echo "8a. Stop a running container (graceful shutdown):"
echo "$ docker stop webserver"
# Sends SIGTERM signal, gives container time to cleanup
# Default timeout: 10 seconds

echo -e "\n8b. Stop with custom timeout:"
echo "$ docker stop -t 30 webserver"
# Wait 30 seconds before force killing

echo -e "\n8c. Kill a container (force stop):"
echo "$ docker kill webserver"
# Sends SIGKILL signal, immediate termination

echo -e "\n8d. Start a stopped container:"
echo "$ docker start webserver"
# Restarts existing stopped container
# Uses same configuration as original run command

echo -e "\n8e. docker run vs docker start:"
cat << 'EOF'
docker run  - CREATE and START a new container
docker start - START an existing stopped container

docker run:
  ├─ Creates new container
  ├─ Applies new settings (ports, volumes, etc.)
  ├─ First time use only
  └─ Multiple runs = Multiple containers!

docker start:
  ├─ Reuses existing container
  ├─ Same settings as before
  ├─ Use after docker stop
  └─ Multiple starts = Same container!

EXAMPLE:
# First time - use docker run
$ docker run --detach --name web nginx

# Later, stop it
$ docker stop web

# Restart it - use docker start (NOT docker run!)
$ docker start web  # Same container, same config
# DON'T: docker run --name web nginx  # Creates duplicate!
EOF

echo -e "\n8f. Pause and unpause (freeze temporarily):"
echo "$ docker pause webserver"
echo "$ docker unpause webserver"

echo -e "\n8g. Restart a container:"
echo "$ docker restart webserver"
# = docker stop + docker start

# ============================================================================
# SECTION 9: REMOVING CONTAINERS
# ============================================================================

echo -e "\n### SECTION 9: Removing Containers ###\n"

echo "9a. Remove stopped container:"
echo "$ docker rm webserver"

echo -e "\n9b. Remove multiple containers:"
echo "$ docker rm web db cache"

echo -e "\n9c. Remove by container ID:"
echo "$ docker rm a8f9c3b2e1d5"

echo -e "\n9d. Force remove (even if running):"
echo "$ docker rm -f webserver"

echo -e "\n9e. Remove all stopped containers:"
echo "$ docker rm \$(docker ps -a -q)"

echo -e "\n9f. Remove containers AND images safely:"
cat << 'EOF'
SAFE REMOVAL PROCEDURE:

1. Stop all containers
   $ docker stop $(docker ps -q)

2. Remove all containers
   $ docker rm $(docker ps -a -q)

3. Remove all images
   $ docker rmi $(docker images -q)

IMPORTANT: Remove containers BEFORE images!

WRONG (will fail):
$ docker rmi nginx
# Error: image is being used by running container

CORRECT:
$ docker stop webserver
$ docker rm webserver
$ docker rmi nginx
EOF

# ============================================================================
# SECTION 10: DOCKERFILE & IMAGE BUILDING
# ============================================================================

echo -e "\n### SECTION 10: Dockerfile & Building Images ###\n"

echo "10a. Basic Dockerfile structure:"
cat << 'EOF'
FROM nginx:latest                           # Base image
COPY index.html /usr/share/nginx/html/      # Copy files
RUN apt-get update && apt-get install -y curl  # Run commands
ENV APP_NAME="MyApp"                        # Environment variables
EXPOSE 80                                   # Document ports
CMD ["nginx", "-g", "daemon off;"]          # Default command
EOF

echo -e "\n10b. Dockerfile best practices example:"
cat << 'EOF'
# ✓ GOOD: Combined RUN commands (fewer layers, smaller image)
FROM ubuntu:20.04
RUN apt-get update && \
    apt-get install -y curl wget git && \
    apt-get clean

# ✗ BAD: Separate RUN commands (extra layers, larger image)
FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y git

# ✓ GOOD: Minimal base image
FROM alpine:3.14         # 5 MB

# ✗ BAD: Bloated base image
FROM ubuntu:20.04        # 70 MB
EOF

echo -e "\n10c. Build image from Dockerfile:"
echo "$ docker build --tag mycompany/myapp:1.0 ."
# Builds image from Dockerfile in current directory

echo -e "\n10d. Build with different Dockerfile:"
echo "$ docker build -f Dockerfile.prod --tag myapp:prod ."

echo -e "\n10e. Build with multiple tags (versions):"
echo "$ docker build \\"
echo "  --tag mycompany/app:1.0.0 \\"
echo "  --tag mycompany/app:latest \\"
echo "  ."

echo -e "\n10f. Build with arguments:"
echo "$ docker build \\"
echo "  --build-arg VERSION=1.2.0 \\"
echo "  --build-arg ENVIRONMENT=prod \\"
echo "  --tag myapp:1.2.0 \\"
echo "  ."

echo -e "\n10g. Real example - Python Flask app:"
cat << 'EOF'
# Create Dockerfile
cat > Dockerfile << 'DOCKEREOF'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
DOCKEREOF

# Create requirements.txt
echo "Flask==2.0.1" > requirements.txt

# Create app.py
cat > app.py << 'PYEOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from Docker!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
PYEOF

# Build image
docker build --tag mycompany/flask-app:1.0 .

# Run container
docker run --detach --publish 5000:5000 --name myapp mycompany/flask-app:1.0
EOF

echo -e "\n10h. View image history:"
echo "$ docker history myapp:1.0"
# Shows each layer/step in image creation

echo -e "\n10i. Tag image with registry:"
echo "$ docker tag myapp:1.0 myregistry.azurecr.io/myapp:1.0"

echo -e "\n10j. Push image to registry:"
echo "$ docker login myregistry.azurecr.io"
echo "$ docker push myregistry.azurecr.io/myapp:1.0"

# ============================================================================
# SECTION 11: RESTART POLICIES
# ============================================================================

echo -e "\n### SECTION 11: Restart Policies ###\n"

echo "11a. Restart policy types:"
cat << 'EOF'
no              - Do not restart (default)
always          - Always restart if stopped
unless-stopped  - Restart unless explicitly stopped
on-failure      - Restart only if exit code != 0
on-failure:3    - Restart max 3 times on failure
EOF

echo -e "\n11b. Run with restart policy:"
echo "$ docker run --detach \\"
echo "  --restart always \\"
echo "  --name webserver \\"
echo "  nginx"

echo -e "\n11c. Restart policy for database (with volume):"
echo "$ docker run --detach \\"
echo "  --restart unless-stopped \\"
echo "  --name postgres \\"
echo "  --volume pgdata:/var/lib/postgresql/data \\"
echo "  postgres:13"

echo -e "\n11d. Service with limited restart attempts:"
echo "$ docker run --detach \\"
echo "  --restart on-failure:5 \\"
echo "  --name worker \\"
echo "  myapp:1.0"

echo -e "\n11e. Check restart policy of container:"
echo "$ docker inspect webserver | grep -A 5 RestartPolicy"
# Output shows restart policy configuration

echo -e "\n11f. Real scenario - Server reboot:"
cat << 'EOF'
SCENARIO: Server reboots after setting --restart always

BEFORE REBOOT:
$ docker ps
# CONTAINER ID  IMAGE  NAMES     STATUS
# a8f9c3b2e1d5  nginx  web       Up 10 days

SERVER REBOOTS...

AFTER REBOOT (with --restart always):
$ docker ps
# CONTAINER ID  IMAGE  NAMES     STATUS
# a8f9c3b2e1d5  nginx  web       Up 3 seconds  ← Auto-restarted!

WITHOUT --restart (stays stopped):
$ docker ps
# (no containers shown - they stayed stopped)
EOF

# ============================================================================
# SECTION 12: CONTAINER NETWORKING
# ============================================================================

echo -e "\n### SECTION 12: Container Networking ###\n"

echo "12a. Create user-defined network:"
echo "$ docker network create app-network"

echo -e "\n12b. Run container on network:"
echo "$ docker run --detach \\"
echo "  --network app-network \\"
echo "  --name web \\"
echo "  nginx"

echo -e "\n12c. Containers can communicate by name:"
echo "$ docker exec web ping db"
# If db container is also on app-network, this works!

echo -e "\n12d. List networks:"
echo "$ docker network ls"

echo -e "\n12e. Inspect network:"
echo "$ docker network inspect app-network"

# ============================================================================
# SECTION 13: VOLUMES & PERSISTENT DATA
# ============================================================================

echo -e "\n### SECTION 13: Volumes & Persistent Data ###\n"

echo "13a. Create named volume:"
echo "$ docker volume create pgdata"

echo -e "\n13b. Run container with named volume:"
echo "$ docker run --detach \\"
echo "  --volume pgdata:/var/lib/postgresql/data \\"
echo "  --name postgres \\"
echo "  postgres:13"

echo -e "\n13c. Bind mount (directory from host):"
echo "$ docker run --detach \\"
echo "  --volume /home/user/code:/app \\"
echo "  --name dev-app \\"
echo "  myapp:dev"
# Changes to /home/user/code appear in container /app

echo -e "\n13d. List volumes:"
echo "$ docker volume ls"

echo -e "\n13e. Inspect volume:"
echo "$ docker volume inspect pgdata"

echo -e "\n13f. Remove unused volumes:"
echo "$ docker volume prune"

# ============================================================================
# SECTION 14: PRACTICAL PRODUCTION SCENARIOS
# ============================================================================

echo -e "\n### SECTION 14: Production Scenarios ###\n"

echo "14a. Multi-container application setup:"
cat << 'EOF'
docker network create web-network
docker run --detach --name postgres --network web-network --restart always \
  --environment POSTGRES_PASSWORD=pass --volume pgdata:/var/lib/postgresql/data postgres:13
docker run --detach --name app --network web-network --restart always mycompany/app:1.0
docker run --detach --name nginx --network web-network --publish 80:80 --restart always nginx:latest
docker ps
EOF

echo -e "\n14b. Scaling application (multiple instances):"
cat << 'EOF'
for i in {1..3}; do
  docker run --detach --name app-$i --restart always mycompany/app:1.0
done
docker ps | grep app-
EOF

echo -e "\n14c. Clean up:"
cat << 'EOF'
docker stop $(docker ps -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)
docker volume prune
docker network prune
EOF

# ============================================================================
# SECTION 15: TROUBLESHOOTING
# ============================================================================

echo -e "\n### SECTION 15: Troubleshooting ###\n"

echo "15a. View container logs:"
echo "$ docker logs webserver"
echo "$ docker logs -f webserver              # Follow in real-time"
echo "$ docker logs --tail 50 webserver       # Last 50 lines"

echo -e "\n15b. Execute command in running container:"
echo "$ docker exec -it webserver bash"
# -it: Interactive terminal
# Now you're inside the container

echo -e "\n15c. Check container resource usage:"
echo "$ docker stats webserver"
# Shows CPU, memory, network I/O, block I/O

echo -e "\n15d. Debug network connectivity:"
echo "$ docker exec app ping database"
# Test if containers can communicate

echo -e "\n15e. View running processes in container:"
echo "$ docker top webserver"

echo -e "\n15f. Copy files between host and container:"
echo "$ docker cp webserver:/var/www/html index.html"
echo "$ docker cp index.html webserver:/var/www/html"

# ============================================================================
# SECTION 16: QUICK REFERENCE / CHEAT SHEET
# ============================================================================

echo -e "\n### SECTION 16: Quick Reference ###\n"

cat << 'EOF'
IMAGE COMMANDS:
  docker search nginx                    # Find images
  docker pull nginx:latest               # Download image
  docker images                          # List downloaded images
  docker rmi nginx                       # Remove image

CONTAINER COMMANDS:
  docker run --detach --name web nginx   # Create & start container
  docker ps                              # List running containers
  docker ps -a                           # List all containers
  docker stop web                        # Stop container
  docker start web                       # Start stopped container
  docker rm web                          # Remove container

RESTART POLICY (Production):
  docker run --restart always ...        # Always restart
  docker run --restart unless-stopped .. # Restart unless stopped
  docker run --restart on-failure:5 ..   # Max 5 restarts

RESOURCE LIMITS (Production):
  docker run --memory 512m --cpus 1 ...  # Set memory & CPU

PERSISTENCE (Production):
  docker run --volume pgdata:/data ...   # Named volume
  docker run --volume /path:/cont ...    # Bind mount

DOCKERFILE & BUILD:
  docker build --tag app:1.0 .           # Build image
  docker build --tag reg/app:1.0 .       # With registry
  docker build -f Dockerfile.prod .      # Specific Dockerfile

DEBUGGING:
  docker logs webserver                  # View logs
  docker exec -it webserver bash         # Get shell in container
  docker stats webserver                 # Resource usage
  docker inspect webserver               # Detailed info
EOF

echo -e "\n=========================================="
echo "Docker Examples Completed!"
echo "=========================================="
