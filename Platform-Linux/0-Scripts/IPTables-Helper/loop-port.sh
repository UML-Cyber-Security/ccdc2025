#! /bin/bash

#********************************
# Written by a sad Matthew Harper...
#********************************

# Check if the scrip is ran as root.
# $EUID is a env variable that contains the users UID
# -ne 0 is not equal zero
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

PORT_LIST=(
    "1"
    "2"
    "3"
)

ACTION="ACCEPT"

TRAFFIC_TYPE="tcp"

TABLE="filter"

CHAIN="INPUT"

for port in "${PORT_LIST[@]}"; do
    iptables -t $TABLE -A $CHAIN -p $TRAFFIC_TYPE --dport $port -j $ACTION
done

