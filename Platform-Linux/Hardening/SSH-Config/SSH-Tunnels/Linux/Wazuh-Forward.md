# SSH Tunneling Wazuh Dashboard
## Description
SSH tunneling is a technique that allows us to securely transmit data
from one end point to another.
We will leverage this technique to provide secure communication between SOC 
practicioner and the dashboard without having to worry about password-guessing of the
Wazuh-Dashboard. To get started Wazuh and all its component must habe already been set.

## Concideration
The security of your SSH Tunnels is directly correlated to the security of SSH.
Setup appropriate security measure to verify safe SSH access.

## Steps
### Configuration
```.bash
foo@bar:$ sudo iptables -t nat -L DOCKER -v --line-numbers
foo@bar:$ sudo iptables -t nat -I DOCKER 3 -p tcp --dport 443 -j REDIRECT --to-port 9999
foo@bar:$ sudo iptables -t nat -L DOCKER -v --line-numbers
```
### Putting It To The Test
#### Step 1: SSH Into Wazuh Machine's Tunnel
```.bash 
    foo@bar:$ ssh -L \<port-to-be-used-locally\> localhost:443 \<wazuh-machine-ip\> -p \<port-to-be-used-in-wazuh-machine\>
```
#### Step 2: Access Wazuh Dashboard
Simply go to https://localhost:\<port-to-be-used-locally\>
Here you will be to access Wazuh Dashboard normally.

Joan Montas, SOC.