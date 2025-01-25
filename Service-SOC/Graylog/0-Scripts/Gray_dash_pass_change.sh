#!/bin/bash
# Script should change the dashboard password for Graylog

read -p "Do you want to generate a new password secret? (generating a password secret will disable all active TOKENS) (y/n): " generate_secret

if [[ "$generate_secret" == "y" ]]; then
    password_secret=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-96};echo;)
fi

echo -n "Enter Password: "
read -s root_password
echo
root_password_sha2=$(echo -n "$root_password" | sha256sum | cut -d" " -f1)

# Update the server.conf file
config_file="/etc/graylog/server/server.conf"
if [[ "$generate_secret" == "y" ]]; then
    sed -i "s/^password_secret =.*/password_secret = $password_secret/" $config_file
fi
sed -i "s/^root_password_sha2 =.*/root_password_sha2 = $root_password_sha2/" $config_file

systemctl restart graylog-server

echo "Configuration updated successfully."