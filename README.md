# GCE-7days2die
Setup scripts for configuring and managing a 7 days to die server on Google Compute Engine

Google gives you $300 of cloud compute resources to use for 60 days.


## GCE Setup
http://console.cloud.google.com

### Prerequisites
* Google account
* Billing enabled on cloud console

### Create Container Engine


### Configure Network Settings
tcp:26900-26901
udp:26900-26903

### Login and install
The following packages are required:
None

These packages are handy but not required:
```
sudo apt install byobu systat
```
Use the following to download the installer and make it executable
```
wget https://raw.githubusercontent.com/lavinog/GCE-7days2die/master/install.sh`
chmod 755 install.sh
```

The installer has the following default settings:
```
ROLE_ACCT='steam'           # Steam account
APP_ID=294420               # Steam App ID
STEAM_PATH='/opt/steam'     # Steam Path
APP_PATH='/opt/steam/7d2d'  # Application Path
SYSTEMD_SERVICE='game-7d2d' # Location of systemd service config
```
There shouldn't be a need to make changes to these settings, but you can modify them as needed.

Run the installer:
```
./install.sh
```
