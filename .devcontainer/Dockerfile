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

RUN \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -; \
  apt-key fingerprint 0EBFCD88; \
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"; \
  apt-get update && apt-get install --no-install-recommends -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


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
  chmod 0440 /etc/sudoers.d/${USER}; \
  sudo usermod -aG docker ${USER}


# Setup ssh authorized keys
COPY ssh /home/${USER}/.ssh
RUN \
  chown -R ${USER}:${USER} /home/${USER}; \
  chmod 700 /home/${USER}/.ssh; \
  chmod 600 /home/${USER}/.ssh/*

# Switch to the non-root user
USER ${USER}
WORKDIR /home/${USER}

# Setup VSCode
COPY --chmod=755 --chown=${USER}:${USER} ./vscode /vscode
ENV VSCODE_INSTALL_PATH=/home/${USER}/.vscode-web
ENV VSCODE_EXTENSIONS_PATH=/home/${USER}/.vscode-server/extensions
ENV VSCODE_WEB_PORT=8080
RUN bash /vscode/setup.sh;

VOLUME [ "/mnt/dev" ]

RUN sudo mkdir -p /mnt/dev; \
  sudo chown -R ${USER}:${USER} /mnt

# Install fish and fisher
COPY --chmod=755 --chown=${USER}:${USER} ./fish /home/${USER}/.config/fish
RUN \
  sudo add-apt-repository ppa:fish-shell/release-4 && \
  sudo apt-get update && \
  sudo apt-get install --yes fish
RUN sudo chsh -s /usr/bin/fish ${USER}
RUN fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher && fisher install IlanCosman/tide@v6"

# Tasks Installation
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b .local

# Ansible installation
RUN \
  sudo add-apt-repository --yes --update ppa:ansible/ansible; \
  sudo DEBIAN_FRONTEND=noninteractive TZ=Europe/Paris apt-get install -y ansible

# FNM installation
RUN curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir /home/${USER}/.local --skip-shell

# Add .local to the PATH
RUN fish -c "set -U fish_user_paths /home/${USER}/.local $fish_user_paths"


# Define fish as the default shell
SHELL ["/usr/bin/fish", "-c"]

COPY --chmod=755 --chown=${USER}:${USER} ./setup /setup
RUN sudo chmod -R +x /setup

COPY --chmod=755 --chown=${USER}:${USER} ./entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]


HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD [ -f ~/.setup_complete ] && service ssh status > /dev/null 2>&1 || exit 1

