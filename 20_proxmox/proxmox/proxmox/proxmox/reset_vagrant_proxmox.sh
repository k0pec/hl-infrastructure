#!/usr/bin/env bash
#rm ~/.ssh/known_hosts
#touch  ~/.ssh/known_hosts
cp .vagrant/machines/pve1/virtualbox/private_key ~/.ssh/vagrant_key1
cp .vagrant/machines/pve2/virtualbox/private_key ~/.ssh/vagrant_key2
cp .vagrant/machines/pve-nfs/virtualbox/private_key ~/.ssh/vagrant_key3
chmod 600 ~/.ssh/vagrant_key1
chmod 600 ~/.ssh/vagrant_key2
chmod 600 ~/.ssh/vagrant_key3
ssh-keygen -R 192.168.0.59
ssh-keygen -R 192.169.0.60
ssh-keygen -R 192.168.0.61
