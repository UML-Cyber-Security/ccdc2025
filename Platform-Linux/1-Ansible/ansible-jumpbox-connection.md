There are multiple methods. The method I will be describing will be a method using the inventory file.
All commands will be in the inventory file on the ansible controller

# 1. Define a proxy/jumpbox host
```ini
[proxy]
<ip of proxy> ansible_ssh_user=<username> ansible_ssh_private_key_file=<path/to/privkey>

# 2. Add Machines you wish to connect to through the proxy. 
# I was only able to get this to wor with pubkey authentication setup.
[machines]
<ip of machine 1> ansible_ssh_user=<username> ansible_ssh_private_key_file=<path/to/privkey>
<ip of machine 2> ansible_ssh_user=<username> ansible_ssh_private_key_file=<path/to/privkey>
<ip of machine 3> ansible_ssh_user=<username> ansible_ssh_private_key_file=<path/to/privkey>

[machine:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -i ~/.ssh/ccdc_harvester -p 22 -W %h:%p blueteam@192.168.1.49"'

[all:vars]
ansible_python_interpreter=/usr/bin/python3
# Or where ever your python3 is saved.
```


### Extra command for sshing into machines 
`ssh blueteam@10.0.0.103 -o ProxyCommand="ssh -i /path/to/shhkey__private_key_that_was_placed_in_proxy_machine -p 22 -W %h:%p blueteam@192.168.1.49"`

-W argument tells SSH it can forward stdin and stdout through the host and port, effectively allowing Ansible to manage the node behind the bastion/jump server.



# Test ansible connection
ansible all -m ping -u blueteam -i harvester.ini






### created by a stressed chisom.