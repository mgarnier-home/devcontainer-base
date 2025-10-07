#!/usr/bin/env bash
sudo sh -c "dockerd >/var/log/dockerd.log 2>&1 &"

# for each env varaible taht starts with DEVCONTAINER_ and is not empty, add a line to ~/.zshrc to export it, without the DEVCONTAINER_ prefix
for var in $(compgen -e | grep '^DEVCONTAINER_'); do
  if [ -n "${!var}" ]; then
    echo "export ${var#DEVCONTAINER_}='${!var}'" >> ~/.zshrc
  fi
done



# if there is a variable named SSH_PRIVATE_KEY, then create a file ~/.ssh/id_rsa with its content
if [ -n "$SSH_PRIVATE_KEY" ]; then
  mkdir -p ~/.ssh
  echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
  echo "SSH private key has been set up from env variable."
# else, if there is a file in /run/secrets/SSH_PRIVATE_KEY, then copy it to ~/.ssh/id_rsa
elif [ -f /run/secrets/SSH_PRIVATE_KEY ]; then
  mkdir -p ~/.ssh
  cp /run/secrets/SSH_PRIVATE_KEY ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
  echo "SSH private key has been copied from /run/secrets/SSH_PRIVATE_KEY."
# else, if there is a file in /tmp/SSH_PRIVATE_KEY, then copy it to ~/.ssh/id_rsa
elif [ -f /tmp/SSH_PRIVATE_KEY ]; then
  mkdir -p ~/.ssh
  cp /tmp/SSH_PRIVATE_KEY ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
  echo "SSH private key has been copied from /tmp/SSH_PRIVATE_KEY."
else
  echo "No SSH_PRIVATE_KEY variable found, skipping SSH key setup."
fi

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
