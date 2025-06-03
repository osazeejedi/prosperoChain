#!/bin/bash
set -e

echo "Generating keys for 5 nodes..."

# Create directories
mkdir -p qdata/logs
echo "5" > qdata/numberOfNodes

# Copy necessary files from quorum-examples
cp ../quorum-examples/examples/7nodes/qbft-extradata.txt . || cp ../../quorum-examples/examples/7nodes/qbft-extradata.txt .
cp ../quorum-examples/examples/7nodes/qbft-genesis.json . || cp ../../quorum-examples/examples/7nodes/qbft-genesis.json .
cp ../quorum-examples/examples/7nodes/passwords.txt . || cp ../../quorum-examples/examples/7nodes/passwords.txt .

# Create directories for each node
for i in {0..4}
do
  mkdir -p qdata/node-$i/{dd,logs}
  mkdir -p qdata/node-$i/dd/{geth,keystore}
done

# Copy keys from quorum-examples (using keys 1-5 for our 5 nodes)
for i in {0..4}
do
  j=$((i+1))
  
  # Try both possible paths for the quorum-examples repository
  if [ -f "../quorum-examples/examples/7nodes/keys/key$j" ]; then
    REPO_PATH="../quorum-examples"
  elif [ -f "../../quorum-examples/examples/7nodes/keys/key$j" ]; then
    REPO_PATH="../../quorum-examples"
  else
    echo "Error: Could not find quorum-examples repository. Please make sure it's cloned at ../quorum-examples or ../../quorum-examples"
    exit 1
  fi
  
  cp "$REPO_PATH/examples/7nodes/keys/key$j" qdata/node-$i/dd/keystore/
  cp "$REPO_PATH/examples/7nodes/raft/nodekey$j" qdata/node-$i/dd/geth/nodekey
  cp "$REPO_PATH/examples/7nodes/keys/tm$j.key" qdata/node-$i/tm.key
  cp "$REPO_PATH/examples/7nodes/keys/tm$j.pub" qdata/node-$i/tm.pub
  cp passwords.txt qdata/node-$i/
done

echo "Keys generated successfully!"
