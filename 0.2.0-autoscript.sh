#!/bin/bash
LOG_FILE="/var/log/airchains_node_install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

printGreen() {
    echo -e "\033[32m$1\033[0m"
}

printLine() {
    echo "------------------------------"
}

# Function to print the node logo
function printNodeLogo {
    echo -e "\033[32m"
    echo "          
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
██████████████████████████████████████████████        ██████████████████████████████████████████████
███████████████████████████████████████████              ███████████████████████████████████████████
████████████████████████████████████████                    ████████████████████████████████████████
█████████████████████████████████████                          █████████████████████████████████████
█████████████████████████████████                                  █████████████████████████████████
██████████████████████████████             █             █            ██████████████████████████████
████████████████████████████           █████             ████           ████████████████████████████
████████████████████████████          ██████             ██████         ████████████████████████████
████████████████████████████          ██████             ██████          ███████████████████████████
████████████████████████████          ███████            ██████          ███████████████████████████
████████████████████████████          ██████████         ██████          ███████████████████████████
████████████████████████████          █████████████      ██████          ███████████████████████████
████████████████████████████             █████████████     ████          ███████████████████████████
████████████████████████████          █     █████████████     █          ███████████████████████████
████████████████████████████          █████     ████████████             ███████████████████████████
████████████████████████████          ██████       ████████████          ███████████████████████████
████████████████████████████          ██████          █████████          ███████████████████████████
████████████████████████████          ██████             ██████          ███████████████████████████
████████████████████████████          ██████             ██████          ███████████████████████████
████████████████████████████          ██████             ██████         ████████████████████████████
████████████████████████████            ████             ███            ████████████████████████████
██████████████████████████████                                        ██████████████████████████████
█████████████████████████████████                                  █████████████████████████████████
█████████████████████████████████████                           ████████████████████████████████████
████████████████████████████████████████                    ████████████████████████████████████████
███████████████████████████████████████████              ███████████████████████████████████████████
██████████████████████████████████████████████        ██████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
████████████████████████████████████████████████████████████████████████████████████████████████████
Hazen Network Solutions 2024 All rights reserved."
    echo -e "\033[0m"
}

# Show the node logo
printNodeLogo

# User confirmation to proceed
echo -n "Type 'yes' to start the installation Airchains v0.2.0 and press Enter: "
read user_input

if [[ "$user_input" != "yes" ]]; then
  echo "Installation cancelled."
  exit 1
fi

# Function to print in green
printGreen() {
  echo -e "\033[32m$1\033[0m"
}

printGreen "Starting installation..."
sleep 1

printGreen "If there are any, clean up the previous installation files"

sudo systemctl stop junctiond
sudo systemctl disable junctiond
sudo rm -rf /etc/systemd/system/junctiond.service
sudo rm $(which junctiond)
sudo rm -rf $HOME/.junctiond
sed -i "/junctiond_/d" $HOME/.bash_profile

# Update packages and install dependencies
printGreen "1. Updating and installing dependencies..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y

# User inputs
read -p "Enter your MONIKER: " MONIKER
echo 'export MONIKER='$MONIKER
read -p "Enter your PORT (2-digit): " PORT
echo 'export PORT='$PORT

# Setting environment variables
echo "export MONIKER=$MONIKER" >> $HOME/.bash_profile
echo "export AIRCHAINS_CHAIN_ID=\"junction\"" >> $HOME/.bash_profile
echo "export AIRCHAINS_PORT=$PORT" >> $HOME/.bash_profile
source $HOME/.bash_profile

printLine
echo -e "Moniker:        \e[1m\e[32m$MONIKER\e[0m"
echo -e "Chain ID:       \e[1m\e[32m$AIRCHAINS_CHAIN_ID\e[0m"
echo -e "Node custom port:  \e[1m\e[32m$AIRCHAINS_PORT\e[0m"
printLine
sleep 1

# Install Go
printGreen "2. Installing Go..." && sleep 1
cd $HOME
VER="1.23.0"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=\$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin

# Version check
echo $(go version) && sleep 1

# Download Prysm protocol binary
printGreen "3. Downloading Airchains binary and setting up..." && sleep 1
wget -O junctiond https://github.com/airchains-network/junction/releases/download/v0.2.0/junctiond-linux-amd64
chmod +x junctiond
mkdir -p $HOME/.junction/cosmovisor/genesis/bin
mv $HOME/junctiond $HOME/.junction/cosmovisor/genesis/bin
sudo ln -s $HOME/.junction/cosmovisor/genesis $HOME/.junction/cosmovisor/current -f
sudo ln -s $HOME/.junction/cosmovisor/current/bin/junctiond /usr/local/bin/junctiond -f

# Create service file
printGreen "6. Creating service file..." && sleep 1
sudo tee /etc/systemd/system/junctiond.service > /dev/null << EOF
[Unit]
Description=junction node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.junction"
Environment="DAEMON_NAME=junctiond"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.junction/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF


# Enable the service
sudo systemctl daemon-reload
sudo systemctl enable junctiond

# Initialize the node
printGreen "7. Initializing the node..."
prysmd config set client chain-id ${AIRCHAINS_CHAIN_ID}
prysmd config set client keyring-backend test
prysmd config set client node tcp://localhost:${AIRCHAINS_PORT}657
prysmd init ${MONIKER} --chain-id ${AIRCHAINS_CHAIN_ID}

# Download genesis and addrbook files
printGreen "8. Downloading genesis and addrbook..."
curl -Ls https://raw.githubusercontent.com/hazennetworksolutions/airchains/refs/heads/main/genesis.json > $HOME/.junction/config/genesis.json
wget -O $HOME/.junction/config/addrbook.json "https://raw.githubusercontent.com/hazennetworksolutions/airchains/refs/heads/main/addrbook.json"

# Configure gas prices and ports
printGreen "9. Configuring custom ports and gas prices..." && sleep 1
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.001amf"|g' $HOME/.junction/config/app.toml
sed -i.bak -e "s%:1317%:${AIRCHAINS_PORT}317%g;
s%:8080%:${AIRCHAINS_PORT}080%g;
s%:9090%:${AIRCHAINS_PORT}090%g;
s%:9091%:${AIRCHAINS_PORT}091%g;
s%:8545%:${AIRCHAINS_PORT}545%g;
s%:8546%:${AIRCHAINS_PORT}546%g;
s%:6065%:${AIRCHAINS_PORT}065%g" $HOME/.junction/config/app.toml

# Configure P2P and ports
sed -i.bak -e "s%:26658%:${AIRCHAINS_PORT}658%g;
s%:26657%:${AIRCHAINS_PORT}657%g;
s%:6060%:${AIRCHAINS_PORT}060%g;
s%:26656%:${AIRCHAINS_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${AIRCHAINS_PORT}656\"%;
s%:26660%:${AIRCHAINS_PORT}660%g" $HOME/.junction/config/config.toml

# Set up seeds and peers
printGreen "10. Setting up peers and seeds..." && sleep 1
SEEDS="2d1ea4833843cc1433e3c44e69e297f357d2d8bd@5.78.118.106:26656"
PEERS="40266cad75df2e409bb11f9ea155b125c4bb5650@89.117.144.196:63656,e2f4bdc67c3a9c2aa93f8a4b8ba400a8311c9bfb@198.7.120.70:26656,aeaf101d54d47f6c99b4755983b64e8504f6132d@65.21.202.124:28656,dd42021b3d2d25539d3c7b15d8868ed662426b87@94.72.105.165:26656,df2a56a208821492bd3d04dd2e91672657c79325@158.220.126.137:27656,fa60f4730929eae83d00d9e21bb780b4defe6d03@89.58.28.79:11656,7419a1b9753309f5f9d3c62daf882854cc0d7642@152.53.3.95:26656,fa66d9933c74918be38948f9027239663ad8bca6@152.53.18.245:24656,e38891d394c3d602affd1825ce327cde2673a2bb@81.17.102.228:63656,a3895f6115423be3e2486b39f51c6ef4886533bc@165.227.69.136:43456,a5a4616f3e0f1c4a958dfd86875eb54e1098c9d9@195.3.220.4:38656,6cddb734472ff64e140ff7fa85fc02ee30ce6870@5.35.86.125:26656,4f84487af5e8a86baa7e4e428ca7156ae5bc3ab7@148.251.235.130:24656,c520e99dd88a2a6b4c29be751e8b386889d9a1c4@37.60.248.36:43456,c48c090a5fd6e55cd5682306fd246d983a5ff1c3@194.163.191.138:43456,6b2791ccb51d06fe1891b387b352f2b7a2a05f6e@158.220.99.216:26656,054b081a861d7613273b0ceb4baab62784995820@144.126.132.101:38656,8d9b73a7e142a2dc4294dcf1e05f3829f24847d4@213.199.53.39:43456,f35755adc8ec5bf8b9816a6f5a22cf4687829e7f@109.199.101.229:43456,d0a4dfb6cc7ee326a0681ae47c203d03e65f7ab5@88.198.4.19:26656"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.junction/config/config.toml
sed -i.bak -e "s/^seeds = \"\"/seeds = \"$SEEDS\"/" $HOME/.junction/config/config.toml
sed -i.bak -e "s/^persistent_peers = \"\"/persistent_peers = \"$PEERS\"/" $HOME/.junction/config/config.toml

# Pruning Settings
printGreen "12. Setting up pruning config..." && sleep 1
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.junction/config/app.toml 
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.junction/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"19\"/" $HOME/.junction/config/app.toml

# Download the snapshot
# printGreen "12. Downloading snapshot and starting node..." && sleep 1





# Start the node
printGreen "13. Starting the node..."
sudo systemctl start junctiond

# Check node status
printGreen "14. Checking node status..."
sudo journalctl -u junctiond -f -o cat

# Verify if the node is running
if systemctl is-active --quiet prysmd; then
  echo "The node is running successfully! Logs can be found at /var/log/airchains_node_install.log"
else
  echo "The node failed to start. Logs can be found at /var/log/airchains_node_install.log"
fi
