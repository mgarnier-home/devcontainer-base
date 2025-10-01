#!/usr/bin/env zsh
. ~/.zshrc

set -euxo pipefail

git config --global core.autocrlf false
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_NAME"
