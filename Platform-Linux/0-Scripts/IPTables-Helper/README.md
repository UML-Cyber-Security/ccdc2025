# IPTables


Some will do some stuff yea

## Add-Both.sh
This script is used in the following manner, with one required argument
```
./ Add-Both.sh <IP-Tables-Rule>
```
This script simply takes the given IPTables rule and adds it to it's respective IPv4 **and** IPv6 Table/Chain 

## List-Table.sh
The script is used in the following manner with one required argument, and one optional.
```
./List-Table.sh <Table-Name> <Chain-Name>
```

The first is the table we wish to print the status of (Default is FILTER), and the second optional argument is the chain we would like to print (Default is all). 

## port-traffic.sh
The script is used in the following manner with three required arguments.
```
./port-traffic.sh <Port> <Protocol> <Jump Target>
```
The script takes a argument for the target destination and source port (Rule for both), the protocol used (udp/tcp mostly) and the target (ACCEPT, DROP, etc). This will add a rule to both the IPv4 and IPv6 tables.

## trusted-ips.sh
The script is used in the following manner with one required arguments.
```
./trusted-ips.sh <Port> <Protocol> <Jump Target>
```
The script takes a argument for a source file containing a newline separated list of IPs, Rules will be added to whitelist those IPs.
