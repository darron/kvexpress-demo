#!/bin/bash
DD_API_KEY=$(cat /tmp/datadog-api-key)
export DD_API_KEY=$DD_API_KEY
bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"
sudo cat > /tmp/consul.yaml <<EOF
init_config:

instances:
    - url: http://localhost:8500
      catalog_checks: yes
      new_leader_checks: yes
EOF
cd /tmp
sudo mv -f /tmp/consul.yaml /etc/dd-agent/conf.d/consul.yaml
sudo service datadog-agent restart
