## Ansible Wazuh Agent Deployment (Linux) ##
What this is:  
Short guide showing on how to deploy Wazuh agent, default Windows and custom Linux with Ansible. This was done on a UBUNTU machine.  

Playbook - List of commands that are sent out to the managed nodes?? <br>
Inventory File - List of machines w/ IP adress plus login info that playbook commands will run on

### Installation ###  
Below is guide for Linux Ubuntu

#### Important: copy over your key to all machines??? ####
For control node: Python 3.8 or newer required <br>
For managed node: Python 2.6 or newer <br>
ALL Linux based systems <br> 

1. Update ansible Personal Package Archive 
```bash
sudo add-apt-repository --yes --update ppa:ansible/ansible
```
3. Install Ansible
```bash
sudo apt install ansible
```
5. Can verify installation w/ 
```ansible --version```

### Add Keys to Machines ###

```ssh-keygen -t rsa -b 2048```
Can copy the keys over with:  
```ssh-copy-id username@remote_host```

### Clone Wazuh Ansible Repo ###

```
cd /etc/ansible/roles/
sudo git clone --branch v4.9.1 https://github.com/wazuh/wazuh-ansible.git
ls
```
Output: `wazuh-ansible`

### Install the Agents ###

1. Edit ansible wazuh-agent role file:  
```sudo nano /etc/ansible/roles/wazuh-ansible/playbooks/wazuh-agent.yml```  
Change `hosts` to your linux hosts, `wazuh-linux` and `wazuh manager address` to the Wazuh manager IP.

2. Add agents to `hosts` file (/etc/ansible/hosts)
```
[wazuh-linux]
test1 ansible_host=192.168.2.94 ansible_ssh_user=blueteam
test2 ansible_host=192.168.3.53 ansible_ssh_user=blueteam
# etc..
```

3. Add custom Linux agent install .yml
Replace the ```/etc/ansible/roles/wazuh-ansible/roles/wazuh/ansible-wazuh-agent/defaults/main.yml``` with the one in the repo:  
`Wazuh/1-Ansible/main.yml`.  

Replace the ```/etc/ansible/roles/wazuh-ansible/roles/wazuh/ansible-wazuh-agent/templates/var-ossec-etc-ossec-agent.conf.j2``` with the one in the repo:
`Wazuh/1-Ansible/var-ossec-etc-ossec-agent.conf.j2`.  


3. Run the Playbook
```
cd /etc/ansible/roles/wazuh-ansible/playbooks
ansible-playbook wazuh-agent.yml -b -K
```
Install Windows agents manually...
