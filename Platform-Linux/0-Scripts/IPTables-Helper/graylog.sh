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
    "443"
    "9515"
    "514"
    "1514"
    "4739"
    "5044"
    "5555"
    "9000"
    "27017"
)

ACTION="ACCEPT"

TRAFFIC_TYPE="tcp"

TABLE="filter"

# Create K8s Chain
iptables -N GRAYLOG-IN
iptables -N GRAYLOG-OUT

for port in "${PORT_LIST[@]}"; do
    iptables -t $TABLE -A GRAYLOG-IN -p $TRAFFIC_TYPE --dport $port -j $ACTION
    iptables -t $TABLE -A GRAYLOG-OUT -p $TRAFFIC_TYPE --sport $port -j $ACTION
done

# RETURN
iptables -t $TABLE -A GRAYLOG-OUT -j RETURN
iptables -t $TABLE -A GRAYLOG-IN -j RETURN

# RETURN
iptables -t $TABLE -A INPUT -j GRAYLOG-IN
iptables -t $TABLE -A OUTPUT -j GRAYLOG-OUT
