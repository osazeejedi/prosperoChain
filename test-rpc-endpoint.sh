#!/bin/bash
set -e

# Configuration
REMOTE_IP="167.99.87.113"
RPC_URL="http://${REMOTE_IP}:22000"

echo "Testing GoQuorum RPC endpoint at ${RPC_URL}..."

# Function to make RPC calls
function rpc_call() {
  local method=$1
  local params=$2
  local result=$(curl -s -X POST -H "Content-Type: application/json" --data "{\"jsonrpc\":\"2.0\",\"method\":\"${method}\",\"params\":[${params}],\"id\":1}" ${RPC_URL})
  echo "${result}"
}

# Test 1: Basic connectivity - web3_clientVersion
echo -e "\n1. Testing basic connectivity (web3_clientVersion):"
rpc_call "web3_clientVersion" ""

# Test 2: Block number
echo -e "\n2. Testing block number (eth_blockNumber):"
rpc_call "eth_blockNumber" ""

# Test 3: Node info
echo -e "\n3. Testing node info (admin_nodeInfo):"
rpc_call "admin_nodeInfo" ""

# Test 4: Get accounts
echo -e "\n4. Testing accounts (eth_accounts):"
rpc_call "eth_accounts" ""

# Test 5: Network ID
echo -e "\n5. Testing network ID (net_version):"
rpc_call "net_version" ""

# Test 6: Peer count
echo -e "\n6. Testing peer count (net_peerCount):"
rpc_call "net_peerCount" ""

echo -e "\nRPC endpoint testing completed."
echo "If you see JSON responses with 'result' fields, the RPC endpoint is working."
echo "If you see error messages or empty responses, the RPC endpoint is not accessible."
