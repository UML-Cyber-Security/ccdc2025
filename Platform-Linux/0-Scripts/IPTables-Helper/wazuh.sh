###### Wahzuh
## IPv4
iptables -A OUTPUT -p tcp --sport 1514 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 1514 -j ACCEPT

## IPv6
ip6tables -A OUTPUT -p tcp --sport 1514 -j ACCEPT
ip6tables -A OUTPUT -p tcp --dport 1514 -j ACCEPT