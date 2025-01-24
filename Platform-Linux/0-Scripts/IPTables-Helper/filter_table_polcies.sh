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
POLICY="DROP"

# Set defualt policy of All FILTER Chains
## IPv4
iptables -P INPUT $POLICY
iptables -P FORWARD $POLICY
iptables -P OUTPUT $POLICY

##IPv6
ip6tables -P INPUT $POLICY
ip6tables -P OUTPUT $POLICY
ip6tables -P FORWARD $POLICY