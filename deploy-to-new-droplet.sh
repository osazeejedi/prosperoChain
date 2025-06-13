#!/bin/bash
set -e

# Configuration for the new droplet
REMOTE_IP="167.99.207.201"
REMOTE_USER="root"
REMOTE_PASSWORD="7cn@hv)yqkJ*j"
REMOTE_DIR="/opt/prosperoNetwork"

echo "Deploying lightweight GoQuorum QBFT Network to new droplet at $REMOTE_IP..."

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
  echo "sshpass not found. Please install it to continue."
  echo "On macOS: brew install hudochenkov/sshpass/sshpass"
  echo "On Ubuntu: apt-get install sshpass"
  exit 1
fi

# Create a temporary directory for deployment files
TEMP_DIR=$(mktemp -d)
echo "Created temporary directory: $TEMP_DIR"

# Create deployment directory structure
mkdir -p $TEMP_DIR/goquorum-qbft-network

# Copy necessary files
echo "Copying necessary files..."
cp -r ./generate-keys.sh ./generate-configs.sh ./docker-compose-remote-light.yaml ./SimpleStorage.sol ./passwords.txt ./qbft-extradata.txt ./qbft-genesis.json $TEMP_DIR/goquorum-qbft-network/

# If qdata directory exists, copy it too
if [ -d "./qdata" ]; then
  echo "Copying qdata directory..."
  cp -r ./qdata $TEMP_DIR/goquorum-qbft-network/
fi

# Copy deployment scripts for contracts
echo "Copying contract deployment scripts..."
cp -r ./deploy-http.js ./deploy-remote-http.js $TEMP_DIR/goquorum-qbft-network/

# Create a setup script to run on the remote server
cat > $TEMP_DIR/goquorum-qbft-network/setup-lightweight.sh << 'EOF'
#!/bin/bash
set -e

echo "Setting up lightweight GoQuorum QBFT Network on remote server..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker not found. Installing Docker..."
  apt-get update
  apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
  echo "Docker Compose not found. Installing Docker Compose..."
  curl -L "https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

# Stop any existing GoQuorum containers
echo "Stopping any existing GoQuorum containers..."
docker ps -a | grep -i quorum | awk '{print $1}' | xargs -r docker stop
docker ps -a | grep -i quorum | awk '{print $1}' | xargs -r docker rm

# Navigate to the GoQuorum directory
cd /opt/prosperoNetwork/goquorum-qbft-network

# Rename docker-compose-remote-light.yaml to docker-compose.yaml
cp docker-compose-remote-light.yaml docker-compose.yaml

# Make scripts executable
chmod +x *.sh

# Check if qdata directory exists, if not generate keys and configs
if [ ! -d "qdata/node-0/dd/geth" ]; then
  echo "Node configurations not found. Running setup scripts..."
  
  # Generate keys and configurations
  if ! ./generate-keys.sh; then
    echo "Error generating keys. Please check the error message above."
    exit 1
  fi
  
  if ! ./generate-configs.sh; then
    echo "Error generating configurations. Please check the error message above."
    exit 1
  fi
fi

# Start the network with Docker Compose
echo "Starting Docker containers..."
docker-compose up -d

echo "Waiting for the network to start..."
sleep 10

# Check if nodes are running
for i in {0..4}
do
  echo "Checking node-$i..."
  if ! docker ps | grep -q "goquorum-qbft-network-node-$i"; then
    echo "Node $i is not running. Please check the logs with 'docker-compose logs node-$i'."
  else
    echo "Node $i is running."
  fi
done

# Check if RPC endpoint is accessible
echo "Testing RPC endpoint..."
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' http://localhost:22000
echo ""

echo "Lightweight network deployed successfully!"
echo ""
echo "RPC Endpoint: http://$HOSTNAME:22000"
echo ""
echo "To check the status of the network:"
echo "docker-compose ps"
echo ""
echo "To view logs:"
echo "docker-compose logs -f"
echo ""
echo "To stop the network:"
echo "docker-compose down"
EOF

# Create a verification script for the remote server
cat > $TEMP_DIR/goquorum-qbft-network/verify-deployment.sh << 'EOF'
#!/bin/bash
set -e

echo "Verifying GoQuorum QBFT Network deployment..."

# Check Docker containers
echo "Checking Docker containers..."
docker ps

# Check disk space
echo -e "\nDisk space usage:"
df -h

# Check Docker disk usage
echo -e "\nDocker disk usage:"
docker system df

# Check GoQuorum logs
echo -e "\nChecking GoQuorum logs (last 10 lines):"
docker logs $(docker ps | grep node-0 | awk '{print $1}') --tail 10 2>/dev/null || echo "No node-0 container found"

# Check if RPC endpoint is accessible
echo -e "\nChecking RPC endpoint..."
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:22000
echo ""

# Check if we can get the node info
echo -e "\nGetting node info:"
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' http://localhost:22000
echo ""

# Check if we can get accounts
echo -e "\nGetting accounts:"
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' http://localhost:22000
echo ""

echo -e "\nVerification completed."
EOF

# Make the scripts executable
chmod +x $TEMP_DIR/goquorum-qbft-network/setup-lightweight.sh
chmod +x $TEMP_DIR/goquorum-qbft-network/verify-deployment.sh

# Create the tar archive
echo "Creating tar archive..."
cd $TEMP_DIR
tar -czf goquorum-network-light.tar.gz goquorum-qbft-network/

# Transfer the archive to the remote server
echo "Transferring files to remote server..."
sshpass -p "$REMOTE_PASSWORD" scp -o StrictHostKeyChecking=no $TEMP_DIR/goquorum-network-light.tar.gz $REMOTE_USER@$REMOTE_IP:/tmp/

# Execute commands on the remote server
echo "Setting up the lightweight network on the remote server..."
sshpass -p "$REMOTE_PASSWORD" ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_IP << EOF
  # Create the directory if it doesn't exist
  mkdir -p $REMOTE_DIR
  
  # Extract the archive
  tar -xzf /tmp/goquorum-network-light.tar.gz -C $REMOTE_DIR
  
  # Run the setup script
  cd $REMOTE_DIR/goquorum-qbft-network
  ./setup-lightweight.sh
  
  # Verify the deployment
  echo "Verifying the deployment..."
  ./verify-deployment.sh
  
  # Clean up
  rm /tmp/goquorum-network-light.tar.gz
EOF

# Clean up the temporary directory
echo "Cleaning up temporary files..."
rm -rf $TEMP_DIR

echo "Lightweight deployment to new droplet completed successfully!"
echo "Your GoQuorum network is now running on $REMOTE_IP"
echo "RPC Endpoint: http://$REMOTE_IP:22000"

# Update the deployment scripts with the new IP address
echo "Updating deployment scripts with the new IP address..."
cat > ./deploy-to-new-droplet-http.js << EOF
const Web3 = require('web3');
const fs = require('fs');
const path = require('path');

// Connect to the GoQuorum node
const web3 = new Web3('http://$REMOTE_IP:22000');

// Read the SimpleStorage contract source code
const contractSource = fs.readFileSync(path.join(__dirname, 'SimpleStorage.sol'), 'utf8');

// Compile the contract
const solc = require('solc');
const input = {
  language: 'Solidity',
  sources: {
    'SimpleStorage.sol': {
      content: contractSource
    }
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['*']
      }
    }
  }
};

console.log('Compiling the contract...');
const compiledContract = JSON.parse(solc.compile(JSON.stringify(input)));
const contractABI = compiledContract.contracts['SimpleStorage.sol']['SimpleStorage'].abi;
const contractBytecode = '0x' + compiledContract.contracts['SimpleStorage.sol']['SimpleStorage'].evm.bytecode.object;

// Deploy the contract
async function deployContract() {
  try {
    // Get accounts
    const accounts = await web3.eth.getAccounts();
    console.log('Available accounts:', accounts);

    // Deploy the contract
    console.log('Deploying the contract...');
    const contract = new web3.eth.Contract(contractABI);
    const deployTx = contract.deploy({
      data: contractBytecode,
      arguments: [42]  // Initial value for SimpleStorage
    });

    // Estimate gas
    const gas = await deployTx.estimateGas();
    console.log('Estimated gas:', gas);

    // Send the transaction
    const deployedContract = await deployTx.send({
      from: accounts[0],
      gas
    });

    console.log('Contract deployed at address:', deployedContract.options.address);

    // Test the contract
    console.log('Testing the contract...');
    const storedValue = await deployedContract.methods.get().call();
    console.log('Initial stored value:', storedValue);

    // Update the value
    console.log('Updating the stored value...');
    await deployedContract.methods.set(100).send({ from: accounts[0] });

    // Get the updated value
    const updatedValue = await deployedContract.methods.get().call();
    console.log('Updated stored value:', updatedValue);

    console.log('Contract deployment and testing completed successfully!');
  } catch (error) {
    console.error('Error deploying or testing the contract:', error);
  }
}

deployContract();
EOF

echo "Created deployment script for the new droplet: deploy-to-new-droplet-http.js"
echo "You can deploy a test contract to the new network with: node deploy-to-new-droplet-http.js"
