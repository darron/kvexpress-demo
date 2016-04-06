#!/bin/bash
apt-get update
apt-get -y upgrade

# Add some other software - consul, kvexpress, etc.
mkdir -p /usr/local/bin
cd /usr/local/bin
curl -s http://stedolan.github.io/jq/download/linux64/jq > jq
curl -s https://raw.githubusercontent.com/octohost/octohost-cookbook/master/files/default/consulkv > consulkv
chmod a+x jq consulkv

curl -s https://packagecloud.io/install/repositories/darron/consul/script.deb.sh | sudo bash
curl -s https://packagecloud.io/install/repositories/darron/consul-webui/script.deb.sh | sudo bash
curl -s https://packagecloud.io/install/repositories/darron/consul-template/script.deb.sh | sudo bash
curl -s https://packagecloud.io/install/repositories/kvexpress/kvexpress/script.deb.sh | sudo bash
curl -s https://packagecloud.io/install/repositories/darron/goshe/script.deb.sh | sudo bash
curl -s https://packagecloud.io/install/repositories/darron/consul-cli/script.deb.sh | sudo bash
curl -s https://packagecloud.io/install/repositories/darron/sifter/script.deb.sh | sudo bash

apt-get -y install consul consul-template consul-webui kvexpress goshe consul-cli sifter

mkdir -p /var/lib/consul
mkdir -p /etc/consul.d/

# Setup the kvexpress hosts watch.
cat > /etc/consul.d/hosts.json <<EOF
{
  "watches": [
    {
      "type": "key",
      "key": "/kvexpress/hosts/checksum",
      "handler": "kvexpress out -k hosts -f /etc/hosts.consul -l 10 -c 00644 -d true -e 'sudo pkill -HUP dnsmasq'"
    }
  ]
}
EOF

# Let's install some other software.

apt-get -y install stress cpulimit rand

apt-get -y install dnsmasq

# Setup dnsmasq.
touch /etc/hosts.consul
mkdir -p /var/log/dnsmasq/ && chmod 755 /var/log/dnsmasq

echo 'server=/consul/127.0.0.1#8600' > /etc/dnsmasq.d/10-consul

cat > /etc/default/dnsmasq <<EOF
DNSMASQ_OPTS="--addn-hosts=/etc/hosts.consul --log-facility=/var/log/dnsmasq/dnsmasq --local-ttl=10"
ENABLED=1
CONFIG_DIR=/etc/dnsmasq.d,.dpkg-dist,.dpkg-old,.dpkg-new
EOF

service dnsmasq restart

# Install Datadog
DD_API_KEY=$(cat /tmp/datadog-api-key)
export DD_API_KEY=$DD_API_KEY
bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"
cat > /etc/dd-agent/conf.d/consul.yaml <<EOF
init_config:

instances:
    - url: http://localhost:8500
      catalog_checks: yes
      new_leader_checks: yes
EOF

# Cleanup and disable datadog.
service datadog-agent stop
rm -f /etc/dd-agent/datadog.conf
update-rc.d datadog-agent disable
