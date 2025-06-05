#!/bin/bash
set -e

# Configuration
REMOTE_IP="167.99.87.113"
REMOTE_USER="root"
REMOTE_PASSWORD="JdW^FTy8D/b/PYz"

echo "Cleaning up disk space on ${REMOTE_IP}..."

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
  echo "sshpass not found. Please install it to continue."
  echo "On macOS: brew install hudochenkov/sshpass/sshpass"
  echo "On Ubuntu: apt-get install sshpass"
  exit 1
fi

# Connect to remote server and clean up
sshpass -p "$REMOTE_PASSWORD" ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_IP << EOF
  echo "Before cleanup:"
  df -h
  
  echo -e "\nDocker disk usage before cleanup:"
  docker system df
  
  echo -e "\nStopping all Docker containers except GoQuorum nodes..."
  # Get a list of container IDs excluding GoQuorum nodes
  NON_QUORUM_CONTAINERS=\$(docker ps | grep -v "node-[0-4]" | grep -v "tessera-[0-4]" | grep -v "CONTAINER ID" | awk '{print \$1}')
  if [ ! -z "\$NON_QUORUM_CONTAINERS" ]; then
    docker stop \$NON_QUORUM_CONTAINERS || echo "No non-GoQuorum containers to stop"
  else
    echo "No non-GoQuorum containers found"
  fi
  
  echo -e "\nRemoving all stopped containers..."
  docker container prune -f
  
  echo -e "\nRemoving unused Docker images..."
  docker image prune -a -f
  
  echo -e "\nRemoving unused Docker volumes..."
  docker volume prune -f
  
  echo -e "\nRemoving Docker build cache..."
  docker builder prune -a -f
  
  echo -e "\nCleaning system logs..."
  journalctl --vacuum-time=1d
  
  echo -e "\nCleaning apt cache..."
  apt-get clean
  
  echo -e "\nRemoving temporary files..."
  rm -rf /tmp/* /var/tmp/*
  
  echo -e "\nRemoving old log files..."
  find /var/log -type f -name "*.gz" -delete
  find /var/log -type f -name "*.1" -delete
  find /var/log -type f -name "*.old" -delete
  
  echo -e "\nClearing systemd journal..."
  journalctl --vacuum-size=50M
  
  echo -e "\nRemoving old Docker logs..."
  find /var/lib/docker/containers -name "*-json.log" -exec truncate -s 0 {} \;
  
  echo -e "\nAfter cleanup:"
  df -h
  
  echo -e "\nDocker disk usage after cleanup:"
  docker system df
EOF

echo -e "\nCleanup completed."
echo "You can now run verify-remote-deployment.sh to check if the GoQuorum network is running properly."
