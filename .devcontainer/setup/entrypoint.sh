#!/bin/bash
sudo sh -c "dockerd >/var/log/dockerd.log 2>&1 &"

bash /setup/setup-vscode.sh "$(tr '\n' ' ' </setup/vscode-params.json)"

zsh /setup/setup.sh

sudo service ssh start

sleep infinity
