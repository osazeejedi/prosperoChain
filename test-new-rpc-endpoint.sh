#!/bin/bash
set -e

# Configuration
NEW_IP="167.99.207.201"
RPC_ENDPOINT="http://${NEW_IP}:22000"

echo "Testing GoQuorum RPC endpoint at ${RPC_ENDPOINT}..."

# Function to make RPC calls
function call_rpc() {
  local method=$1
  local params=$2
  local result=$(curl -s -X POST -H "Content-Type: application/json" --data "{\"jsonrpc\":\"2.0\",\"method\":\"${method}\",\"params\":${params},\"id\":1}" ${RPC_ENDPOINT})
  echo "$result"
}

# Test 1: Basic connectivity (web3_clientVersion)
echo -e "\n1. Testing basic connectivity (web3_clientVersion):"
call_rpc "web3_clientVersion" "[]"

# Test 2: Block number (eth_blockNumber)
echo -e "\n2. Testing block number (eth_blockNumber):"
call_rpc "eth_blockNumber" "[]"

# Test 3: Node info (admin_nodeInfo)
echo -e "\n3. Testing node info (admin_nodeInfo):"
call_rpc "admin_nodeInfo" "[]"

# Test 4: Accounts (eth_accounts)
echo -e "\n4. Testing accounts (eth_accounts):"
call_rpc "eth_accounts" "[]"

# Test 5: Network ID (net_version)
echo -e "\n5. Testing network ID (net_version):"
call_rpc "net_version" "[]"

# Test 6: Peer count (net_peerCount)
echo -e "\n6. Testing peer count (net_peerCount):"
call_rpc "net_peerCount" "[]"

echo -e "\nRPC endpoint testing completed."
