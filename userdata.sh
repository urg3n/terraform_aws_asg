#!/bin/bash
apt-get update
apt-get install -y software-properties-common libffi-dev g++ libssl-dev python-pip python-dev git 
apt-add-repository ppa:ansible/ansible 
apt-get update
apt-get install -y ansible 
ssh-add /home/ubuntu/.ssh/id_rsa
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
cd /tmp/
git clone https://github.com/urg3n/ansible_terraform_aws.git
cd /tmp/ansible_terraform_aws
mv * /etc/ansible/roles/
ansible-playbook --private-key=/home/ubuntu/.ssh/id_rsa -i 'localhost,' /etc/ansible/roles/site.yml
