#!/bin/bash
IP_ADDRESS=$(ifconfig eth0 | grep "inet addr" | cut --delimiter=":" -f 2 | cut --delimiter=" " -f 1)
NODE_NAME=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
BOOTSTRAP_SERVER=$(cat /tmp/consul-server-addr)
sudo cat > /tmp/consul.json <<EOF
{
  "client_addr": "127.0.0.1",
  "dogstatsd_addr": "127.0.0.1:8125",
  "data_dir": "/var/lib/consul",
  "start_join": [
    "$BOOTSTRAP_SERVER"
  ],
  "node_name": "$NODE_NAME",
  "recursor": "8.8.8.8",
  "leave_on_terminate": true,
  "bind_addr": "0.0.0.0",
  "datacenter": "us-west-2-test",
  "log_level": "info",
  "advertise_addr": "$IP_ADDRESS",
  "enable_syslog": true
}
EOF
sudo mv -f /tmp/consul.json /etc/consul.d/default.json
# Add datadog service.
ALL_ROLES=("kafka" "cassandra" "haproxy" "posgresql" "redis" "lamar" "context-server" "rawls" "delancie" "bubs" "daniels" "spidly" "trace" "bunk" "influx" "prometheus" "spark" "tick" "mysql" "druid")
RANDOM=$$$(date +%s)
ROLE=${ALL_ROLES[$RANDOM % ${#ALL_ROLES[@]} ]}
sudo cat > /tmp/datadog.json <<EOF
{
  "service": {
    "name": "datadog",
    "tags": [
      "$ROLE"
    ],
    "check": {
      "interval": "60s",
      "script": "/bin/true"
    }
  }
}
EOF
sudo mv -f /tmp/datadog.json /etc/consul.d/service-datadog.json
# Add 1 of the services.
sudo cat > /tmp/service.json <<EOF
{
  "service": {
    "name": "$ROLE",
    "check": {
      "interval": "60s",
      "script": "/bin/true"
    }
  }
}
EOF
sudo mv -f /tmp/service.json /etc/consul.d/service-$ROLE.json
sudo chown -R root.root /etc/consul.d/
sudo service consul start
