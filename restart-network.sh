#!/bin/bash

# Script to restart the Quorum QBFT network with optimized Blockscout settings

echo "Stopping any running containers..."
docker-compose down

echo "Starting the network with optimized Blockscout settings..."
docker-compose up -d

echo "Waiting for services to initialize..."
sleep 10

echo "Checking service status..."
docker-compose ps

echo "Network restarted successfully!"
echo "Blockscout explorer should be available at http://localhost:4000"
echo "Quorum node RPC endpoints are available at:"
echo "  - Node 0: http://localhost:22000"
echo "  - Node 1: http://localhost:22001"
echo "  - Node 2: http://localhost:22002"
echo "  - Node 3: http://localhost:22003"
echo "  - Node 4: http://localhost:22004"

echo ""
echo "To monitor Blockscout database connections, you can use:"
echo "docker-compose logs -f explorer | grep -i 'database\|connection\|pool'"

echo ""
echo "Additional optimizations applied:"
echo "1. Added queue parameters to prevent connection drops"
echo "   - ECTO_QUEUE_TARGET: 5000ms"
echo "   - ECTO_QUEUE_INTERVAL: 5000ms"
echo "2. Disabled verified contracts counter to reduce database load"
echo "   - DISABLE_VERIFIED_CONTRACTS_COUNTER: true"
echo ""
echo "For more details, see BLOCKSCOUT_DB_OPTIMIZATION.md"
