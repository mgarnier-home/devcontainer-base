#!/usr/bin/env bash

if [[ -z "$VSCODE_INSTALL_PATH" || -z "$VSCODE_EXTENSIONS_PATH" ]]; then
  echo "Error: VSCODE_EXTENSIONS_PATH and VSCODE_INSTALL_PATH must be set."
  exit 1
fi

if [[ ! -f "$1" ]]; then
  echo "Error: File $1 does not exist."
  exit 1
fi

VSCODE_WEB="$VSCODE_INSTALL_PATH/bin/code-server"

extensions=$(jq -r '.[]' <"$1")

mkdir -p "$VSCODE_EXTENSIONS_PATH"
echo "Installing VS Code extensions from $1 to $VSCODE_EXTENSIONS_PATH"

for extension in $extensions; do
  echo "Installing extension $extension..."
  output=$($VSCODE_WEB --extensions-dir="$VSCODE_EXTENSIONS_PATH" --install-extension "$extension" --force)
  if [[ $? -ne 0 ]]; then
    echo "Failed to install extension: $extension: $output"
    exit 1
  fi
done
