#!/bin/bash
echo "Rocket Chat Setup for Digital Ocean Ubuntu 20.9"
echo "Your host name.com as accessed from internet (ex: chat.rgwit.be):"
read yourhostname
sudo apt-get -y update
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt-get -y update && sudo apt-get install -y curl && curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
sudo apt-get install -y build-essential mongodb-org nodejs graphicsmagick
sudo npm install -g inherits n && sudo n 12.14.0
curl -L https://releases.rocket.chat/latest/download -o /tmp/rocket.chat.tgz
tar -xzf /tmp/rocket.chat.tgz -C /tmp
cd /tmp/bundle/programs/server && npm install
sudo mv /tmp/bundle /opt/Rocket.Chat
sudo useradd -M rocketchat && sudo usermod -L rocketchat
sudo chown -R rocketchat:rocketchat /opt/Rocket.Chat
cat << EOF |sudo tee -a /lib/systemd/system/rocketchat.service
[Unit]
Description=The Rocket.Chat server
After=network.target remote-fs.target nss-lookup.target nginx.target mongod.target
[Service]
ExecStart=/usr/local/bin/node /opt/Rocket.Chat/main.js
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=rocketchat
User=rocketchat
Environment=NODE_OPTIONS=--max_old_space_size=16144
Environment=MONGO_URL=mongodb://localhost:27017/rocketchat?replicaSet=rs01 MONGO_OPLOG_URL=mongodb://localhost:27017/local?replicaSet=rs01 ROOT_URL=http://$yourhostname:3000/ PORT=3000
[Install]
WantedBy=multi-user.target
EOF
sudo sed -i "s/^#  engine:/  engine: mmapv1/"  /etc/mongod.conf
sudo systemctl enable mongod && sudo systemctl start mongod
mongo --eval "printjson(rs.initiate())"
sudo systemctl enable rocketchat && sudo systemctl start rocketchat
echo "Try your server at http://$yourhostname:3000"
