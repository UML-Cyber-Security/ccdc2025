# How to Disable (Remove) All Existing Tokens and Create a New Admin Token in InfluxDB 2.x

In **InfluxDB 2.x**, tokens are the primary method of authentication and authorization. You can’t technically “disable” a token in-place, but you can **delete** existing tokens and create a new one with **admin privileges**.

Below is a **two-step approach**:

1. **Create a new privileged (admin) token** (so you don’t lock yourself out).  
2. **Remove (delete) all other tokens**.

> **Important**: This process will permanently remove any tokens used by services or applications. Make sure to **update** those services with the new token or they will lose access.

---

## 1. Create a New Admin Token

Use the Influxdb CLI to create an **all-access** token. You’ll need to specify:
- Your **organization** name or ID.
- The **authentication** you currently have (e.g., an existing admin token or user credentials).

For example:

```bash
# Use your existing admin token or username/password if your CLI is configured accordingly.
# This creates a new token with full privileges ("--all-access").
influx auth create \
  --org MyOrg \
  --all-access \
  --description "New Master Admin Token"
```

## 2. Remove All Existing Tokens
Now that you have a fresh admin token, you can delete all old tokens. This effectively disables them since they no longer exist.

1. List All Tokens:
- Use your NEW token to authenticate
`influx auth list --org MyOrg --host http://localhost:8086 --token '<NEW_TOKEN>'`

You’ll get a table of tokens. Each token has an ID in the first column.

2.Delete Each Token by ID:

- Example deleting a specific token by ID
`influx auth delete --id <TOKEN_ID> --host http://localhost:8086 --token '<NEW_TOKEN>'`
----
There is a token delete and master token creation script in the repo.

