#!/bin/bash
DD_API_KEY=$(cat /tmp/datadog-api-key)
NODE_NAME=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
# Create a new config file.
cat > /tmp/datadog.conf <<EOF
[Main]
api_key: $DD_API_KEY
hostname: $NODE_NAME
dd_url: https://app.datadoghq.com
gce_updated_hostname: yes
use_mount: no
EOF
sudo mv -f /tmp/datadog.conf /etc/dd-agent/datadog.conf

# Start it up.
sudo update-rc.d datadog-agent enable
sudo service datadog-agent restart || true

cat > /tmp/goshednsmasq.conf <<EOF
description "goshe dnsmasq stats gathering daemon"

# Defaults set by kernel
limit nofile 1024 4096

emits goshednsmasq-up

start on runlevel [2345]
stop on runlevel [!2345]

exec /usr/local/bin/goshe dnsmasq

post-start exec initctl emit goshednsmasq-up

kill signal INT
EOF

sudo mv -f /tmp/goshednsmasq.conf /etc/init/goshednsmasq.conf
sudo ln -s /lib/init/upstart-job /etc/init.d/goshednsmasq
sudo service goshednsmasq start
