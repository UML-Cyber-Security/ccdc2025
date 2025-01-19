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

## JournalD

## SSH

## Extras
* **Firewall Reset**: Resets the firewall to a empty allow all state.
* **Firewall Isolation**: Contains scripts to isolate the system on a network level.
* **Gluster Backup**: Setup backups when Gluster is used.
* **Gluster_Setup**: Download Gluster and Configure IPtables rules.
* **remove-ldap**: Remove ldap from Linux system.
* **Firewall Docker**: This sets up firewall rules to log packets sent to docker containers