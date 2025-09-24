FROM ubuntu:jammy 

# Install baseline packages
RUN apt-get update && \
  apt-get install --no-install-recommends --yes \
  apt-transport-https \
  bash \
  bash-completion \
  build-essential \
  ca-certificates \
  cifs-utils \
  curl \
  dmidecode \
  gnupg-agent \
  gpg \
  htop \
  iputils-ping \
  jq \
  lm-sensors \
  locales \
  man \
  nano \
  openssh-server \
  p7zip-full \
  pciutils \
  python3 \
  python3-pip \
  software-properties-common \
  sudo \
  zip \
  unzip \
  util-linux \
  vim \
  wget \
  rsync \
  tree \
  && \
  # Install latest Git using their official PPA
  add-apt-repository ppa:git-core/ppa && \
  apt-get install --yes git \
  && rm -rf /var/lib/apt/lists/*

# RUN \
#   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -; \
#   apt-key fingerprint 0EBFCD88; \
#   add-apt-repository \
#   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#   $(lsb_release -cs) \
#   stable"; \
#   apt-get update && apt-get install --no-install-recommends -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


ARG SSHD_PORT=2222
RUN \
  sed -i -e "s/^#\(Port\) .*/\1 ${SSHD_PORT}/" /etc/ssh/sshd_config; \
  mkdir /run/sshd; \
  systemctl enable ssh


# Make typing unicode characters in the terminal work.
ENV LANG=en_US.UTF-8
ARG USER=mgarnier


# Create a non-root user
RUN \
  useradd --groups sudo --no-create-home --shell /bin/bash ${USER}; \
  echo "${USER} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USER}; \
  chmod 0440 /etc/sudoers.d/${USER}; 
# \
# sudo usermod -aG docker ${USER}


# Setup ssh authorized keys
COPY ssh /home/${USER}/.ssh
RUN \
  chown -R ${USER}:${USER} /home/${USER}; \
  chmod 700 /home/${USER}/.ssh; \
  chmod 600 /home/${USER}/.ssh/*

# Switch to the non-root user
USER ${USER}
WORKDIR /home/${USER}

# RUN \
#   git config --global core.autocrlf false && \
#   git config --global user.email "$" && \
#   git config --global user.name "${USER}"


# Setup VSCode
COPY --chmod=755 --chown=${USER}:${USER} ./vscode /vscode
ENV VSCODE_INSTALL_PATH=/home/${USER}/.vscode-web
ENV VSCODE_EXTENSIONS_PATH=/home/${USER}/.vscode-server/extensions
ENV VSCODE_WEB_PORT=8080
RUN bash /vscode/setup.sh;

VOLUME [ "/mnt/dev" ]

RUN sudo mkdir -p /mnt/dev; \
  sudo chown -R ${USER}:${USER} /mnt

# Zsh Installation
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" && \
  sudo chsh -s /usr/bin/zsh $USER
SHELL ["/usr/bin/zsh", "-c"]

COPY --chmod=644 --chown=${USER}:${USER} ./zsh/.p10k.zsh /home/${USER}/.p10k.zsh
RUN \
  echo "[[ ! -f /home/${USER}/.p10k.zsh ]] || source /home/${USER}/.p10k.zsh" >> /home/${USER}/.zshrc && \
  echo "export PATH=\$PATH:\$HOME/.local" >> ~/.zshrc

# ASDF Installation
ARG ASDF_VERSION=0.18.0
RUN mkdir -p $HOME/.local && \
  curl -o asdf.tar.gz -L https://github.com/asdf-vm/asdf/releases/download/v${ASDF_VERSION}/asdf-v${ASDF_VERSION}-linux-amd64.tar.gz && \ 
  tar -xzf asdf.tar.gz -C $HOME/.local && \
  rm asdf.tar.gz && \
  echo "export PATH=\${ASDF_DATA_DIR:-\$HOME/.asdf}/shims:\$PATH" >> ~/.zshrc && \
  echo "plugins=(asdf)" >> ~/.zshrc

RUN zsh -c "source ~/.zshrc &&  \
  asdf --version && \
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git && \
  asdf plugin add golang https://github.com/asdf-community/asdf-golang.git"

# Tasks Installation
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b .local && \
  echo "export PATH=\$PATH:\$HOME/.local" >> ~/.zshrc

# Ansible installation
RUN \
  sudo add-apt-repository --yes --update ppa:ansible/ansible; \
  sudo DEBIAN_FRONTEND=noninteractive TZ=Europe/Paris apt-get install -y ansible

# # GO Installation
# ARG GO_VERSION=1.24.5
# RUN \
#   curl -o go.tar.gz https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz; \
#   sudo tar -C /usr/local -xzf go.tar.gz; \
#   rm go.tar.gz; \
#   echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.zshrc; \
#   echo "Go Installed"

# # NVM Installation
# RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash;

# Install gh cli
RUN (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y

COPY --chmod=755 --chown=${USER}:${USER} ./setup /setup
RUN sudo chmod -R +x /setup

COPY --chmod=755 --chown=${USER}:${USER} ./entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]


HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD [ -f ~/.setup_complete ] && service ssh status > /dev/null 2>&1 || exit 1

