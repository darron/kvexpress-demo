#!/bin/bash
IP_ADDRESS=$(ifconfig eth0 | grep "inet addr" | cut --delimiter=":" -f 2 | cut --delimiter=" " -f 1)
NODE_NAME=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
sudo tee /etc/consul.d/default.json <<EOF
{
  "client_addr": "127.0.0.1",
  "dogstatsd_addr": "127.0.0.1:8125",
  "data_dir": "/var/lib/consul",
  "node_name": "$NODE_NAME",
  "recursor": "8.8.8.8",
  "leave_on_terminate": false,
  "bind_addr": "0.0.0.0",
  "datacenter": "us-west-2-test",
  "log_level": "trace",
  "advertise_addr": "$IP_ADDRESS",
  "enable_syslog": true,
  "server": true,
  "ui_dir": "/var/lib/consul/ui",
  "bootstrap_expect": 3
}
EOF
sudo chown root.root /etc/consul.d/default.json
sudo service consul start
