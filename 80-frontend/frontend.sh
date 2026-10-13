#!/bin/bash
set -e
echo "===== SCRIPT STARTED ====="

echo "===== CHECKING DNF ====="
sudo dnf --version

echo "===== INSTALLING ANSIBLE ====="
sudo dnf install  ansible -y

echo "===== ANSIBLE INSTALLED ====="

ansible --version

echo "===== RUNNING ANSIBLE PULL ====="

ansible-pull -i localhost -U https://github.com/jitheshl/expense-ansible-roles-tf.git -e "component=frontend" -e "environment=$1"  main.yaml

echo "===== SCRIPT COMPLETED ====="