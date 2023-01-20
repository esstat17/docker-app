FROM ubuntu:22.04
# docker build -t dockertestv1 .
# LABEL about the custom image
LABEL maintainer="esstat17@gmail.com"
LABEL version="0.1"
LABEL description="Docker auto install and testing by running nginx"

ENV DEBIAN_FRONTEND noninteractive
ENV PORT_NEW 8443

# Install prerequesite
RUN set -x \
    && apt-get update \
    && apt-get -y install sudo \
    && apt-get install -y nginx

ARG admin="esstat17"
ARG platform="ubuntu"
ARG debug="false"

ENV USER $admin

ARG homedir=/home/$admin
ENV HOME $homedir

# create a new user named admin
RUN useradd -m $admin -d $HOME -s /bin/bash -u 1001

# add admin to the sudo group
RUN usermod -aG sudo $admin

# RUN useradd -rm -d $HOME -s /bin/bash -g root -G sudo -u 1001 $admin

# give admin user passwordless access to sudo
RUN echo "$admin ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$admin

# change user to admin
USER $admin

# User check
RUN whoami

# Current Directory
WORKDIR $homedir

COPY ./install.sh $homedir

RUN set -x \
    && sudo chown $admin:$admin install.sh \
    && chmod u+x install.sh \
    && bash install.sh $debug

# Clean apt caches
RUN set -x \ 
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

# The following lines below is to test the install.sh script
# Needs root to run nginx, needs to fix this soon
# su - root 
USER root
EXPOSE 80
STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
