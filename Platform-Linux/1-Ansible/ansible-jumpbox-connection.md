# Anisble Jumpbox connection
**Author**: Chisom
---

There are multiple methods. The method I will be describing will be a method using the inventory file.
All commands will be in the inventory file on the ansible controller


## 1. Define a proxy/jumpbox host
This belongs in the inventory file.
An inventory file is a .ini that specifies the machines that ansible will connect to. You can specify machine groups as listed below(ex. "proxy", "machines"). You can also specify certain variables(commands) that relate to machine groups. In this case, these varaibles specifies how ssh will connect to the group "machines".

```ini
[proxy]
<ip of proxy> ansible_ssh_user=<username> ansible_ssh_private_key_file=<path/to/privkey>

# 2. Add Machines you wish to connect to through the proxy. 
# I was only able to get this to work with pubkey authentication being already setup.
[machines]
<ip of machine 1> ansible_ssh_user=<username> ansible_ssh_private_key_file=<path/to/privkey>
<ip of machine 2> ansible_ssh_user=<username> ansible_ssh_private_key_file=<path/to/privkey>
<ip of machine 3> ansible_ssh_user=<username> ansible_ssh_private_key_file=<path/to/privkey>

[machine:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -i <path/to/privkey/in/proxy/machine> -p <ssh-port> -W %h:%p <remote user>@<remote-ip>"'
ex: ansible_ssh_common_args='-o ProxyCommand="ssh -i ~/.ssh/ccdc_harvester -p 22 -W %h:%p blueteam@192.168.1.49"'
# These commands are applied specifically to ansible's ssh connection, and slightly change the properties of how it connects. In the case, it tells ansible that it will be jumping through a machine to to another machine to run the specified playbook

[all:vars]
ansible_python_interpreter=/usr/bin/python3
# Or where ever your python3 is saved.
```

## 2. Test ansible connection
ansible all -m ping -u blueteam -i harvester.ini

### Command for directly sshing into machines using a proxy
`ssh blueteam@10.0.0.103 -o ProxyCommand="ssh -i /path/to/shhkey__private_key_that_was_placed_in_proxy_machine -p 22 -W %h:%p blueteam@192.168.1.49"`
This command allows you to ssh using a jumpbox. There are other ways to do this i.e using the ssh -j command.
(Extra info)

-W %h:%p: Tells the SSH proxy on 192.168.1.49 to forward traffic directly to the destination host and port (%h and %p expand to 10.0.0.103 and its default SSH port 22, in this case)
    %h host
    %p port