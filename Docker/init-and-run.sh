#!/bin/sh

SESSION_KEY_FILE="/session/.session_key"
NODE_NAME="$1"

# One-time initialization
if [ ! -f "$SESSION_KEY_FILE" ] || [ ! -s "$SESSION_KEY_FILE" ]; then
  echo "Session key not found. Starting rotate_keys_docker.sh"
  ./rotate_keys_docker.sh

  # We need to start the server first and query the session key in the background
  (
    sleep 10

    result=$(curl -s -H "Content-Type: application/json" \
      --data '{"jsonrpc":"2.0", "method":"author_rotateKeys", "params":[], "id":1}' \
      http://localhost:9944 | jq -r '.result')

    if [ -n "$result" ]; then
      echo "$result" > "$SESSION_KEY_FILE"
      echo "$SESSION_KEY_FILE created."
    fi
  ) &
fi

# Start the main application
/app/argochain --chain minervaRaw.json --base-path /var/opt/argochain --port 30333 --rpc-port 9944 --telemetry-url "wss://telemetry.polkadot.io/submit/ 0" --name "$NODE_NAME" --validator --rpc-methods Unsafe --unsafe-rpc-external --rpc-max-connections 100 --rpc-cors all
