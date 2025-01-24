
# Graylog update 

to check versions of graylog with elasticsearch

```bash
dpkg -l | grep -E ".(elasticsearch|graylog|mongo)."
``` 

to check versions of graylog with opensearch
```bash
dpkg -l | grep -E ".(opensearch|graylog|mongo)."
```
![Alt text](<../Images/Screenshot 2025-01-24 at 1.51.30 PM.png>)
example of what you should get when you run the command

### Next:
Run the [Graylog Upgrade](Graylog_upgrade.sh) Script. 

when it asks about the configuration file for Graylog and any service that invovles graylog say yes or y.

![Alt text](<../Images/Screenshot 2025-01-24 at 1.48.01 PM.png>)
 It should look something like this


## CRUCIAL 
### After Upgrade

After the upgrade is done go into the ```/etc/graylog/server/``` directory and edit the ```server.conf``` file. Scroll to the part that says HTTP and re-enter the http_bind_address, http_publish_uri, http_external_uri as shown below. Make sure to uncomment it or it won't connect or load. Make sure to add the port :9000 to the end of everything and the port :9000/ to everything except the bind address.
```bash
 http_bind_address = #(ex. 0.0.0.0:9000)
 http_publish_uri =  #(ex public ip of the master or private ip of the master. ie) public: (192.168.x.x:9000/) private: (10.19.17.56:9000/))
 http_external_uri =  #(ex public ip for private master ie)192.168.4.99:9000/; leave alone if public ip for the master) 
``` 

Then you have options.

Seems to not copy the below information so you need to create another one it seems.

ALSO CAN RUN [Gray_dash_pass script](Gray_dash_pass_change.sh) it does the same thing as below. If you dont do either graylog will fail to start. The script changes/creates the dashboard password for the Graylog UI Dashboard

To create your password_secret, run the following command: 
```bash
< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-96};echo;
```

Then copy into the ```server.conf``` file in ```/etc/graylog/server/```


Use the following command to create your root_password_sha2: 
```bash 
echo -n "Enter Password: " && head -1 </dev/stdin | tr -d '\n' | sha256sum | cut -d" " -f1
```
Then copy into the ```server.conf``` file in ```/etc/graylog/server/```

then run 

```bash
sudo systemctl restart graylog-server
```

```bash
sudo systemctl status graylog-server
```

should be running now. Enjoy Graylog!

