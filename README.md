# GCE-7days2die
Setup scripts for configuring and managing a 7 days to die server on Google Compute Engine

Google gives you $300 of cloud compute resources to use for 1 year.


## GCE Setup
http://console.cloud.google.com

### Prerequisites
* Google account
* Billing enabled on cloud console

### Create Container Engine


### Configure Network Settings
In order for the server to be visible in the server list, you will need to create a firewall rule in the networking section of the instance:

Field|Setting
---|---
Name|gameconnection
Description|Ports for 7d2d connection and server query
Network|default
Source filter|Allow from any source (0.0.0.0/0)
Allowed protocols and ports|tcp:26900-26901; udp:26900-26903

### Login and install
Start a SSH session throught the GCE interface

#### Install byobu
It is recommended that you install [byobu](http://byobu.co/) so that if you get disconnected, it won't terminate your session.
```
sudo apt update
sudo apt install byobu
byobu
```
*Note, you can detach byobu with F6 and get help with F1*

#### Install dependencies
The following packages are required:
* unzip
* lib32gcc1
* telnet
* netcat
* wget
* curl

In addition, the following is also recommended, but not required:
* bash-completion
* vmtouch - can be used to read save files into memory.

```
sudo apt update
sudo apt -y install unzip lib32gcc1 telnet netcat bash-completion wget curl

```

#### Download and run installer
Use the following to download the repository and extract
```
wget https://github.com/lavinog/GCE-7days2die/archive/master.zip
unzip master.zip

```
Change to the new folder
```
cd GCE-7days2die-master
```


The installer uses the settings found in ./config/7daystodie.conf
The default base folder is /opt/7DaysToDie
And the application is ran by a 'steam' user
There shouldn't be a need to make changes to these settings, but you can modify them as needed.

Run the installer:
```
bash install.sh
```
*Note that you need to prefix it with bash since it is not executable.*
*You could also make it executable, but it is not necessary*


The installer will do the following:

1. Create the role account
2. Create the folder structure
3. Copy the scripts to the folder structure
4. Link the config file to /etc/7daystodie.conf
5. Ensure the dependencies are installed
6. Install steamcmd
7. Use steamcmd to download the 7d2d server package
8. Copy the default serverconfig.xml to the config folder and set the SaveGameFolder setting.
9. Configure a systemd config file and enable the server to be autostarted.

It is recommended that you edit the server config file using:
   ```
   nano /opt/7DaysToDie/config/serverconfig.xml
   ```

You can use the following commands to manage the server:

To manually start the server:
   ```
   sudo systemctl start game-7daystodie
   ```

To manually stop the server:
   ```
   sudo systemctl start game-7daystodie
   ```

To disable auto start on boot:
   ```
   sudo systemctl disable game-7daystodie
   ```

To enable auto start on boot:
   ```
   sudo systemctl enable game-7daystodie
   ```

To console into the server:
   ```
   telnet localhost 8081
   ```



