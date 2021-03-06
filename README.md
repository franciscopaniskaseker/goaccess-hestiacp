# Requirements
## setup goaccess
Ubuntu:
```bash
wget -O - https://deb.goaccess.io/gnugpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/goaccess.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/goaccess.gpg] https://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/goaccess.list
sudo apt-get update
sudo apt-get install goaccess
```

Fedora:
```bash
yum install goaccess
```

other distros:
https://goaccess.io/download#distro

# setup this git script

## setup
Just execute:

```bash
sudo bash install.sh USER GROUP /PATH/TO/REPORT/report.html
```

USER means the hestiacp or linux user that you want to own the report.

GROUP means the hestiacp or linux user that you want to set in the report.

/PATH/TO/REPORT/report.html is the PATH of the report.html where the port will be stored.

Example:
```bash
sudo bash install.sh admin admin /home/admin/web/mydomain.com/public_html/report.html
```

The Goaccess report will be stored in "/home/admin/web/mydomain.com/public_html/report.html" under "admin" user and "admin" group.

Notes:
- if you intend to store the report under hestiacp user, the group will have the same name of user.
- if you did some mistake or you want to change the user, group or report.html path, you can (1) just install again (do not need to remove) or (2) edit /etc/goaccess-hestiacp.conf file


## Uninstall procedure

Just execute

```bash
./uninstall.sh
```

# Frequent asked questions (FAQ)
### Where I can find the logs to check eventual errors?
As this is installed using systemd unit, you can check eventual errors in the journalctl:
```bash
journalctl -u goaccess-hestiacp
``` 
or to see the log in real time:
```bash
journalctl -u goaccess-hestiacp -f
```
### Which is the frequency of Goaccess report update?
By default is 60 seconds. You can change this frequency editing the variable update_frequency (in seconds) into the file /etc/goaccess-hestiacp.conf.

Example:
```bash
update_frequency=120
```

This mean 120 seconds.
