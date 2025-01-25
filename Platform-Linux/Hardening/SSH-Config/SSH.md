# SSH Config

## Links
https://linuxize.com/post/using-the-ssh-config-file/

https://www.ssh.com/academy/ssh/config

https://www.linuxquestions.org/questions/linux-security-4/securing-ssh-allow-denying-and-match-statements-4175530596/


## Testing 

You should test your SSH configuration before applying, otherwise this may cause issues with regards to us being locked out of the system.

We can use two flags with the `sshd` command:

First we can preform a normal set of syntax error checking
```
$ sudo sshd -t
```
* This is located at `/usr/sbin/sshd`

We can also preform extended testing
```
$ sudo sshd -T
```
* This is located at `/usr/sbin/sshd`


## References  
* https://linux.die.net/man/8/sshd
* https://www.cyberciti.biz/tips/checking-openssh-sshd-configuration-syntax-errors.html