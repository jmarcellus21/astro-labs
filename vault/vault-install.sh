#/bin/bash
# install Vault
# uses a GCP KMS seal

# add official HashiCorp Linux repository
sudo apt install -y software-properties-common apt-transport-https
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install -y vault

# install autocomplete tools
vault -autocomplete-install
complete -C /usr/bin/vault vault

# give vault ability to use mlock syscall
sudo setcap cap_ipc_lock=+ep /usr/bin/vault

# disable swap
sudo swapoff -a

#sudo useradd --system --home /etc/vault.d --shell /bin/false vault

# create Vault configuration file
sudo mkdir --parents /etc/vault.d
sudo touch /etc/vault.d/vault.hcl
sudo chown --recursive vault:vault /etc/vault.d
sudo chmod 640 /etc/vault.d/vault.hcl

# create raft directory
sudo mkdir /opt/raft
sudo chown -R vault:vault /opt/raft

cat > /etc/vault.d/vault.hcl <<EOF
# Full configuration options can be found at https://www.vaultproject.io/docs/configuration

ui = true

#mlock = true
#disable_mlock = true

#storage "file" {
#  path = "/opt/vault/data"
#}

#storage "consul" {
#  address = "127.0.0.1:8500"
#  path    = "vault"
#}

# HTTP listener
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
  # tls_cert_file = "/opt/vault/tls/tls.cert"
  # tls_key_file  = "/opt/vault/tls/tls.key"
}

seal "gcpckms" {
  project    = "log-jammin"
  region     = "global"
  key_ring   = "vault-keyring"
  crypto_key = "vault-key"
}

# HTTPS listener
# listener "tcp" {
# address       = "0.0.0.0:8200"
#   tls_cert_file = "/opt/vault/tls/tls.crt"
#  tls_key_file  = "/opt/vault/tls/tls.key"
#}

# Raft storage provider
storage "raft" {
  path    = "/opt/raft"
  node_id = "raft_node_1"
}
cluster_addr = "http://127.0.0.1:8201"
api_addr     = "http://127.0.0.1:8200"
EOF


cat > /etc/systemd/system/vault.service <<EOF
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable vault
sudo systemctl start vault
# sleep 5
sudo systemctl status vault

# ONLY SET IN DEV. NOT SUITABLE FOR PRODUCTION DEPLOYMENT
# export VAULT_ADDR=http://127.0.0.1:8200

# unseal vault for first time
vault operator init -recovery-shares=1 -recovery-threshold=1 -address=http://127.0.0.1:8200

# ensure Vault is unsealed and initialized
vault status -address=http://127.0.0.1:8200
