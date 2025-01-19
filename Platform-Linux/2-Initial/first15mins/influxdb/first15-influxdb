# InfluxDB2 Security and Setup Guide (First 15 Minutes)

This guide outlines the essential steps to secure and configure InfluxDB2. 
**RWU-CCDC-2025**

# Table of Contents <!-- omit from toc -->
- [InfluxDB2 Security and Setup Guide (First 15 Minutes)](#influxdb2-security-and-setup-guide-first-15-minutes)
  - [Steps](#steps)
    - [1. Identify Database Location](#1-identify-database-location)
    - [2. Create a Token with All Permissions](#2-create-a-token-with-all-permissions)
    - [3. Generate Temporary Certificates for HTTPS/TLS](#3-generate-temporary-certificates-for-httpstls)
      - [Generate a Private Key:](#generate-a-private-key)
      - [Create a Certificate Signing Request (CSR):](#create-a-certificate-signing-request-csr)
      - [Self-Sign the CSR:](#self-sign-the-csr)
    - [4. Add HTTPS Configuration](#4-add-https-configuration)
    - [5. Configure Operator Token](#5-configure-operator-token)
    - [6. Backup Data and Configurations](#6-backup-data-and-configurations)
      - [Backup Current Data:](#backup-current-data)
      - [Backup Current Yaml Configuration:](#backup-current-yaml-configuration)
    - [7. Disable Unknown or Old Tokens](#7-disable-unknown-or-old-tokens)
    - [8. Generate Permanent Certificates for HTTPS/TLS](#8-generate-permanent-certificates-for-httpstls)
      - [Generate a Private Key:](#generate-a-private-key-1)
      - [Create a Certificate Signing Request (CSR):](#create-a-certificate-signing-request-csr-1)
      - [Send CSR to Certificate Authority (CA):](#send-csr-to-certificate-authority-ca)
      - [Receive the Signed Certificate:](#receive-the-signed-certificate)
    - [9. Update Configuration with Permanent Certificates](#9-update-configuration-with-permanent-certificates)


## Steps

### 1. Identify Database Location
Determine the database being used and its location. For this guide, we assume **InfluxDB2** is being deployed.

---

### 2. Create a Token with All Permissions
1. Access the InfluxDB2 UI.
2. Navigate to **Tokens**.
3. Select **Create Token** and assign all necessary permissions.

---

### 3. Generate Temporary Certificates for HTTPS/TLS
#### Generate a Private Key:
```bash
openssl genpkey -algorithm RSA -out influx.key -aes256
chmod 600 influx.key
```
#### Create a Certificate Signing Request (CSR):
```bash
openssl req -new -key influx.key -out influx.csr
chmod 644 influx.csr
```
#### Self-Sign the CSR:
```bash
openssl x509 -req -in influx.csr -signkey influx.key -out influx.crt -days 365
```
---

### 4. Add HTTPS Configuration
Create or update the influx `config.yaml` file:
```bash
vim /etc/influxdb2/config.yaml
```
Add the following configuration:
```yaml
auth-enabled: true
tls-cert: /etc/ssl/certificates/influx.crt
tls-key: /etc/ssl/certificates/influx.key

[logging]
  level: "info"  # Set logging level (info/debug/error)
  file: "/var/log/influxdb/influxd.log"  # Log location

strong-passwords: true
ui-disabled: false
```
---

### 5. Configure Operator Token
Use the new token to create the configuration:
```bash
influx config create --config-name default --org [org-name] -u https://localhost:8086/ --token [your-new-token] --active
```
---

### 6. Backup Data and Configurations
#### Backup Current Data:
You would need to find where influx's data is saved for this infrastructure
```bash
influx backup /path/to/save/data
```
#### Backup Current Yaml Configuration:
```bash
cp current-config.yaml old-config.bak
```
---

### 7. Disable Unknown or Old Tokens
Use the InfluxDB2 UI to disable unknown or outdated tokens. **Do not delete tokens**, as they may be needed later.

---

### 8. Generate Permanent Certificates for HTTPS/TLS
#### Generate a Private Key:
```bash
openssl genpkey -algorithm RSA -out influx.key -aes256
chmod 600 influx.key
```
#### Create a Certificate Signing Request (CSR):
```bash
openssl req -new -key influx.key -out influx.csr
chmod 644 influx.csr
```
#### Send CSR to Certificate Authority (CA):
Submit the CSR to a trusted CA for signing.

#### Receive the Signed Certificate:
Once the certificate is received from the CA, proceed to update your configuration.

---

### 9. Update Configuration with Permanent Certificates
Edit the configuration file to reference the permanent certificate:
```yaml
tls-cert: /etc/ssl/certificates/influx.crt
tls-key: /etc/ssl/certificates/influx.key
```
Update the InfluxDB configuration:
```bash
influx config update --config-name default
```
---


