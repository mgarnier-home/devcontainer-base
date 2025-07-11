#!/usr/bin/env bash
sudo sh -c "dockerd >/var/log/dockerd.log 2>&1 &"

# Create or overwrite ~/.ssh/environment file
# env | grep '^DEVCONTAINER_' >~/.ssh/environment

# Execute all files preent in the /setup directory, and respect the shebang
for file in /setup/*; do
  if [ -f "$file" ]; then
    echo "Executing setup file: $file"
    if [[ -x "$file" ]]; then
      # If the file is executable, run it directly
      "$file"
    else
      # If the file is not executable, source it
      echo "Skipping non-executable file: $file"
    fi
  else
    echo "Skipping non-file: $file"
  fi
done

sudo service ssh start

touch ~/.setup_complete

$VSCODE_INSTALL_PATH/bin/code-server serve-web --extensions-dir=$VSCODE_EXTENSIONS_PATH --port $VSCODE_WEB_PORT --host 0.0.0.0 --accept-server-license-terms --without-connection-token --telemetry-level off
