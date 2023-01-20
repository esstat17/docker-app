#!/bin/bash

# Tested at
# Docker Version 20.10.20
# January 17, 2023

set -eo pipefail

START=$(date +%s)

# Blue, Green, Yellow, Red text-color
info() { printf "\r\033[00;34mINFO:\t$1\033[0m\n"; }
success() { printf "\r\033[00;32mSUCCESS:\t$1\033[0m\n"; }
warn() { printf "\r\033[00;33mWARNING:\t$1\033[0m\n"; }
fail() { printf "\r\033[00;31mERROR:\t$1\033[0m\n"; }
failsoexit() {
    printf "\r\033[00;31mERROR:\t$1\033[0m\n"
    exit 1
}

# Required parameters
PARAM_COUNT=0

if [ $PARAM_COUNT -ne 0 ] && [ "$#" -ne $PARAM_COUNT ]; then
	fail "ERROR: $PARAM_COUNT required parameters. You passed $#."
	info "Example on how to use"
	info " ./setup.sh <param>" #inux or debian
	exit 255;
fi
# Input info
info "Number of parameters passed: $#"
info "List of parameters: $@"

# sudoer only
if [ -z "$(groups $USER | grep sudo)" ]; then
    warn "This script requires \`sudo\` permissions for $USER"
fi

# e.g. Debian or Linux
FIRST_INPUT="$1" # If no second input, debug false
SECOND_INPUT="$2"
DEBUG=${FIRST_INPUT:-"false"}

if command -v docker > /dev/null; then
    success "Docker is already installed. Exiting."
    exit 0
fi

# Check if system is using apt or yum package manager
if command -v apt-get > /dev/null; then
  package_manager="apt-get"
elif command -v yum > /dev/null; then
  package_manager="yum"
else
  fail "Unsupported either yum or apt-get are supported package manager for now. Exiting."
fi

install_packages() {    
    # Update first
    sudo "$package_manager" update || failsoexit "fail to \`apt update\`"

    # Define packages to be installed
    # declare -a packages=("$@")
    for package in "$@"; do
      if ! command -v "$package" > /dev/null; then
        info "It looks like \`${package}\` is not yet installed;"
        info "I will try to install it or exit if there's a failure."

        # exec installs
        sudo "$package_manager" install -y "$package" || fail "Fail to install \`${package}\`."
      fi
    done
}

# Define the Tools to be installed
declare -a req_tools=("ca-certificates" "curl" "gnupg" "lsb-release")
install_packages "${req_tools[@]}"

# You can also use this command to get platform
PLATFORM_DETECT=$(lsb_release -i | awk '{print $3}')
GET_PLATFORM_DETECT=${SECOND_INPUT:-"$PLATFORM_DETECT"}
PLATFORM=$(echo "$PLATFORM_DETECT" | tr '[:upper:]' '[:lower:]')

# Linux
# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings || failsoexit "fail to create folder \`/etc/apt/keyrings\`"
curl -fsSL "https://download.docker.com/linux/$PLATFORM/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg || failsoexit "fail to CURL GPG key from repo"

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$PLATFORM \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Your default umask may be incorrectly configured
sudo chmod a+r /etc/apt/keyrings/docker.gpg || warn "Unable to \`chmod a+r /etc/apt/keyrings/docker.gpg\`"

# Defines 
declare -a docker_packages=("docker-ce" "docker-ce-cli" "containerd.io")

# Docker packages installation
install_packages "$docker_packages"

# Enable docker as daemon
if [ "$DEBUG" != "true" ]; then
  sudo systemctl start docker || warn "Unable to \`systemctl start docker\`"
  sudo systemctl enable docker || warn "Unable to \`systemctl enable docker\`"
fi

# Post Installation
# see@ https://docs.docker.com/engine/install/linux-postinstall/
# Add the current user to the docker group
sudo groupadd docker || warn "Unable to \`groupadd docker\`"
sudo usermod -aG docker $USER || warn "Unable to \`usermod -aG docker ${USER}\`"
newgrp docker || warn "Unable to \`newgrp docker\`"

# To fix some strange error priviledges
sudo chown "$USER":"$USER" "$HOME"/.docker -R || warn "Cannot chown $USER"
sudo chmod g+rwx "$HOME"/.docker -R || warn "Cannot chmod $USER"

if command -v docker > /dev/null; then
    success "Congratulations! Docker has been successfully installed!"
    exit 0
fi

# Docker Compose Installation
if command -v docker-compose > /dev/null; then
    success "Also \`docker-compose\` is already installed. Exiting."
    exit 0
fi
# Get the latest version
COMPOSE_VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/docker/compose/releases/latest | sed -e 's|.*/||')

sudo curl -fL "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || failsoexit "fail to CURL docker-compose repo"
sudo chmod +x /usr/local/bin/docker-compose || failsoexit "Unable to \`chmod +x /usr/local/bin/docker-compose\`"

if command -v docker-compose > /dev/null; then
    success "Also Docker-Compose has been successfully installed!"
    exit 0
fi
END=$(date +%s)
DIFF=$(( $END - $START ))
# Print the total runtime of the script
info "\n It took $DIFF seconds to execute. \n\n"
exit 0
