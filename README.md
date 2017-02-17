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
sudo apt install byobu sysstat

```
At this point it is recommended that you start byobu so that if you get disconnected, it wont terminate your session.
```
byobu
```

Use the following to download the installer and make it executable
```
wget https://raw.githubusercontent.com/lavinog/GCE-7days2die/master/install.sh
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
The installer will do the following:
1. Create the role account
2. install steamcmd
3. use steamcmd to download the 7d2d server package
4. Configure a systemd config file and enable the server to be autostarted.

To prevent the server from auto starting use the following command:
```
sudo systemctl disable game-7d2d
```

To reenable the auto start:
```
sudo systemctl enable game-7d2d
```
To manually start the server:
```
sudo systemctl start game-7d2d
```
And to stop it:
```
sudo systemctl stop game-7d2d
```

It is recommended that you edit the serverconfig.xml file located in the game folder before starting it.
Since it is writable only by the role account you will need to use sudo to edit it:
```
sudo nano /opt/steam/7d2d/serverconfig.xml
```



