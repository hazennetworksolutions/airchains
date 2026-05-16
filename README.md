<div align="center">

# ⛓️ Airchains Junction Varanasi Testnet Full Node & Validator Setup Guide

**A complete guide to running an Airchains Junction Varanasi testnet full node and registering as a validator**  
*System preparation, binary installation, Cosmovisor setup, and validator creation — step by step.*

[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04+-E95420?style=flat-square&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Airchains](https://img.shields.io/badge/Airchains-Varanasi%20Testnet-7B2FBE?style=flat-square)](https://airchains.io)
[![Version](https://img.shields.io/badge/Node%20Version-v0.3.2-brightgreen?style=flat-square)](https://github.com/airchains-network/junction/releases)
[![Chain ID](https://img.shields.io/badge/Chain%20ID-varanasi--1-blue?style=flat-square)](https://docs.airchains.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

[hazennetworksolutions.com](https://hazennetworksolutions.com)

</div>

---

> **Network:** Airchains Junction Varanasi Testnet (Chain ID: varanasi-1)  
> **Version:** v0.3.2  
> **Last Updated:** May 2026

---

## Table of Contents

- [Hardware Requirements](#hardware-requirements)
- [Network Endpoints](#network-endpoints)
- [Step 1 — System Verification](#step-1--system-verification)
- [Step 2 — System Update and Dependencies](#step-2--system-update-and-dependencies)
- [Step 3 — Install Go](#step-3--install-go)
- [Step 4 — Download Binary](#step-4--download-binary)
- [Step 5 — Install Cosmovisor](#step-5--install-cosmovisor)
- [Step 6 — Create Systemd Service](#step-6--create-systemd-service)
- [Step 7 — Initialize the Node](#step-7--initialize-the-node)
- [Step 8 — Download Genesis and Addrbook](#step-8--download-genesis-and-addrbook)
- [Step 9 — Configure Ports, Gas Prices and Pruning](#step-9--configure-ports-gas-prices-and-pruning)
- [Step 10 — Configure Seeds and Peers](#step-10--configure-seeds-and-peers)
- [Step 11 — Start the Node](#step-11--start-the-node)
- [Step 12 — Create a Wallet](#step-12--create-a-wallet)
- [Step 13 — Register as a Validator](#step-13--register-as-a-validator)
- [Monitoring the Node](#monitoring-the-node)
- [Useful Commands](#useful-commands)
- [Staying Updated](#staying-updated)

---

## Hardware Requirements

| Component | Minimum | Recommended |
|---|---|---|
| Operating System | Ubuntu 22.04+ | Ubuntu 24.04 |
| CPU | 4 cores | 8 cores |
| RAM | 8 GB | 16 GB |
| Disk | 200 GB NVMe SSD | 500 GB NVMe SSD |
| Network | 100 Mbps | 1 Gbps |

---

## Network Endpoints

| Type | Endpoint |
|---|---|
| RPC | https://junction-testnet-rpc.synergynodes.com |
| REST API | https://junction-testnet-api.synergynodes.com |
| Explorer | https://explorer.airchains.io |
| Faucet | https://faucet.airchains.io |
| Official Docs | https://docs.airchains.io |
| GitHub | https://github.com/airchains-network/junction |

---

## Step 1 — System Verification

After SSH-ing into your server, verify the system meets requirements:

```bash
lsb_release -a          # Should be Ubuntu 22.04 or higher
uname -r                # Kernel version
lscpu | grep -E "Model name|CPU\(s\)|Thread|Socket|Core"
free -h                 # Minimum 8 GB RAM
df -h                   # Minimum 200 GB free disk
```

---

## Step 2 — System Update and Dependencies

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git wget htop tmux build-essential jq make lz4 gcc unzip
```

---

## Step 3 — Install Go

Airchains Junction v0.3.2 requires **Go 1.23+**:

```bash
cd $HOME
VER="1.23.0"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"

[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
```

Verify the installation:

```bash
go version
```

Expected output: `go version go1.23.0 linux/amd64`

---

## Step 4 — Download Binary

```bash
wget -O junctiond \
  https://github.com/airchains-network/junction/releases/download/v0.3.2/junctiond-linux-amd64
chmod +x junctiond

mkdir -p $HOME/.junction/cosmovisor/genesis/bin
mv $HOME/junctiond $HOME/.junction/cosmovisor/genesis/bin/

ln -sf $HOME/.junction/cosmovisor/genesis $HOME/.junction/cosmovisor/current -f
sudo ln -sf $HOME/.junction/cosmovisor/current/bin/junctiond /usr/local/bin/junctiond -f
```

Verify:

```bash
junctiond version
```

Expected output: `v0.3.2`

---

## Step 5 — Install Cosmovisor

```bash
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.6.0
```

Verify:

```bash
cosmovisor version
```

---

## Step 6 — Create Systemd Service

Set your moniker and port prefix:

```bash
MONIKER="YOUR_MONIKER"
PORT="26"   # Default is 26. Change to avoid conflicts (e.g. 27, 28...)
```

Create the service file:

```bash
sudo tee /etc/systemd/system/junctiond.service > /dev/null << EOF
[Unit]
Description=Airchains Junction Node Service
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

sudo systemctl daemon-reload
sudo systemctl enable junctiond
```

---

## Step 7 — Initialize the Node

```bash
junctiond config set client chain-id varanasi-1
junctiond config set client keyring-backend test
junctiond config set client node tcp://localhost:${PORT}657

junctiond init $MONIKER --chain-id varanasi-1 --default-denom uamf
```

Set environment variables permanently:

```bash
echo "export MONIKER=$MONIKER" >> $HOME/.bash_profile
echo "export AIRCHAINS_CHAIN_ID=\"varanasi-1\"" >> $HOME/.bash_profile
echo "export AIRCHAINS_PORT=$PORT" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

---

## Step 8 — Download Genesis and Addrbook

```bash
wget -O $HOME/.junction/config/genesis.json \
  https://raw.githubusercontent.com/airchains-network/junction-resources/refs/heads/main/varanasi-testnet/genesis/genesis.json

wget -O $HOME/.junction/config/addrbook.json \
  https://raw.githubusercontent.com/hazennetworksolutions/airchains/refs/heads/main/addrbook.json
```

Verify genesis checksum:

```bash
sha256sum $HOME/.junction/config/genesis.json
```

---

## Step 9 — Configure Ports, Gas Prices and Pruning

### Custom Ports

```bash
sed -i.bak -e "s%:1317%:${AIRCHAINS_PORT}317%g;
s%:8080%:${AIRCHAINS_PORT}080%g;
s%:9090%:${AIRCHAINS_PORT}090%g;
s%:9091%:${AIRCHAINS_PORT}091%g;
s%:8545%:${AIRCHAINS_PORT}545%g;
s%:8546%:${AIRCHAINS_PORT}546%g" $HOME/.junction/config/app.toml

sed -i.bak -e "s%:26658%:${AIRCHAINS_PORT}658%g;
s%:26657%:${AIRCHAINS_PORT}657%g;
s%:6060%:${AIRCHAINS_PORT}060%g;
s%:26656%:${AIRCHAINS_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${AIRCHAINS_PORT}656\"%;
s%:26660%:${AIRCHAINS_PORT}660%g" $HOME/.junction/config/config.toml
```

### Gas Prices

```bash
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.00025uamf"|g' \
  $HOME/.junction/config/app.toml
```

### Pruning

```bash
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.junction/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.junction/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"19\"/" $HOME/.junction/config/app.toml
```

### Enable Prometheus (optional)

```bash
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.junction/config/config.toml
```

### Disable Indexer (saves disk space)

```bash
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.junction/config/config.toml
```

---

## Step 10 — Configure Seeds and Peers

```bash
SEEDS="04e2fdd6ec8f23729f24245171eaceae5219aa91@airchains-testnet-seed.itrocket.net:19656"
PEERS="40266cad75df2e409bb11f9ea155b125c4bb5650@89.117.144.196:63656,e2f4bdc67c3a9c2aa93f8a4b8ba400a8311c9bfb@198.7.120.70:26656,aeaf101d54d47f6c99b4755983b64e8504f6132d@65.21.202.124:28656,dd42021b3d2d25539d3c7b15d8868ed662426b87@94.72.105.165:26656,df2a56a208821492bd3d04dd2e91672657c79325@158.220.126.137:27656,fa60f4730929eae83d00d9e21bb780b4defe6d03@89.58.28.79:11656,7419a1b9753309f5f9d3c62daf882854cc0d7642@152.53.3.95:26656,fa66d9933c74918be38948f9027239663ad8bca6@152.53.18.245:24656,e38891d394c3d602affd1825ce327cde2673a2bb@81.17.102.228:63656,a3895f6115423be3e2486b39f51c6ef4886533bc@165.227.69.136:43456,a5a4616f3e0f1c4a958dfd86875eb54e1098c9d9@195.3.220.4:38656,6cddb734472ff64e140ff7fa85fc02ee30ce6870@5.35.86.125:26656,4f84487af5e8a86baa7e4e428ca7156ae5bc3ab7@148.251.235.130:24656,c520e99dd88a2a6b4c29be751e8b386889d9a1c4@37.60.248.36:43456,c48c090a5fd6e55cd5682306fd246d983a5ff1c3@194.163.191.138:43456"

sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" \
       $HOME/.junction/config/config.toml
```

---

## Step 11 — Start the Node

```bash
sudo systemctl start junctiond
sudo journalctl -u junctiond -f --no-pager -o cat
```

Verify the service is running:

```bash
sudo systemctl status junctiond --no-pager
```

The service should show `active (running)`.

Check sync status:

```bash
junctiond status 2>&1 | jq .SyncInfo
```

Wait until `catching_up` is `false` before proceeding to validator registration.

---

## Step 12 — Create a Wallet

```bash
junctiond keys add wallet --keyring-backend test
```

> ⚠️ **CRITICAL:** Save your mnemonic phrase in a secure location. Without it, you cannot recover your wallet.

To recover an existing wallet:

```bash
junctiond keys add wallet --recover --keyring-backend test
```

Get testnet tokens from the faucet:

> 🚰 **Faucet:** [faucet.airchains.io](https://faucet.airchains.io)

Check your balance:

```bash
junctiond query bank balances $(junctiond keys show wallet -a --keyring-backend test)
```

---

## Step 13 — Register as a Validator

> The node must be **fully synced** before creating a validator.

### Get your pubkey:

```bash
junctiond comet show-validator
```

### Create validator JSON:

```bash
cat > $HOME/validator.json << EOF
{
  "pubkey": $(junctiond comet show-validator),
  "amount": "1000000uamf",
  "moniker": "YOUR_MONIKER",
  "identity": "",
  "website": "",
  "security": "",
  "details": "",
  "commission-rate": "0.05",
  "commission-max-rate": "0.20",
  "commission-max-change-rate": "0.01",
  "min-self-delegation": "1"
}
EOF
```

### Submit the transaction:

```bash
junctiond tx staking create-validator $HOME/validator.json \
  --from wallet \
  --chain-id varanasi-1 \
  --keyring-backend test \
  --gas auto \
  --gas-adjustment 1.4 \
  --fees 500uamf \
  -y
```

### Verify your validator:

```bash
junctiond query staking validator \
  $(junctiond keys show wallet --bech val -a --keyring-backend test)
```

---

## Monitoring the Node

### Watch live block commits:

```bash
sudo journalctl -u junctiond -f --no-pager | grep "committed block"
```

### Full logs:

```bash
sudo journalctl -u junctiond -f --no-pager
```

### Sync status:

```bash
junctiond status 2>&1 | jq .SyncInfo
```

### Service management:

```bash
# Restart service
sudo systemctl restart junctiond

# Stop service
sudo systemctl stop junctiond

# Check status
sudo systemctl status junctiond
```

---

## Useful Commands

### Wallet

```bash
# List wallets
junctiond keys list --keyring-backend test

# Show wallet address
junctiond keys show wallet -a --keyring-backend test

# Check balance
junctiond query bank balances $(junctiond keys show wallet -a --keyring-backend test)
```

### Staking

```bash
# Delegate tokens
junctiond tx staking delegate \
  $(junctiond keys show wallet --bech val -a --keyring-backend test) 1000000uamf \
  --from wallet --chain-id varanasi-1 --keyring-backend test \
  --gas auto --gas-adjustment 1.4 --fees 500uamf -y

# Redelegate tokens
junctiond tx staking redelegate \
  $(junctiond keys show wallet --bech val -a --keyring-backend test) <NEW_VALOPER> 1000000uamf \
  --from wallet --chain-id varanasi-1 --keyring-backend test \
  --gas auto --gas-adjustment 1.4 --fees 500uamf -y

# Undelegate tokens
junctiond tx staking unbond \
  $(junctiond keys show wallet --bech val -a --keyring-backend test) 1000000uamf \
  --from wallet --chain-id varanasi-1 --keyring-backend test \
  --gas auto --gas-adjustment 1.4 --fees 500uamf -y
```

### Rewards

```bash
# Withdraw all rewards
junctiond tx distribution withdraw-all-rewards \
  --from wallet --chain-id varanasi-1 --keyring-backend test \
  --gas auto --gas-adjustment 1.4 --fees 500uamf -y

# Withdraw commission
junctiond tx distribution withdraw-rewards \
  $(junctiond keys show wallet --bech val -a --keyring-backend test) --commission \
  --from wallet --chain-id varanasi-1 --keyring-backend test \
  --gas auto --gas-adjustment 1.4 --fees 500uamf -y
```

### Governance

```bash
# List proposals
junctiond query gov proposals

# Vote on a proposal
junctiond tx gov vote 1 yes \
  --from wallet --chain-id varanasi-1 --keyring-backend test \
  --gas auto --gas-adjustment 1.4 --fees 500uamf -y
```

### Validator Operations

```bash
# Edit validator
junctiond tx staking edit-validator \
  --new-moniker "NEW_MONIKER" \
  --identity "" \
  --from wallet --chain-id varanasi-1 --keyring-backend test \
  --gas auto --gas-adjustment 1.4 --fees 500uamf -y

# Unjail validator
junctiond tx slashing unjail \
  --from wallet --chain-id varanasi-1 --keyring-backend test \
  --gas auto --gas-adjustment 1.4 --fees 500uamf -y

# Check validator signing info
junctiond query slashing signing-info $(junctiond comet show-validator)
```

---

## Staying Updated

Follow these channels to stay informed about upgrades and announcements:

- Discord: [Airchains Discord](https://discord.gg/airchains)
- GitHub Releases: [airchains-network/junction Releases](https://github.com/airchains-network/junction/releases)
- Official Docs: [docs.airchains.io](https://docs.airchains.io)

### Upgrade with Cosmovisor (example: v0.4.0)

```bash
wget -O junctiond \
  https://github.com/airchains-network/junction/releases/download/v0.4.0/junctiond-linux-amd64
chmod +x junctiond

mkdir -p $HOME/.junction/cosmovisor/upgrades/v0.4.0/bin
mv junctiond $HOME/.junction/cosmovisor/upgrades/v0.4.0/bin/
chmod +x $HOME/.junction/cosmovisor/upgrades/v0.4.0/bin/junctiond
```

Cosmovisor will automatically switch to the new binary at the upgrade block height.

---

*Guide maintained by [HazenNetworkSolutions](https://hazennetworksolutions.com)*
