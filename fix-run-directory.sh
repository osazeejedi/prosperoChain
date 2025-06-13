#!/bin/bash
set -e

# Configuration
REMOTE_IP="167.99.87.113"
REMOTE_USER="root"
REMOTE_PASSWORD="JdW^FTy8D/b/PYz"

echo "Fixing /run directory issue on ${REMOTE_IP}..."

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
  echo "sshpass not found. Please install it to continue."
  echo "On macOS: brew install hudochenkov/sshpass/sshpass"
  echo "On Ubuntu: apt-get install sshpass"
  exit 1
fi

# Connect to remote server and fix the /run directory issue
sshpass -p "$REMOTE_PASSWORD" ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_IP << EOF
  echo "Current /run directory usage:"
  df -h /run
  
  echo -e "\nListing large files in /run:"
  find /run -type f -size +10M -exec ls -lh {} \;
  
  echo -e "\nListing directories in /run:"
  du -h --max-depth=1 /run | sort -hr
  
  echo -e "\nCleaning up Docker socket files:"
  find /run -name "docker*.sock" -exec ls -lh {} \;
  
  echo -e "\nStopping Docker service:"
  systemctl stop docker
  
  echo -e "\nCleaning up /run/docker directory:"
  rm -rf /run/docker/* || echo "No files to remove in /run/docker"
  
  echo -e "\nRemoving large files in /run:"
  find /run -type f -size +10M -delete
  
  echo -e "\nRestarting Docker service:"
  systemctl start docker
  
  echo -e "\nWaiting for Docker to start..."
  sleep 5
  
  echo -e "\nChecking Docker service status:"
  systemctl status docker
  
  echo -e "\n/run directory usage after cleanup:"
  df -h /run
EOF

echo -e "\nFix completed."
echo "You can now run verify-remote-deployment.sh to check if the issue is resolved."
echo "If the issue persists, you may need to run cleanup-remote-server.sh or deploy-lightweight-network.sh."
