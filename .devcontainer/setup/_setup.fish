#!/usr/bin/env fish

cp /run/secrets/SSH_PRIVATE_KEY ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

git config --global core.autocrlf false
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_NAME"

# install node
set -q NODE_VERSION
or set NODE_VERSION 22

fnm install $NODE_VERSION
fnm use $NODE_VERSION

# install go
set -q GO_VERSION
or set GO_VERSION 1.24.5
curl -o go.tar.gz https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go.tar.gz
rm go.tar.gz
set -U fish_user_paths /usr/local/go/bin $fish_user_paths
