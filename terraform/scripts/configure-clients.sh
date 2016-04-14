#!/bin/bash
IP_ADDRESS=$(ifconfig eth0 | grep "inet addr" | cut --delimiter=":" -f 2 | cut --delimiter=" " -f 1)
NODE_NAME=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
BOOTSTRAP_SERVER=$(cat /tmp/consul-server-addr)

# Add dns torture script.
sudo tee /usr/local/bin/dnspound.sh <<EOF
#!/bin/bash
DOMAINS=\$(cat /etc/hosts.consul | cut -d ' ' -f 2 | sort | uniq)
while [ 1 ];
do
  for domain in $DOMAINS
  do
    dig \$domain
  done
done
EOF
sudo chmod a+x /usr/local/bin/dnspound.sh

sudo tee /etc/consul.d/default.json <<EOF
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
# Add datadog service.
ALL_ROLES=("kafka" "cassandra" "haproxy" "posgresql" "redis" "lamar" "context-server" "rawls" "delancie" "bubs" "daniels" "spidly" "trace" "bunk" "influx" "prometheus" "spark" "tick" "mysql" "druid")
RANDOM=$$$(date +%s)
ROLE=${ALL_ROLES[$RANDOM % ${#ALL_ROLES[@]} ]}
sudo tee /etc/consul.d/service-datadog.json <<EOF
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
# Add 1 of the services.
AZ=$(ec2metadata --availability-zone)
sudo tee /etc/consul.d/service-$ROLE.json <<EOF
{
  "service": {
    "name": "$ROLE",
    "tags": [
      "az-$AZ",
      "random-long-words-go-here",
      "and-another-one-here"
    ],
    "check": {
      "interval": "60s",
      "script": "/bin/true"
    }
  }
}
EOF

sudo tee /etc/consul.d/dnspound.json <<EOF
{
  "watches": [
    {
      "type": "event",
      "name": "dnspound",
      "handler": "sifter run -d true -e '/usr/local/bin/dnspound.sh'"
    }
  ]
}
EOF

sudo chown -R root.root /etc/consul.d/
sudo service consul start
