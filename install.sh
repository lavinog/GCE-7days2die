#! /bin/bash

# Steam account
ROLE_ACCT='steam'
# Steam App ID
APP_ID=294420

#Steam Path
STEAM_PATH='/opt/steam'

#Application Path
APP_PATH='/opt/steam/7d2d'

# Create a steam role account
sudo useradd $ROLE_ACCT

# create folders
sudo mkdir -p ${STEAM_PATH}
sudo mkdir -p ${APP_PATH}

sudo chmod -Rv steam:steam ${STEAM_PATH} ${APP_PATH}

# Install steamcmd
# Steps from https://developer.valvesoftware.com/wiki/SteamCMD#Manually

# install lib32gcc1
sudo apt update
sudo apt -y install lib32gcc1

cd ${STEAM_PATH}
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | sudo -u ${ROLE_ACCT} tar zxvf -

sudo -u ${ROLE_ACCT} steamcmd +login anonymous +force_install_dir ${INSTALL_FOLDER} +app_update ${APP_ID} +quit
