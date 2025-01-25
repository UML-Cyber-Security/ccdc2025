#!/bin/bash

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

CONFIG_FILE="/etc/graylog/server/server.conf"
NODE_ID_FILE="/etc/graylog/server/node-id"

if [[ -f $CONFIG_FILE ]]; then
  echo "Extracting specific lines from $CONFIG_FILE:"
  grep -E "^(node_id_file|password_secret|http_bind_address|http_publish_uri|http_external_uri|http_enable_tls) =" $CONFIG_FILE
else
  echo "Error: Configuration file $CONFIG_FILE does not exist."
  exit 1
fi

echo

if [[ -f $NODE_ID_FILE ]]; then
  echo "Contents of $NODE_ID_FILE:"
  cat $NODE_ID_FILE
else
  echo "Error: Node ID file $NODE_ID_FILE does not exist."
  exit 1
fi
