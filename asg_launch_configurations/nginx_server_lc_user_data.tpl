#!/bin/bash
apt install git -y
pip install ansible
git clone https://github.com/s2zaman/devops_assignment.git /tmp/devops-assignment
/usr/local/bin/ansible-playbook -i /tmp/devops-assignment/ansible_stuff/hosts /tmp/devops-assignment/ansible_stuff/nginx_server.cfg.yaml &> /tmp/ansible.log