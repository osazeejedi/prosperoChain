#!/bin/bash
set -e

echo "Generating configurations for 5 nodes..."

# Create genesis file with 5-node extradata
extraData=$(grep "5node" qbft-extradata.txt | cut -f2 -d ":")
sed "s/\"extraData\": \".*\"/\"extraData\": $extraData/" qbft-genesis.json > qdata/genesis.json

# Create static-nodes.json and permissioned-nodes.json
cat > qdata/static-nodes.json << EOF
[
  "enode://ac6b1096ca56b9f6d004b779ae3728bf83f8e22453404cc3cef16a3d9b96608bc67c4b30db88e0a5a6c6390213f7acbe1153ff6d23ce57380104288ae19373ef@node-0:21000?discport=0",
  "enode://0ba6b9f606a43a95edc6247cdb1c1e105145817be7bcafd6b2c0ba15d58145f0dc1a194f70ba73cd6f4cdd6864edc7687f311254c7555cc32e4d45aeb1b80416@node-1:21000?discport=0",
  "enode://579f786d4e2830bbcc02815a27e8a9bacccc9605df4dc6f20bcc1a6eb391e7225fff7cb83e5b4ecd1f3a94d8b733803f2f66b7e871961e7b029e22c155c3a778@node-2:21000?discport=0",
  "enode://3d9ca5956b38557aba991e31cf510d4df641dce9cc26bfeb7de082f0c07abb6ede3a58410c8f249dabeecee4ad3979929ac4c7c496ad20b8cfdd061b7401b4f5@node-3:21000?discport=0",
  "enode://3701f007bfa4cb26512d7df18e6bbd202e8484a6e11d387af6e482b525fa25542d46ff9c99db87bd419b980c24a086117a397f6d8f88e74351b41693880ea0cb@node-4:21000?discport=0"
]
EOF

cp qdata/static-nodes.json qdata/permissioned-nodes.json

# Copy configurations to each node
for i in {0..4}
do
  cp qdata/genesis.json qdata/node-$i/dd/
  cp qdata/static-nodes.json qdata/node-$i/dd/
  cp qdata/permissioned-nodes.json qdata/node-$i/dd/
done

# Create Tessera config for each node
for i in {0..4}
do
  cat > qdata/node-$i/tessera-config.json << EOF
{
  "useWhiteList": false,
  "jdbc": {
    "username": "sa",
    "password": "",
    "url": "jdbc:h2:./qdata/tm/db;TRACE_LEVEL_SYSTEM_OUT=0",
    "autoCreateTables": true
  },
  "serverConfigs":[
    {
      "app":"ThirdParty",
      "enabled": true,
      "serverAddress": "http://tessera-$i:9080",
      "cors": {
        "allowedMethods": ["GET", "OPTIONS"],
        "allowedOrigins": ["*"]
      },
      "communicationType": "REST"
    },
    {
      "app":"Q2T",
      "enabled": true,
      "serverAddress": "unix:/qdata/tm.ipc",
      "communicationType": "REST"
    },
    {
      "app":"P2P",
      "enabled": true,
      "serverAddress": "http://tessera-$i:9000",
      "communicationType": "REST"
    }
  ],
  "peer": [
EOF

  # Add peers
  for j in {0..4}
  do
    if [ $i -ne $j ]; then
      # Add comma after each entry except the last one
      is_last=false
      if [ $j -eq 4 ] || ([ $j -eq 3 ] && [ $i -eq 4 ]) || ([ $j -eq 2 ] && [ $i -eq 3 ]) || ([ $j -eq 1 ] && [ $i -eq 2 ]) || ([ $j -eq 0 ] && [ $i -eq 1 ]); then
        is_last=true
      fi
      
      cat >> qdata/node-$i/tessera-config.json << EOF
    {"url": "http://tessera-$j:9000"}$([ "$is_last" = false ] && echo "," || echo "")
EOF
    fi
  done

  cat >> qdata/node-$i/tessera-config.json << EOF
  ],
  "keys": {
    "passwords": [],
    "keyData": [
      {
        "privateKeyPath": "/qdata/tm.key",
        "publicKeyPath": "/qdata/tm.pub"
      }
    ]
  },
  "alwaysSendTo": []
}
EOF
done

# Genesis initialization will be done in the Docker container's entrypoint
echo "Genesis initialization will be done when the containers start..."

echo "Configurations generated successfully!"
