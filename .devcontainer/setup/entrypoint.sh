#!/bin/bash
sudo sh -c "dockerd >/var/log/dockerd.log 2>&1 &"
sudo service ssh start

zsh /setup/setup.sh

sleep infinity
