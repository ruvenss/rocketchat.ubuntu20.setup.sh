#!/bin/bash
sudo chown -R 1001:122 "/root/.npm"
if [ $(dpkg-query -W -f='${Status}' figlet 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get install -y -q figlet;
fi
figlet Rocket.Chat
figlet Updating...
sudo systemctl stop rocketchat
figlet Service stopped
sleep 1
sudo rm -rf /opt/Rocket.Chat
sleep 1
figlet Setting NPM
sudo n install 14.19.3
sleep 5
figlet Download latest...
curl -L -s https://releases.rocket.chat/latest/download -o /tmp/rocket.chat.tgz
sleep 5
figlet Uncompressing...
tar -xzf /tmp/rocket.chat.tgz -C /tmp
sleep 10
figlet Installing...
cd /tmp/bundle/programs/server && npm install
sleep 15
sudo mv /tmp/bundle /opt/Rocket.Chat
sleep 1
sudo chown -R rocketchat:rocketchat /opt/Rocket.Chat
sleep 2
figlet Starting...
sudo systemctl daemon-reload
figlet daemon reloaded...
sudo systemctl restart rocketchat.service
sleep 120
figlet Service status...
sudo systemctl status rocketchat.service
figlet Done !
