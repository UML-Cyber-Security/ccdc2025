# Graylog First 15 #
WHAT THIS IS:  
Steps to do and complete during the first 15 minutes

## 1. Locate Network Inventory Sheet ##
- At least write system info down if sheet is n/a
- Nmap here if needed
- Run `Inital-Backup.sh`

## 2. Initial Audit ##
- Run basic scan `Init_Audit.sh`
- Add information to network inventory sheet

## 3. New user ##
```bash
sudo useradd blueteam
```
```bash
sudo usermod -aG sudo blueteam``` or ```sudo usermod -aG wheel blueteam
```

## 4. SSH keys ##
- ```ssh-keygen```
- Add to keys file and confirm key is working

## 5. Passwords ##
- Change all passwords on the machine

## 6. Run setup scripts ##
- Run all (0-5) initial setup scripts.

## 7. Secondary Audit ##
- Run verbose `Init_Audit.sh`
- Fix stuff, lock users (`sudo usermod -L <user>`), WRITE DOWN BAD STUFF FOUND!S

## 8. Antivirus ##
Refer to the `SOC Sheet` for commands to properly run everything isntalled.  
ClamAV: 
```bash
sudo apt-get install clamav clamav-daemon -y
or 
sudo dnf install clamav clamav-daemon -y
```
```bash
sudo freshclam
sudo systemctl start clamav-freshclam
```
Debsums
```bash
sudo apt-get install debsums -y
```
LinPEAS (use wget OR curl, not both)
```bash
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
```
```bash
curl -LO https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
```