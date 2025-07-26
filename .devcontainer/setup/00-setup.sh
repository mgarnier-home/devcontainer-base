#!/usr/bin/env zsh
. ~/.zshrc

git config --global core.autocrlf false
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_NAME"

# install node
node_version=${NODE_VERSION:-22}
nvm install $node_version
nvm use $node_version
