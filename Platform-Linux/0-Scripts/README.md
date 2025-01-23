# Scripts
This directory contains various bash scripts to configure our Linux systems and verify various aspects of them. The should be run in a specific order to prevent the system logs from being flooded, though most of these can be ran in any order. They are listed in the order they are meant to run and are prepended with a number. The [Extras](#extras) section contains notes on additional scripts.

## Initial Backup
* **User History**: All user histories will be backed up to */backups/user-histories*. This goes through all home directories, and copies them with an associative name.
* **SSH**: The sshd_config is stored at */backups/configs/sshd_config.backup* with the ending .backup (As you can see).
* **PAM**: The Pam directory and initial conf is stored at */backups/configs/pam*
* **Firewall**: Old Firewall rules will be stored at */backups/firewall/* or in the case of ufw at */backups/configs/ufw*.
* **Crontab**: The */var/spool/cron/crontabs* directory is copied to */backups/configs/crontabs*.
* **Logs**: The */var/log* directory is backed up to */backups/logs*.
* **netplan**: The netplan is backed up to */backups/netplan*.
* **shadow**: In-place backup to */etc/shadow.bak*.
* **passwd**: In-place backup to */etc/passwd.bak*.
* **gshadow**: In-place backup to */etc/gshadow.bak*.
* **group**: In-place backup to */etc/group.bak*.

## Verify Packages
This script will verify some core packages we use (can be expanded), we could use the `dpkg --verify` or `rpm -Va` to validate *all* packages on the system. This is not immediately done as this can take a bit of time (1 - 2 min).

The [`debsum`](https://manpages.ubuntu.com/manpages/trusty/man1/debsums.1.html) can be used on *Debian* systems to validate all packages.

## Set Permissions
This script ensures various files have the proper permissions set to prevent unauthorized users from accessing critical files. Because we likely want permissions on the shadow files to not be allow all. Granted most of the files would not work properly if they do not have the proper permissions, so this is more paranoia.

## Firewall
These scripts install iptables, which is the firewall we will be using, additionally we will use this to provide an initial configuration.

### Logging
Currently there is additional logging for SSH-INITAL connections,  INVALID packets (indicative of a scan), and ICMP-FLOOD packets (possible)

* SSH-INITAL will result in logs prefixed at log-level 5 (Notice) with
  * "IPTables-SSH-INITIAL: "
* INVALID packets will result in logs prefixed at log-level 4 (Warning) with
  * "IPTables-INVALID-LOG: "
* ICMP-FLOOD will result in logs prefixed at log-level 4 (warning) with
  * "IPTables-ICMP-FLOOD: "
* Traffic to Docker containers will result in logs prefixed at log-level 5 (Notice) with
  * "IPTables-DOCKER-LOG:"

### INPUT Chain
* Allows all established connections (Established,Related)
* Allows inbound https connections (443) -- if the system is not hosing a web server this should be removed
* Allows Communications on loopback
* Disallows 127.0.0.0/8 traffic on interfaces other then lo
* Allows DNS, port 53
  * Does not allow zone transfers (port 53 over tcp), may be necissary if we are running a DNS server.
* Accept unreachable destination (3), time exceeded (11) and bad ip header (12) ICMP for IPv4
* Accept ICMPv6 types 1,2,3,4,128,129,130,131,132,133,134,135,136,141,142,143,148,149,151,152,153. Which are described as necessary for IPv6 to function.


If we need to enable zone transfers we would need to do the following:
```sh
# DNS Zone Transfers
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
ip6tables -A INPUT -p tcp --dport 53 -j ACCEPT
```
### ICMP
Ping is not automatically allowed (over IPv4). uncomment the following in the scrip to remove this. You can also run them manually
``` sh
# Ping rules
iptables -A INPUT -m conntrack -p icmp --icmp-type 0 --ctstate NEW,ESTABLISHED,RELATED -j ICMP-FLOOD
iptables -A INPUT -m conntrack -p icmp --icmp-type 8 --ctstate NEW,ESTABLISHED,RELATED -j ICMP-FLOOD
```

IPv6 needs a large number of ICMPv6 packets enabled to function properly.

### Established.
Established connections are automatically allowed. Comment the following in the script to remove it
```
# Allows incoming connections from established outbound connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

### Outbound
* Allows outbound SSH (responses and new conns), logs new connections
* Allows DNS (requests and responses) quires and zone transfers
* Allows loopback interface traffic
* Allows HTTP, and HTTPS requests and responses
* Allows Wahzuh (port 1514)
* ICMP as in inbound

### Rules are saved using IPTables-persistance
This means there can be conflict with ufw.

## Install Remove

## AuditD
This script configures a number of auditd rules to log various events on the system. Below are some of the events and the keys associated with them.

> [!NOTE]
> Use `ausearch -k <TAG> -i` to find logs associated with a given event.

* `time-change`
  * This is any time changes or commands used to change the time on the machine
* `system-locale`
  * Changes to hostname, domainname
  * Changes to /etc/issues(.net)
  * Changes to /etc/hosts
  * Changes to /etc/network
* `MAC-policy`
  * if apparmor is enabled it will be watched
* `logins`
  * /var/log/faillog write and attribute change (chmod)
  * /var/log/lastlog
  * /var/log/tallylog
  * /var/log/wtmp
  * /var/log/btmp
  * /etc/login.defs
  * /etc/securetty
* `session`
  * /var/run/utmp
* `perm_mod`
  * Any changes to permissions
* `access`
  * Any unauthorized access attempts are logged
* `mounts`
  * Log any successful file system mounts
* `delete`
  * File deletion events
* `scope`
  * Changes to sudoers or sudoer.d files/dirs
  * /etc/sudoers: Changes to sudoers file
* `sudo_log`
  * Log all commands run as root where the actual user id is > 1000
* `modules`
  * /sbin/insmod (execute)
  * /sbin/rmmod
  * /sbin/modprobe
  * Initalizing and deleting module (syscalls)
* `Cron`
  * /var/spool/atspool: creation of at rules
  * /etc/at.allow: Editing of at allow list
  * /etc/at.deny: Editing of at deny list
  * /etc/cron.allow: Editing of cron allow list
  * /etc/cron.deny: Editing of cron deny list
  * /etc/cron.d/: Editing of cron.d directory (file creation ect)
  * /etc/cron.monthly/: Monthly cron jobs (Not important)
  * /etc/cron.weekly/: Weekly (not important)
  * /etc/cron.daily/: Daily cron job editing (not super relevant)
  * /etc/cron.hourly/: Hourly cron jobs
  * /etc/crontab: Edits
  * /var/spool/cron/root: Changes to root crontab
* `user_groups`
  * /etc/group: Changes to groups file
* `user_passwd`
  * /etc/passwd: Changes to passwd file
* `user_shadow`
  * /etc/shadow: Changes to the shadow file
* `passwd_modification`
  * /usr/bin/passwd: Changing of passwords
* `group_modification`
  * /usr/sbin/groupadd
  * /usr/sbin/groupmod
  * /usr/sbin/addgroup
* `user_modification`
  * /usr/sbin/useradd
  * /usr/sbin/userdel
  * /usr/sbin/usermod
  * /usr/sbin/adduser
* `rootkey`
  * /root/.ssh: Changes to root ssh key
* `systemd`
  * /bin/systemctl: systemctl command
  * /etc/systemd/: Systemd configurations (long lived)
  * /usr/lib/systemd
* `pam`
  * /etc/pam.d/
  * /etc/security/limits.conf
  * /etc/security/limits.d
  * /etc/security/pam_env.conf
  * /etc/security/namespace.conf
  * /etc/security/namespace.d
  * /etc/security/namespace.init
* `priv_esc`
  * /bin/su
  * /usr/bin/sudo: We do have a rule to catch euid=0 what about sudo -u \<user\>
* `susp_activity`
  * /usr/bin/wget
  * /usr/bin/curl
  * /usr/bin/base64
  * /bin/nc
  * /bin/netcat
  * /usr/bin/ncat
  * /usr/bin/ss
  * /usr/bin/netstat
  * /usr/bin/ssh
  * /usr/bin/scp
  * /usr/bin/sftp
  * /usr/bin/ftp
  * /usr/bin/socat
  * /usr/bin/wireshark
  * /usr/bin/tshark
  * /usr/bin/rawshark
* `T1219_Remote_Access_Tools`
  * /usr/bin/rdesktop
  * /usr/local/bin/rdesktop
  * /usr/bin/wlfreerdp
  * /usr/bin/xfreerdp
  * /usr/local/bin/xfreerdp
  * /usr/bin/nmap
* `sbin_susp`
  * /sbin/iptables
  * /sbin/ip6tables
  * /sbin/ifconfig
  * /usr/sbin/arptables
  * /usr/sbin/ebtables
  * /sbin/xtables-nft-multi
  * /usr/sbin/nft
  * /usr/sbin/tcpdump
  * /usr/sbin/traceroute
  * /usr/sbin/ufw
* `susp_shell`
  * /bin/rbash
  * /bin/open
  * /usr/local/bin/xonsh
  * /bin/xonsh
  * /bin/tclsh
  * /bin/tcsh
  * /bin/fish
  * /bin/csh
  * /bin/ash
## Rsyslog
Install and Setup rsyslog in addition to providing a basic configuration for *rsyslog*. Once installed it will be enabled, configure file creation mode to be `640`
## JournalD
This script configures journald to forward logs to rsyslog, compress large files before forwarding them to rsyslog, and write the files to disk for persistence.
## SSH
Provide basic and somewhat over the top SSH configurations.

1. Configure to use Version 2 of SSH.
2. Configure VERBOSE logging.
3. Disable X11 Forwarding (**DANGER**).
4. Set Max Auth Attempts to 4 (slow brute forcing).
5. Ignore RHosts.
6. Disable HostBased Authentication.
7. Disable root login.
8. Disable PermitUserEnvironment.
9. Disallow the use of empty passwords.
10. ClientAliveInterval set to 5 min. Allows disconnects for ~5 min.
11. ClientAliveCountMax set to 0 (any failed is a disconnect).
12. LoginGrace set to 1 min.
13. Enable PAM
14. Commented out DisableTCP Forwarding.
15. Max Startups limit number of connections before randomly dropping unauthenticated connections.
16. Max sessions limit number of active sessions per ssh connection (10 tmux, etc).
17. Configure Ciphers, MAC and KEX algorithms (common best practices)

## Accounts
Creates accounts for each team member and a new group for them. `First Initial | Last Initial | bteam`, for example Jon Doe would be `jdbteam`.

> [!IMPORTANT]
> Edit file to add SSH keys. TEST YOUR CONNECTION.

## Sudo
Configures *sudo commands* to be executed in pty terminals stopping obscure exploits that fork off or hijack ssh tty terminals and to execute processes as root and persist when the original sudo command exists.

## Extras
* **firewall-reset**: Resets the firewall to a empty allow all state.
* **firewall-isolation**: Contains scripts to isolate the system on a network level.
* **firewall-docker**: This sets up firewall rules to log packets sent to docker containers
* **list-suid-binary**: Search system for SUID binaries. *Linpeas* will give better output but this is meant to be short and simple.
* **list-users**: A quick script to list all sudo users and non-system users.
* **query-users**: Iterate over all non system users with `bash` or `sh` set as their shell, ask user if we should delete, lock, or ignore the user.
* **remove-ldap**: Uninstall LDAP.
* **ssh-non-standard**: Configure SSH and Firewall for non-standard port.
* **gluster-backup**: Setup backups when Gluster is used.
* **gluster-setup**: Download Gluster and Configure IPtables rules.
* **teleport-config**: Configure teleport in a quick and sane manner.
* **Docker-Helper**: Contains scripts for basic Quality of Life Docker things
  * **docker-install**: Old Docker engine install script.
  * **firewall-docker**: Configure firewall to support *Docker SWARM*.
  * **inspect-all-containers**: Inspect all containers save results to files (in directory command is run).
    * running-containers.log
    * Inspect-Outputs
    * networks.log
    * images.log
    * all-containers-summaried.log
  * **install-editors**: Install editor on Docker container (manual configurations and changes post up-time?).
  * **post-install-script**: Create Docker group and add user to it.
  * **shell**: Launch shell in given container id.
* **EasyRSA-CA**: Easy RSA setup and use scripts
  * **setup-ca-server**: Configure easyRSA
  * **create-certificate**: Generate a certificate
* **Firewall-Isolation**: Contains scripts for isolating a machine, and for clearing the isolation rules.
  * **isolation**: Isolate the system.
  * **clean-isolation**: Clear isolation rules.
* **Gluster-Backup**: Deprecated scripts for creating backups of data handled by Gluster.
* **Gluster-Setup**: Deprecated scripts for setting up Gluster.
* **HealthChecks**: Scripts to be executed or ran to get a baseline of the system or generate logs for SIEM.
  * **echo-core-service**: Echo results of core service checks to stdout.
  * **log-coreservice**: Uses logger to write results of healthchecks to syslog. Maybe messages.