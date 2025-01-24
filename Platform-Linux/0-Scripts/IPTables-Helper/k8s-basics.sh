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
    "6443"
    "10250"
    "10259"
    "10257"
    "10256" # Worker
)

MULTI_PORT=(
    "2379:2380"
    "30000:32767" # Worker
)
ACTION="ACCEPT"

TRAFFIC_TYPE="tcp"

TABLE="filter"

# Create K8s Chain
iptables -N K8S-GREAT-IN
iptables -N K8S-GREAT-OUT

for mport in "${MULTI_PORT[@]}"; do
    iptables -t $TABLE -A K8S-GREAT-IN -p $TRAFFIC_TYPE -m multiport --dport $mport -j $ACTION
    iptables -t $TABLE -A K8S-GREAT-OUT -p $TRAFFIC_TYPE -m multiport --sport $mport -j $ACTION
done

for port in "${PORT_LIST[@]}"; do
    iptables -t $TABLE -A K8S-GREAT-IN -p $TRAFFIC_TYPE --dport $port -j $ACTION
    iptables -t $TABLE -A K8S-GREAT-OUT -p $TRAFFIC_TYPE --sport $port -j $ACTION
done

# RETURN
iptables -t $TABLE -A GRAYLOG-OUT -j RETURN