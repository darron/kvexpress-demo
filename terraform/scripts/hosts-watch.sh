#!/bin/bash

sudo tee /etc/consul.d/hosts.json <<EOF
{
  "watches": [
    {
      "type": "key",
      "key": "/kvexpress/hosts/checksum",
      "handler": "kvexpress out -k hosts -f /etc/hosts.consul -l 10 -c 00644 -d true -z true -e 'sudo pkill -HUP dnsmasq'"
    }
  ]
}
EOF
