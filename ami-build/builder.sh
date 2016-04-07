#!/bin/bash

# How I build a packer / terraform box on AWS so that I can build and deploy from there.

apt-get install -y git unzip make
curl -s https://github.com/darron.keys >> /home/ubuntu/.ssh/authorized_keys
cd /usr/local/bin/
wget https://releases.hashicorp.com/packer/0.10.0/packer_0.10.0_linux_amd64.zip
wget https://releases.hashicorp.com/terraform/0.6.14/terraform_0.6.14_linux_amd64.zip
wget https://github.com/direnv/direnv/releases/download/v2.8.1/direnv.linux-amd64
mv direnv.linux-amd64 direnv
chmod a+x direnv
unzip packer_0.10.0_linux_amd64.zip
unzip terraform_0.6.14_linux_amd64.zip
rm -f *.zip
echo 'eval "$(direnv hook bash)"' >> /home/ubuntu/.bashrc
# Setup some config:
# 1. Install AWS private key for launching boxes.
# 2. Setup .envrc with variables.
# 3. Create terraform/variables.tf
git config --global user.name "My Name"
git config --global user.email example@example.org
