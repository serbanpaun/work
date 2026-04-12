#!/bin/bash
DYNHOST="MY_HOST"
# Website to get our external IP Address
EXTERNAL_WEB="https://ip.ptm.ro/"
# We need to make sure we use our external interface for the request
INTERFACE="eth0"
SSH_USER="MYUSER"
SSH_HOST="MY_DYNDNS_SERVER"
SSH_PORT="22" # Default SSH port is 22
# curl is configured to go through external interface
# Make sure EXTERNAL_WEB website returns only IP Address
# or you need to process IP_ADDRESS to extract it yourself.
IP_ADDRESS=$(/usr/bin/curl -s --interface $INTERFACE $EXTERNAL_WEB)
# SSH Options for remote DYNDNS SERVER connection
OPTIONS="-oConnectTimeout=10 -oBatchMode=yes -oStrictHostKeyChecking=no"
# Optional Debug messages
echo $DYNHOST
echo $IP_ADDRESS
echo "Connecting to remote server..."
# Use sudo if not connecting as root (recommended)
ssh $OPTIONS $SSH_USER@$SSH_HOST -p $SSH_PORT "sudo systemctl start update_dns@${DYNHOST}_${IP_ADDRESS}"
