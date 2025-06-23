#!/usr/bin/env bash

if [[ -z "$VSCODE_INSTALL_PATH" || -z "$VSCODE_WEB_PORT" ]]; then
  echo "Error: VSCODE_INSTALL_PATH, and VSCODE_WEB_PORT must be set."
  exit 1
fi

mkdir -p $VSCODE_INSTALL_PATH

echo "Installing Microsoft Visual Studio Code Server! to ${VSCODE_INSTALL_PATH}"

# Download and extract vscode-server
ARCH=$(uname -m)
case "$ARCH" in
x86_64) ARCH="x64" ;;
aarch64) ARCH="arm64" ;;
*)
  echo "Unsupported architecture"
  exit 1
  ;;
esac

HASH=$(curl -fsSL https://update.code.visualstudio.com/api/commits/stable/server-linux-$ARCH-web | cut -d '"' -f 2)
output=$(curl -fsSL https://vscode.download.prss.microsoft.com/dbazure/download/stable/$HASH/vscode-server-linux-$ARCH-web.tar.gz | tar -xz -C ${VSCODE_INSTALL_PATH} --strip-components 1)

if [ $? -ne 0 ]; then
  echo "Failed to install Microsoft Visual Studio Code Server: $output"
  exit 1
fi
echo "VS Code Web has been installed."

bash /vscode/install-extensions.sh "/vscode/default-extensions.json"
