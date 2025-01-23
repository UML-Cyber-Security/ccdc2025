#! /bin/bash
users=(
    "mhbteam"
    "cubteam"
    "sdbteam"
    "aebteam"
    "jbbteam"
    "dbbteam"
    "rpbteam"
    "tlbteam"
    "jtbteam"
    "vabteam"
    "prbteam"
    "rwbteam"
)
ssh_keys=(
    ""
    ""
    ""
    ""
    ""
    ""
    ""
    ""
    ""
)

echo "[!] Creating Alternative Sudo Group [!]"
groupadd Minecraft-User

tpass="1qazxsW@1" #EDIT DEFAULT PASSWORD

. /etc/os-release

echo "[!] Creating Team Users [!]"
for user in "${users[@]}"; do
    useradd -m -s /bin/bash $user
    if [[ "$ID" == "debian" || "$ID" == "ubuntu" || "$ID" == "linuxmint" || "$ID" == "raspbian" ]]; then
        usermod -aG sudo $user
    elif [[ "$ID" == "rhel" || "$ID" == "centos" || "$ID" == "fedora" || "$ID" == "rocky" || "$ID" == "alma" ]]; then
        usermod -aG wheel $user
    fi
    usermod -aG Minecraft-User $user
    echo "$user:$tpass" | chpasswd
    passwd -l $user
    mkdir /home/$user/.ssh
    for ssh_key in "${ssh_keys[@]}"; do
        echo $ssh_key >> /home/$user/.ssh/authorized_keys
    done
    chown $user:$user /home/$user/.ssh
    chown $user:$user /home/$user/.ssh/authorized_keys
done

echo "[!] Created Users, Unlock Those That Will Be Used [!]"
echo "[!!] Use \`passwd -u username\` to unlock the users [!!]"

